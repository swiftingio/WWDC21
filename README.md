# WWDC21

### Concurrency & SwiftUI
 
The goal of the research was to investigate how the new API introduced in WWDC21 works in an example - async/await, structured concurrency + what's new in SwiftUI. 

The application is based on the NASA API which allows for displaying the APOD (Astronomic picture of the Day) in a SwiftUI List, which you can also add to locally stored Favorites.

<p float="left">
<img width="300" alt="Zrzut ekranu 2021-12-17 o 09 53 06" src="https://raw.githubusercontent.com/swiftingio/WWDC21/main/Images/list.png">
<img width="300" alt="Zrzut ekranu 2021-12-17 o 09 53 06" src="https://raw.githubusercontent.com/swiftingio/WWDC21/main/Images/details.png">
</p>

### Authors

Bartłomiej Woronin,	contact: [email](mailto:bartlomiej.woronin@gmail.com), [Twitter](https://twitter.com/BWoronin).

Kacper Mazurkiewicz,	contact: [email](mailto:kacper.mazurk@gmail.com), [Twitter](https://twitter.com/juniortjt1).

### Project information

- 100% Swift.
- No third party-library used.
- SwiftUI used for layout.
- 100% GCD free.
- Core Data used for favorites persistance.


### Get started 

1. Clone the repository.
2. Launch `WWDC21.xcodeproj` using Xcode.
3. Build & Run.

### Documentation

1. [AsyncSequence](./Wiki/AsyncSequence.md)
2. [Actors](./Wiki/Actors.md)
3. [URLSession](./Wiki/URLSession.md)
4. [Core Data](./Wiki/CoreData.md)
5. [Task Group](./Wiki/Task-Group/md)
6. [TimelineView](./Wiki/TimelineView.md)
7. [What's new in SwiftUI](./Wiki/What's-new-in-SwiftUI.md)
8. [Continuation](./Wiki/Continuation.md)
9. [Nonisolated](.Wiki/NonIsolated.md)