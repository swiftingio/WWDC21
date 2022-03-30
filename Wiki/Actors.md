## Actors

If we want to share the mutable state to ensure the concurrent access to it, we have to provide the synchronization. `actor` is a new type which allow us to achieve such a synchronization and prevent the **data races**.

Simple example of the data race:

```
class Counter {
  var value = 0

  func increment() -> Int {
    value = value + 1
    return value
  }
}

let counter = Counter()
Task.detached {
  print(counter.increment())
}

Task.detached {
  print(counter.increment())
}
```

We might get 1 and then 2 or 2 and then 1.
Of course at the end the counter would be left in a consistent state.

Unfortunately, it may happen that we can get 1 and 1 if both tasks read a 0 and write 1. Or even 2 and 2 if the return `print` statements happens after both increment operations.

#### Actor type

In the example below, since the Counter is an actor - it ensures that the value isn't accessed concurrently. This guarantee that the data races won't occur.

```
actor Counter {
  var value = 0

  func increment() -> Int {
    value = value + 1
    return value
  }
}
```

## APODy app

In an example APODy app we created an actor which isolates the `NSImageCache` to prevent data races while caching the data or removing the image from the cache.

```
public actor ImageCache {
    let cache: NSCache<NSString, UIImage>
...
    public func insert(image: UIImage, for key: String) {
        let nsstring = NSString(string: key)
        cache.setObject(image, forKey: nsstring)
    }

    public func remove(in key: String) {
        let nsstring = NSString(string: key)
        cache.removeObject(forKey: nsstring)
    }
...
}
```

As there is one instance of above actor `ImageCache` in the app lifecycle, it can be shared across different parts of the application. But since we declared that it is an `actor` type, its `let cache` access/modifications can happen safely from the actor's internal scope functions `func insert` or `func remove`. 

For example we could safely cache images in the background by launching multiple detached Tasks to insert the image without worrying about simultaneous change.


```
     private let imageCache: ImageCache
...
     private func fetchImage(url: String) async throws -> UIImage {
        if let cachedImage = await imageCache.getImage(for: url) {
            return cachedImage
        } else {
            let image = try await networking.fetchImage(url: url)
            cacheImage(image: image, url: url)
            return image
        }
    }

    // MARK: Helper

    private func cacheImage(image: UIImage, url: String) {
        Task.detached(priority: .background) { [weak self] in
            if await self?.imageCache.getImage(for: url) == nil {
                await self?.imageCache.insert(image: image, for: url)
            }
        }
    }
```

### Main actor

Main actor perform its synchronization throughout the main queue.

We can just add an @MainActor attribute to specify that the class properties has to be synchronized against the main thread.

```
@MainActor class ApodViewModel: ObservableObject {
    @Published var thumbnails: [String: UIImage] = [:]

    let persistence: ApodPersistence

    private let dataSource: ThumbnailDataSource
    private let networking: ApodNetworking

    init(
        networking: ApodNetworking,
        persistence: ApodPersistence,
        dataSource: ThumbnailDataSource
    ) {
        self.persistence = persistence
        self.networking = networking
        self.dataSource = dataSource
    }

    public func refreshData() async throws {
        let currentDate = Date()
        let endDate = Calendar.current.date(byAdding: .month, value: -1, to: currentDate)!

        let objects = try await networking.fetchApods(
            startDate: endDate,
            endDate: currentDate
        )
        try await persistence.save(apods: objects)
    }

    public func fetchThumbnails(for models: [ApodModel]) async {
        for await (url, image) in dataSource.getThumbnails(models: models) {
            thumbnails[url] = image
        }
    }
}
```

`persistence`, `dataSource` and `networking` are actors and their tasks (eg. `persistence.save` or `for await thumbnails in dataSource.getThumbnails(models: models)` will be scheduled on the different thread, and it wouldn't block the main thread.

Since we defined that the `ApodViewModel ` is a `@MainActor`, the `thumbnails[url] = image` line will be always executed from the main thread so our view will be updated correctly.