Task group is great when you don't know the number of concurrent tasks that you'd like to execute. It allows for running multiple tasks concurrently with nice structured code.

For example we can use Task Group to fetch thumbnails concurrently:

```
    private func fetchThumbnails(from apody: [ApodModel]) async throws -> [String: UIImage] {
        try await withThrowingTaskGroup(of: (String, UIImage).self) { group in
            var thumbnails: [String: UIImage] = [:]
            for apod in apody.filter({ $0.media_type == .image }) {
                group.addTask(priority: .background) {
                    (apod.url, try await self.fetchImage(url: apod.url))
                }
            }
            for try await (url, image) in group {
                thumbnails[url] = image
            }
            return thumbnails
        }
    }
```

Once added to a group (by `group.addTask()`), child tasks are being executed immediately and in any order.

### Use AsyncSequence to deliver thumbnails one after another.

In our case the above code wasn't good enough. Indeed it fetches multiple icons concurrently, however the result is still delivered as a complete `thumbnails: [String: UIImage]` dictionary.

Our goal was to receive each thumbnail one by one asynchronously.

So once again the `AsyncSequence` usage seemed to be a good candidate.

This is what we came up with:

```
public actor ThumbnailDataSource {
    private let imageCache: ImageCache
...
    public typealias ThumbnailsStream = AsyncStream<(String, UIImage)>

    public nonisolated func getThumbnails(models: [ApodModel]) -> ThumbnailsStream {
        return ThumbnailsStream { continuation in
            Task {
                try await fetchThumbnails(from: models, continuation: continuation)
            }
        }
    }

    private func fetchThumbnails(
        from apody: [ApodModel],
        continuation: ThumbnailsStream.Continuation
    ) async throws {
        try await withThrowingTaskGroup(of: (String, UIImage).self) { group in
            for apod in apody.filter({ $0.media_type == .image }) {
                group.addTask(priority: .background) {
                    (apod.url, try await self.fetchImage(url: apod.url))
                }
            }
            for try await data in group {
                continuation.yield(data)
            }
            continuation.finish()
        }
    }
}
```
`func getThumbnails(models: [ApodModel]) -> ThumbnailsStream` creates the AsyncStream, which triggers a thumbnails fetching function. We could pass the `Continuation` object which would allow us later on to inform about the changes in the stream.

`nonisolated` prefix gave a possibility for the function to synchronously create the `AsyncStream` in the code. Since we do not modify anything in terms of the actors properties in the function, it is safe to expose the method as `nonisolated`.

In the `func fetchThumbnails` we added the `continuation` property and we `yield` the result every time the group task finishes its fetch. Once all of the data are fetched, we call `conitnuation.finish()` to finish the iteration from the parent perspective.

Instead of returning the dictionary of thumbnails, we yield a `(String, UIImage)` tuple to the parent one by one.

So the binding in the parent view would look like this:
```
@MainActor class ApodViewModel: ObservableObject {
 
@Published var thumbnails: [String: UIImage] = [:]

private let dataSource: ThumbnailDataSource
...
    public func fetchThumbnails(for models: [ApodModel]) async {
        for await (url, image) in dataSource.getThumbnails(models: models) {
            thumbnails[url] = image
        }
    }
...
```
