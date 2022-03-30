#### What are the Tasks?

- Tasks provides a new async context for executing code concurrently 
- Swift checks your usage of tasks to help prevent concurrency bugs
- when calling an async function a task is not created (we have to create a task explicitly)
- Whenever you make a call from one async function to another, the same task is used to execute the call.
- Marking a task as canceled does not stop the task. It simply informs the task that its results are no longer needed. 
- Structured task guarantee: when a task is canceled, all subtasks that are decedents of that task will be automatically canceled too.
- we have diffrent kind of taks with diffrent flavors:

Structured tasks:

* Async let task
* Group task

unstructured tasks:

* Detached tasks

## Structured Tasks

### Async let task

for better understanding the async let's look at the following code:

```
func fetchOneThumbNail(with id: String) async throws -> UIImage {
    let imageReq = imageReq(for: id), metadaReq = metaDataReq(for: id)
    
    let (data, _) = try await URLSession.shared.data(for: imageReq)
    let (metadata, _) = try await URLSession.shared.data(for: metadaReq)
    
    guard let size = parseSize(from: metadata),
          let image = await UIImage(data: data)?.byPreparingThumbNail(ofSize: size) else {
              throw ThumbnailFailedError()
          }
    return image
}

```

Here we can see some drawbacks that two calls are running sequentially, so we will fetch for metadata after downloading the image.

But how we could run those two things concurrently? Here we can use async let task:

#### So what it is async let task?

- is a concurrent binding
- async-let allows for creating a fixed number of child tasks 
- used to make a concurrent call which will be done by child task
- child task is created by the parent task, and parent tasks will be finished when all childs finished their work
-  Async-let is scoped like a variable binding. That means the two childs tasks must complete before the next loop
-  with automatic management of cancellation and error propagation if the binding goes out of scope. 

So now we can refactor previous code in that way:

```
func fetchOneThumbNail(with id: String) async throws -> UIImage {
    let imageReq = imageReq(for: id), metadaReq = metaDataReq(for: id)
    
    async let (data, _) = URLSession.shared.data(for: imageReq)
    async let (metadata, _) = URLSession.shared.data(for: metadaReq)
    
    guard let size = parseSize(from: metadata),
          let image = await UIImage(data: data)?.byPreparingThumbNail(ofSize: size) else {
              throw ThumbnailFailedError()
          }
    return image
}

```

#### Task tree

For better understanding a concept of taks is very important to get know better the relations between them because it brings to us:

- cancellation
- priority
- task local-variables

Task tree rules:

- Tasks are not the child of a specific function, but their lifetime may be scoped to it
- The tree is made up of links between each parent and its child tasks
- A link enforces a rule that says a parent task can only finish its work if all of its child tasks have finished
- marking a task as canceled does not stop the task. It simply informs the task that its results are no longer needed. 
- In fact, when a task is canceled, all subtasks that are decedents of that task will be automatically canceled too

#### Cooperative cancellation

- Cancelation in Swift is cooperative
- it means that if the task is in the middle of important transaction then it would be incorrect just to stop the task so we must to check for cancellation explicitly and wind down execution in whatever way is appropriate

```
func fetchThumbNails(ids: [String]) async throws {
    var thumbNails: [String: UIImage] = [:]
    
    for id in ids {
        try Task.checkCancellation()
        thumbNails[id] = try await fetchThumbNail(id: id)
    }
    return thumbNails
}
```

in this example, we will throw an error if task is canceled

Another example how to check if Task is canceled can be done in that way:

```
func fetchThumbNails(ids: [String]) async throws {
    var thumbNails: [String: UIImage] = [:]
    
    for id in ids {
        if Task.isCancelled { return true }
        thumbNails[id] = try await fetchThumbNail(id: id)
    }
    return thumbNails
}
```


### Group tasks

