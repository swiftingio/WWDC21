
### General about Sendable

- A Sendable type is one whose values can be shared across different actors
- Sendable types protect code from data races so when we have conformance to this 
- is a protocol
- every actor type implicitly conforms to the Sendable protocol, so we don't need to write it when we create our own actors:

```
actor DataSource {
  ...
}
```

### Sendable vs diffrent types

- Value types are Sendable because each copy is independent
- Actor types are Sendable because they synchronize access to their mutable state.
- Classes can be Sendable, but only if they are carefully implemented. (immutable classes)
- Functions aren't necessarily Sendable, so there is a new kind of function type for functions that are safe to pass across actors.
- Functions themselves can be Sendable, meaning that it is safe to pass the function value across actors. This is particularly important for closures where it restricts what the closure can do to help prevent data races.
- Sendable function types are used to indicate where concurrent execution can occur, and therefore prevent data races.
- Sendable types and closures help maintain actor isolation by checking that mutable state isn't shared across actors, and cannot be modified concurrently.

### Sendable and class

- classes are generally are not thread-safe because they are reference types.
- And to indicate that our class is thread-safe we can conform to the Sandable protocol, then if the class doesn't contain any variables then the compiler will allow us to compile the code and we will agree with us that the class is thread-safe (immutable reference types).

```
final class Car: Sendable {
 let seats: Int
...
}
```

- The second option is internally synchronized reference types. If the class contains some variables which can be in the future potential place for data races then we have to add "@unchecked". This indicates that the type can safely be passed across concurrency domains, but requires the author of the type to ensure that this is safe:

```
final class Car: @unchecked Sendable {
    private var speed: Double = 0

    func drive(_ speed: String) {
        DispatchQueue.userMutatingLock.sync {
            self.speed = speed
        }
    }
}

```
