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

class PresentedView: ObservableObject {
    @Published var model: APODModel?
    @Published var image: UIImage?
}

struct ListView: View {
    @ObservedObject var viewModel: HomeViewModel
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject var presentedObject: PresentedView

    @Namespace var namespace
    @State private var showDetails: Bool = false

    @SectionedFetchRequest(
        sectionIdentifier: ApodSort.default.section,
        sortDescriptors: ApodSort.default.descriptors
    )
    public var apods: SectionedFetchResults<String, Apod>
    @State private var selectedSort = ApodSort.default

    @State private var searchText: String = ""
    var query: Binding<String> {
        Binding {
            searchText
        } set: { newValue in
            searchText = newValue
            apods.nsPredicate = newValue.isEmpty ? nil : NSPredicate(format: "title CONTAINS %@", newValue)
        }
    }

    var body: some View {
        ZStack {
            NavigationView {
                ZStack {
                    List {
                        ForEach(apods) { section in
                            Section(header: Text(section.id)) {
                                ForEach(section) { apod in
                                    let model = APODModel(coreDataApod: apod)
                                    ApodView(
                                        namespace: namespace,
                                        model: model,
                                        image: viewModel.thumbnails[model.url],
                                        persistence: viewModel.persistence,
                                        showDetails: $showDetails
                                    )
                                    .listRowBackground(Color.clear)
                                    .listRowSeparator(.hidden)
                                }
                            }
                        }
                        .navigationTitle("APOD")
                        .listStyle(.plain)
                    }
                    .searchable(text: query)
                    .toolbar {
                        ToolbarItemGroup(placement: .navigationBarTrailing) {
                            SortSelectionView(
                                selectedSortItem: $selectedSort,
                                sorts: ApodSort.sorts
                            )
                            .onChange(of: selectedSort) { _ in
                                let request = apods
                                request.sortDescriptors = selectedSort.descriptors
                                request.sectionIdentifier = selectedSort.section
                            }
                        }
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
            .colorScheme(.dark)

            if showDetails, let apod = presentedObject.model {
                DetailsView(
                    model: apod,
                    showDetails: $showDetails,
                    image: presentedObject.image,
                    namespace: namespace
                )
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ListView(viewModel: HomeViewModel(persistence: DefaultApodStorage(container: APODYPersistenceController.preview.container), dataSource: DefaultApodPersistenceDataSource(context: APODYPersistenceController.preview.container.newBackgroundContext())))
            .environment(\.managedObjectContext, APODYPersistenceController.preview.container.viewContext)
    }
}