-  They offer more flexibility than async-let without giving up all of the nice properties of structured concurrency.
-  A task group is a form of structured concurrency that is designed to provide a dynamic amount of concurrency. 
-  Is preferred used when the amount of concurrency is not known statically because it depends on the number of IDs in the array.
- You can introduce a task group by calling the **withThrowingTaskGroup** function. This function gives you a scoped group object to create child tasks that are allowed to throw errors.
-  Tasks added to a group cannot outlive the scope of the block in which the group is defined. 
-  You create child tasks in a group by invoking its async method. Once added to a group, child tasks begin executing
-  You can use async-let within group tasks or create task groups within async-let tasks, and the levels of concurrency in the tree compose naturally.

Let's look at the example of creating a task group:

```
func fetchThumbNails(for ids: [String]) async throws -> [String: UIImage] {
    var thumbNails: [String: UIImage] = [:]
    try await withThrowingTaskGroup(of: Void.self) { group in
        for id in ids {
            group.addTask {
                thumbNails[id] = try await fetchThumbnail(id: id)
            }
        }
    }
    return thumbNails
}
```

but here in the snippet, we can see some issue: The problem is that we’re trying to insert a thumbnail into a single dictionary from each child task. This is a common mistake when increasing the amount of concurrency in your program. Data races are accidentally created.

This dictionary cannot handle more than one access at a time, and if two child tasks tried to insert thumbnails simultaneously, that could cause a crash or data corruption. In the past, you had to investigate those bugs yourself, but Swift provides static checking for it.

How to fix it?

 - In this case, I specified that each child task must return a tuple containing the String ID and UIImage for the thumbnail. Then, inside each child task, instead of writing to the dictionary directly, I have them return the key value tuple for the parent to process. The parent task can iterate through the results from each child task using the new for-await loop. The for-await loop obtains

 - The parent task can iterate through the results from each child task using the new for-await loop. The for-await loop obtains the results from the child tasks in order of completion. Because this loop runs sequentially, the parent task can safely add each key value pair to the dictionary. This is just one example of using the for-await

let's look on the example with the fix:
 
```
func fetchThumbnails(ids: [String]) async throws -> [String: UIImage] {
    
    var thumbnails: [String: UIImage] = [:]
    try await withThrowingTaskGroup(of: (String, UIImage).self) { group in
        for id in ids {
            group.addTask {
                return (id, try await fetchThumbnail(id: id))
            }
        }
        
        for try await (id, thumbnail) in group {
            thumbnails[id] = thumbnail
        }
        
    }
    
    return thumbnails
}
```

#### Summary for Structured taks

 -  Async-let and group tasks are the two kind of tasks that provide scoped structured tasks in Swift. 
 -   You can also manually cancel all tasks before exiting the block using the group’s cancelAll method.
 -   Remember that if you cancel a parent task then cancellation goes down the tree
 
## Unstructured tasks

- Swift also provides unstructured task APIs, which give you a lot more flexibility at the expense of needing a lot more manual management. There are a lot of situations where a task might not fall into a clear hierarchy.
- Alternatively, the lifetime you want for a task might not fit the confines of a single scope or even a single function
- tasks that run independently of a scope while still inheriting traits from that task’s originating context.
- task is **_unscoped._** Its lifetime is not bound by the scope of where it was launched. 
- The origin doesn’t even need to be async. We can create an unscoped task anywhere.
- must be manually canceled
- it inherits actor isolation and priority of the origin context

Let's look on the following example which shows us when potentially will be worth creating unstructured tasks:

```
@MainActor
class MyDelegate: UICollectionViewDelegate {
    func collectionView(_ view: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt item: IndexPath) {
        
        let ids = getThumbnailIDs(for: item)
        
        Task {
            let thumbnails = await fetchThumbnails(for: ids)
            display(thumbnails, in: cell)
        }
    }
}
```

so how to cancel an unscoped task ?
let's say that we have the following scenario:
we should also cancel that task if the item is scrolled out of view before the thumbnails are ready. 

