#### Old approach with completion handlers

```
 func fetchPhoto(url: URL, completionHandler: @escaping (UIImage?, Error?) -> Void) {
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            if let error = error {
                completionHandler(nil, error)
            }
            if let data = data, let httpResponse = response as? HTTPURLResponse,
               httpResponse.statusCode == 200 {
                DispatchQueue.main.async {
                    completionHandler(UIImage(data: data), nil)
                }
            } else {
                completionHandler(nil, Error.invalidServerResponse)
            }
        }
        task.resume()
    }
```


#### New async await approach:
```
func fetchPhoto(url: URL) async throws -> UIImage {
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
                  throw Error.invalidServerResponse
              }
        guard let image = UIImage(data: data) else {
            throw Error.unsupportedImage
        }
        
        return image
    }
```

#### Example from APOD app.

```
 public func fetchApods(count: Int) async throws -> [APODModel] {
        let endpoint = ApodEndpoint.apody

        let parameters = [
            ApodParameter.count("\(count)"),
            ApodParameter.apiKey,
        ]
        let url = try urlBuilder.build(endpoint: endpoint, parameters: parameters)
        let (data, response) = try await URLSession.shared.data(from: url)

        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw ApodNetworkingError.invalidServerResponse
        }

        let parsedData = try decoder.decode([APODModel].self, from: data)
        return parsedData
    }
```

### Receiving data in chunks using `AsyncSequence`.

In order to receive asynchronously data in chunks, there is a possibility to use new property  `URLSession.bytes` which is an `AsyncSequence`. Then using `for-try-await-loop` iterate over the chunks.

```
  func receiveData() async throws {
        let (bytes, response) = try await URLSession.shared.bytes(from: Self.eventStreamURL)
        
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw Error.invalidServerResponse
        }
        
        for try await line in bytes.lines {
            let photoMetadata = try JSONDecoder().decode(PhotoMetaData.self, from: Data(line.utf8))
            await updateFavoriteCount(with: photoMetadata)
        }
    }
``` 