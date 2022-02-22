import SwiftUI

struct FormView: View {
    private enum Field: Int, Hashable, CaseIterable {
        case title, description
    }

    @FocusState private var focusField: Field?

    @State var title: String = ""
    @State var description: String = ""

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Feedback")) {
                    TextField("Title", text: $title)
                        .focused($focusField, equals: .title)
                    TextField("Description", text: $description)
                        .focused($focusField, equals: .description)
                }
                Section(header: Text("ABOUT")) {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.0.0")
                    }
                }
            }
            .navigationTitle("Settings")
            .toolbar {
                ToolbarItemGroup(placement: .keyboard) {
                    Button(action: selectPreviousField) {
                        Label("Previous", systemImage: "chevron.up")
                    }.disabled(!canSelectPreviousField())

                    Button(action: selectNextField) {
                        Label("Next", systemImage: "chevron.down")
                    }
                    .disabled(!canSelectNextField())
                }
            }
            .onSubmit {
                if focusField == .title {
                    focusField = .description
                } else {
                    endEdititing()
                }
            }
            .submitLabel(.done)
        }
    }

    private func selectPreviousField() {
        focusField = focusField.map {
            Field(rawValue: $0.rawValue - 1)!
        }
    }

    private func selectNextField() {
        focusField = focusField.map {
            Field(rawValue: $0.rawValue + 1)!
        }
    }

    private func canSelectPreviousField() -> Bool {
        if let currentFocusState = focusField {
            return currentFocusState.rawValue > 0
        } else {
            return false
        }
    }

    private func canSelectNextField() -> Bool {
        if let currentFocusState = focusField {
            return currentFocusState.rawValue < Field.allCases.count - 1
        } else {
            return false
        }
    }

    private func endEdititing() {
        focusField = nil
    }
}
