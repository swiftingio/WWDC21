## List of new improvements

* `AsyncImage` - new SwiftUI View which allows for fetching the image asynchronously.
* New `.refreshable` modifier to introduce pull to refresh.
* New `.task` modifier you can attach async task onto the view lifecycle.
* Passing binding into the array of elements and receive binding into each elements that we can use within the closure.

```
struct DirectionsList: View {
   @Binding var directions: [Direction]
   
   var body: some View {
       List($directions) { $direction in
          Label {
              TextField("Instructions", text: $direction.text)
          } icon: {
              DirectionsIcon(direction)
          }
       }
   }
}
```

* `.listRowSeparator` modifier - allows for eg. hiding the row separator.
* custom swipe actions on the List using `.swipeActions` modifier.
* new `.listStyle` added. eg. `.inset` style allows for alternating the row background.
* `searchable` modifier allows to introduce search bar function to the Views. Eg. can be used on the `NavigationView`. (Craft search experiences in SwiftUI - WWDC21 talk)

## Advanced graphics

* Automatically selects the proper variant of SF symbol (fill etc.) based on the context of use in SwiftUI.
* `Canvas` View which allows to draw specific view.
* `.accessibilityChildren` to eg. speak each element as user navigate through.
* `TimelineView` which allows to redraw the contnent it contains at scheduled points in time.
* `.privacy` (sensitive) modifier to hide some sensitive data displayed or not based on the display state.
* New materials to use eg. `.background(.ultraThinMaterial, in: RoundedRectangle())`.

## Text and keyboard

* Text can contain Markdown and support it eg. `Text("**Text**")`
* `.textSelection` modifier to enabled or disable text selection.
* `.onSubmit` modifier to catch the "submit" action from the user and react on it.
* `@FocusState` property wrapper and `.focused` modifier to allow for switch the focus to the view.


## Buttons

* Bordered buttons style.
* `.controlSize` - large modifier allows to get large rounded buttons automatically. (use `controlProminence` modifier to set color variation).
* `ControlGroup` to group the buttons together.