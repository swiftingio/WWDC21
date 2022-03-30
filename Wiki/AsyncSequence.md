### AsyncSequence - replacing Combine publisher with AsyncSequence.

Based on the WWDC21 session - [Meet AsyncSequence](https://developer.apple.com/videos/play/wwdc2021/10058/), the `AsyncSequence` is very similar to the normal `Sequence` but each element is delivered asynchronously.

Good use cases for AsyncSequence are callbacks or delegate methods that are called multiple times. But it seems like `AsyncSequence` might replace the Combine's `Publisher` in some scenarios.

For example I used to implement `NSFetchedResultsController` using Combine's publisher to deliver the results from the persistence.

In this article we will replace the Combine's `Publisher` with the `AsyncSequence` to get the advantage from the Structured Concurrency and boost the performance a little bit by removing the GCD approach. 

### Combine approach

Let's imagine the custom class which wraps the `NSFetchedResultsController` and allows for listening to the data changes in the persistence by listening to all of the `Apod` Core Data elements using the `Publisher`.

So an example class might look like below:
```
public class ApodPersistenceDataSource: NSObject {
    var publisher: CurrentValueSubject<[APODModel], CoreDataError>?
    private let fetchedResultController: NSFetchedResultsController<Apod>
    
    private var currentData: [APODModel] {
        let fetchedData = fetchedResultController?.fetchedObjects ?? []
        let mappedData = fetchedData.compactMap { APODModel(coreDataApod: $0) }
        return mappedData
    }
...
}
```

So first we declare the `publisher` via which we will provide an array of custom model structs created from the `Apod` elements retrieved from Core Data to the outside world.

The computed property `currentData` is a helper which allows to dynamically get the data from the `fetchedResultController` and it also maps the data into the internal structure.

Also we initialize the `NSFetchedResultsController` to be able to get the data from persistence via the proper delegate method:


```
extension ApodPersistenceDataSource: NSFetchedResultsControllerDelegate {
    public func controllerDidChangeContent(_: NSFetchedResultsController<NSFetchRequestResult>) {
        context.perform { [weak self] in
            guard let self = self else { return }
            self.publisher?.send(self.currentData)
        }
    }
}
```

And an example usage from the parent class would be like:
```
class ViewModel {
 let objects: [APODModel]
 let persistenceSource: ApodPersistenceDataSource
...
 public func bindDataSource() {
        persistenceSource.publisher
            .subscribe(on: DispatchQueue.global())
            .receive(on: DispatchQueue.main)
            .sink { [weak self] newData in
            self?.objects = newData
        }
        .store(in: &cancellables)
    }
}
```

So this allows us to continuously listen to the data source based on the cancellable lifecycle. 

This approach is fine, but as you may notice it uses the `DispatchQueue.global()` and `DispatchQueue.main` from the GCD to listen for the data on the background queue and then switch to the main queue to update the view on the main thread. According to Apple it is more efficient to not introduce new GCD concurrent queues because it may lead to the thread explosion or excessive thread switching. (more explained in the Swift Concurrency: Behind the scenes)

So the modern (Swift) approach is recommended, and can be achieved by introducing `await` semantics.

### AsyncSequence approach

#### Easy way - make use of new `values` property.

Fortunately the easiest way would be to use `values` property on publisher since Combine publishers are equipped with the support for `AsyncSequence`.

Basically `values` is an `AsyncStream` which allows us to continuously listen to the data source using the new `await` mechanism and asynchronously iterate over the collection. So we can just adapt the `bindDataSource` function to:

```
actor ViewModel {
let persistenceSource: ApodPersistenceDataSource
let objects: [APODModel]

public func bindDataSource() async {
        for await objects in persistenceSource.publisher.values {
            self?.objects = objects
        }
    }
}
```

As you may noticed, it is also good to protect the mutable state of objects declaring a ViewModel as an `actor`.

#### 2nd approach - get rid of the publisher and create your own AsyncSequence.

We can of course prepare very easily the version of the DataSource with our custom implementation of AsyncSequence.

```
public class ApodPersistenceDataSource: NSObject {
    private var newDataAppeared: (([APODModel]) -> Void)?
    private var fetchedResultController: NSFetchedResultsController<Apod>?

 private var currentData: [APODModel] {
        let fetchedData = fetchedResultController?.fetchedObjects ?? []
        let mappedData = fetchedData.compactMap { APODModel(coreDataApod: $0) }
        return mappedData
    }
...
}
```

For this we would need to use the closure which will communicate our `AsyncStream` about the changes in the datasource from the deleagte method:

```
extension ApodPersistenceDataSource: NSFetchedResultsControllerDelegate {
    public func controllerDidChangeContent(_: NSFetchedResultsController<NSFetchRequestResult>) {
        newDataAppeared?(currentData)
    }
}
```

Now we can just create a public method which creates the AsyncStream like below:

```
public func getObjects() -> AsyncStream<[APODModel]> {
        return AsyncStream<[APODModel]> { [weak self] continuation in
            guard let self = self else {
                continuation.finish()
                return
            }
            continuation.yield(self.currentData)

            self.newDataAppeared = { newData in
                continuation.yield(newData)
            }
        }
    }
```

Using the continuation we can `yield` the data into the stream whenever new data appears from the data source.

And the binding would look like this:
```
actor ViewModel {
    let dataSource: ApodPersistenceDataSource
    let objects: [APODModel]
...
    public func bindDataSource() async {
        for await newObjects in dataSource.getObjects() {
            self.objects = newObjects 
        }
    }
}
```