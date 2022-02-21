//
//  ContentView.swift
//  WWDC21
//
//  Created by mazurkk3 on 14/02/2022.
//

import APODY
import APODYModel
import CoreData
import SwiftUI

struct ContentView: View {
    @ObservedObject var viewModel: HomeViewModel
    @Environment(\.managedObjectContext) private var viewContext

    @State private var showingSheet: Bool = false

    @SectionedFetchRequest(
        sectionIdentifier: \.date,
        sortDescriptors: [SortDescriptor(\.title, order: .reverse)]
    )
    public var apods: SectionedFetchResults<String, Apod>

    var body: some View {
        NavigationView {
            ZStack {
                List {
                    ForEach(apods) { section in
                        Section(header: Text(section.id)) {
                            ForEach(section) { apod in
                                Text(apod.title)
                                ApodView(viewModel: ApodViewModel(apod: APODModel(coreDataApod: apod), networking: viewModel.networking, imageCache: viewModel.imageCache))
                                    .listRowSeparator(.hidden)
                            }
                        }
                    }
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
