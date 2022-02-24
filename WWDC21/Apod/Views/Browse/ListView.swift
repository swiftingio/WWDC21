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

struct ListView: View {
    @Environment(\.managedObjectContext) private var viewContext

    @Namespace var namespace
    @ObservedObject var viewModel: ApodViewModel

    // MARK: Core data properties

    @SectionedFetchRequest(
        sectionIdentifier: ApodSort.default.section,
        sortDescriptors: ApodSort.default.descriptors
    )
    public var apods: SectionedFetchResults<String, Apod>
    @State private var selectedSort = ApodSort.default

    // MARK: Search properties

    @State private var searchText: String = ""
    private var searchQuery: Binding<String> {
        Binding {
            searchText
        } set: { newValue in
            searchText = newValue
            apods.nsPredicate = newValue.isEmpty ? nil : NSPredicate(format: "title CONTAINS %@", newValue)
        }
    }

    // MARK: Details view - related state

    @State private var showDetails: Bool = false
    @State private var presentedModel: ApodModel?
    @State private var presentedImage: UIImage?

    // MARK: Views

    var body: some View {
        ZStack {
            NavigationView {
                ZStack {
                    List {
                        ForEach(apods) { section in
                            Section(header: Text(section.id)) {
                                ForEach(section) { apod in
                                    let model = ApodModel(coreDataApod: apod)
                                    makeApodCell(model: model)
                                }
                            }
                        }
                        .navigationTitle("APOD")
                        .listStyle(.plain)
                    }
                    .searchable(text: searchQuery)
                    .toolbar {
                        makeToolbarGroup()
                    }
                }
                .refreshable {
                    try? await viewModel.refreshData()
                }
                .task {
                    try? await viewModel.refreshData()
                }
            }

            if showDetails, let apod = presentedModel {
                DetailsView(
                    model: apod,
                    showDetails: $showDetails,
                    presentedImage: $presentedImage,
                    image: presentedImage,
                    namespace: namespace
                )
            }
        }
    }

    @ViewBuilder
    private func makeApodCell(model: ApodModel) -> some View {
        ApodView(
            namespace: namespace,
            model: model,
            image: viewModel.thumbnails[model.url],
            persistence: viewModel.persistence,
            showDetails: $showDetails,
            presentedModel: $presentedModel,
            presentedImage: $presentedImage
        )
        .listRowBackground(Color.clear)
        .listRowSeparator(.hidden)
    }

    @ToolbarContentBuilder
    private func makeToolbarGroup() -> some ToolbarContent {
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

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ListView(viewModel: ApodViewModel(persistence: DefaultApodStorage(container: APODYPersistenceController.preview.container), dataSource: DefaultApodPersistenceDataSource(context: APODYPersistenceController.preview.container.newBackgroundContext())))
            .environment(\.managedObjectContext, APODYPersistenceController.preview.container.viewContext)
    }
}