```
@MainActor
class MyDelegate: UICollectionViewDelegate {
    func collectionView(_ view: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt item: IndexPath) {
        
        var thumbnailsTasks: [IndexPath: Task<Void, Never>] = [:]
        let ids = getThumbnailIDs(for: item)
        
        thumbnailsTasks[item] = Task {
            defer { thumbnailsTasks[item] = nil  }
            let thumbnails = await fetchThumbnails(for: ids)
            display(thumbnails, in: cell)
        }
    }
}
```




- Our delegate class is bound to the main actor, and the new task inherits that (so will be also run on the main actor), so they’ll never run together in parallel. We can safely access the stored properties of main actor-bound classes inside this task without worrying about data races.

### Detached tasks

- it gives us a lot of flexibility,
- Task can be detached (Task.detached(piority:.background), independent from originating context
-  Their lifetimes are not bound to their originating scope. 
- But detached tasks don’t pick anything else up from their originating scope either. 
- By default, they aren’t constrained to the same actor and don’t have to run at the same priority as where they were launched. 
- Detached tasks run independently with generic defaults for things like priority, but they can also be launched with optional parameters to control how and where the new task gets executed.

Let's look on the detached task example:

```
@MainActor
class MyDelegate: UICollectionViewDelegate {
    func collectionView(_ view: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt item: IndexPath) {
        
        var thumbnailsTasks: [IndexPath: Task<Void, Never>] = [:]
        let ids = getThumbnailIDs(for: item)
        
        thumbnailsTasks[item] = Task {
            defer { thumbnailsTasks[item] = nil  }
            let thumbnails = await fetchThumbnails(for: ids)
            
            Task.detached(priority: .background) {
                writeToLocalCache(thumbnails)
            }
            
            display(thumbnails, in: cell)
        }
    }
}
```

but what if should we do in the future if we have multiple background tasks we want to perform on our thumbnails? We could detach more background tasks, but we could also utilize structured concurrency inside of our detached task. We can combine all of the different kinds of tasks together to exploit each of their strengths.

```
@MainActor
class MyDelegate: UICollectionViewDelegate {
    func collectionView(_ view: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt item: IndexPath) {
        
        var thumbnailsTasks: [IndexPath: Task<Void, Never>] = [:]
        let ids = getThumbnailIDs(for: item)
        
        thumbnailsTasks[item] = Task {
            defer { thumbnailsTasks[item] = nil  }
            let thumbnails = await fetchThumbnails(for: ids)
            
            Task.detached(priority: .background) {
                withTaskGroup(of: Void.self) { g in
                    g.async {
                        writeToLocalCache(thumbnails)
                    }
                    g.async {
                        log()
                    }
                    g.async {
                        ...
                    }
                }
            }
            display(thumbnails, in: cell)
        }
    }
```

Instead of detaching an independent task for every background job, we can set up a task group and spawn each background job as a child task into that group. There are a number of benefits of doing so. If we do need to cancel the background task in the future, using a task group means we can cancel all of the child tasks just by canceling that top-level detached task. 

Benefits

- That cancellation will then propagate to the child tasks automatically, and we don’t need to keep track of an array of handles. 
- Furthermore, child tasks automatically inherit the priority of their parent. To keep all of this work in the background, we only need to background the detached task, and that will automatically propagate to all of its child tasks, so we don’t need to worry about forgetting to transitively set background priority and accidentally starving UI work.
 
#### Summary

|   | Launched by | Launchable from  | Lifetime  | Cancelletaion  | Inherits from origin  |
|---|---|---|---|---|---|
| Async let task  | async let x  | async function  |  scoped to statement |  automatic |  priority, task local values |
| Group tasks | group.async  |  withTaskGroup | scoped to task group  |  automatic | priority, task local values  |
| Unstructured tasks  | Task  | anywhere  |  unscoped | via Task  | priority, task local values, actor  |
| Detached tasks  | Task.detached  | anywhere  | unscoped  | via Task  |  nothing |