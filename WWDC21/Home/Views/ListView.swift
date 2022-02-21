//
//  ContentView.swift
//  WWDC21
//
//  Created by mazurkk3 on 14/02/2022.
//

import APODY
import CoreData
import SwiftUI

class PresentedView: ObservableObject {
    @Published var presentedViewModel: ApodViewModel?
}

struct ContentView: View {
    @ObservedObject var viewModel: HomeViewModel
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject var presentedObject: PresentedView

    @Namespace var namespace
    @State private var showDetails: Bool = false

    var body: some View {
        ZStack {
            NavigationView {
                ZStack {
                    List(viewModel.objects, id: \.url) { apod in
                        ApodView(namespace: namespace, viewModel: apod, showDetails: $showDetails)
                            .listRowSeparator(.hidden)
                    }
                    .navigationTitle("APOD")
                    .listStyle(.plain)
                }
            }
            .refreshable {
                do {
                    try await viewModel.refreshData()
                } catch {
                    print("\(error.localizedDescription)")
                }
            }
            .task {
                do {
                    try await viewModel.refreshData()
                } catch {
                    print("\(error.localizedDescription)")
                }
            }
        }
    }
}

private let itemFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    formatter.timeStyle = .medium
    return formatter
}()

struct SheetView: View {
    @Environment(\.dismiss) var dismiss

    @StateObject var viewModel: ApodViewModel

    var body: some View {
        Group {
            if let image = viewModel.image {
                ScrollView {
                    Image(uiImage: image)
                }
            } else {
                ProgressView()
            }
        }
        .onTapGesture {
            dismiss()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(viewModel: HomeViewModel(persistence: DefaultApodStorage(container: APODYPersistenceController.preview.container), dataSource: DefaultApodPersistenceDataSource(context: APODYPersistenceController.preview.container.newBackgroundContext())))
            .environment(\.managedObjectContext, APODYPersistenceController.preview.container.viewContext)
    }
}
