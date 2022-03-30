## Continutaion

### General

Is a pattern to rewrite the callbacks to async/await manner.

### About continutaion API 

We have two options

- [withCheckedThrowingContinuation](https://developer.apple.com/documentation/swift/3814989-withcheckedthrowingcontinuation) we use this option if our function which we are refactoring is returning an error along with data
- [withCheckedContinuation](https://developer.apple.com/documentation/swift/3814988-withcheckedcontinuation) if our previous function just returns the result (without an error)

### Example

Let's look at the following example where we would like to fetch all pedometer data from the core motion sensor with the usage of the callback :

```
func fetchPedometerData(from: Date, to: Date, completion: @escaping (CMPedometerData?, Error?) -> Void) {
        pedometer.queryPedometerData(from: from, to: to) { data, error  in
            if let error = error {
                completion(nil, error)
            } else {
                completion(data, nil)
            }
        }
    }
```

Rewritten function to async version would look like this:

```
    func fetchPedometerData() async throws -> CMPedometerData? {
        typealias LocationContinuation = CheckedContinuation<[CLLocation], Never>
        return try await withCheckedThrowingContinuation { continuation in
            pedometer.queryPedometerData(from: Date() as Date, to: Date()) { data, error  in
                if let error = error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume(returning: data)
                }
            }
        }
    }
```

Please take attention to the following steps during the refactor:

- in the async version we need to return all the time values from the signature of the function
- we have to add **async** to the signature of the function 
- if we would like to also support error handling then we need to add **throws** in the signature of the function
- in the body, we use **withCheckedThrowingContinuation** or **withCheckedContinuation** API depending if we refactored function has error handling

And now when we would like to call the new async function we do it in the following way:

```
let (data, error) = try await fetchPedometerData() 
```

#### Resources

To have more examples please take a look on below snippets which were shown during WWDC 21 on the [Meet async/await in swift](https://developer.apple.com/videos/play/wwdc2021/10132/) session:

- [withCheckedThrowingContinuation](https://code.roche.com/mazurkk3/wwdc21/-/snippets/670)
- [withCheckedContinuation](https://code.roche.com/mazurkk3/wwdc21/-/snippets/671)