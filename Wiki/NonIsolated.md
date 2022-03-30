### General about nonisolated

- explicit way to give clients the freedom to synchronously access immutable actor state via the nonisolated keyword
- Nonisolated means that this method is treated as being outside the actor, even though it is, syntactically, described on the actor.
- Because nonisolated methods are treated as being outside the actor, they cannot reference mutable state on the actor.

```
public actor ThumbnailDataSource {
...
public nonisolated func getThumbnails(models: [ApodModel]) -> AsyncStream<[String: UIImage]> {
        return AsyncStream<[String: UIImage]> { [weak self] continuation in
            guard let self = self else { return }
            Task {
                try await withThrowingTaskGroup(of: (String, UIImage).self) { group in
                    var thumbnails: [String: UIImage] = [:]
                    for model in models.filter({ $0.media_type == .image }) {
                        group.addTask(priority: .background) {
                            (model.url, try await self.fetchImage(url: model.url))
                        }
                    }
                    for try await (url, image) in group {
                        thumbnails[url] = image
                        continuation.yield(thumbnails)
                    }
                    continuation.finish()
                }
            }
        }
}
```

here **getThumbNails** function can only refer to non-isolated data on the actor. An attempt to refer to any actor-isolated declaration will produce an error or require asynchronous access, as appropriate:

```
error: actor-isolated property 'balance' can not be referenced on non-isolated parameter 'self'
```

having this we can invoke this function from other place of application without using await keyword:

```
let thumbnails = dataSource.getThumbnails(models: models) 
```