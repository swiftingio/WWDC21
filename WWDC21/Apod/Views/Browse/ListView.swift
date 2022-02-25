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

    @State private var selectedSort = ApodSort.default

    @SectionedFetchRequest(
        sectionIdentifier: ApodSort.default.section,
        sortDescriptors: ApodSort.default.descriptors
    )
    public var apods: SectionedFetchResults<String, Apod>

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

    // MARK: Views

    var body: some View {
        ZStack {
            NavigationView {
                ZStack {
                    if apods.isEmpty {
                        EmptyView()
                    } else {
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
                        .buttonStyle(PlainButtonStyle())
                        .toolbar {
                            makeToolbarGroup()
                        }
                        .refreshable {
                            try? await viewModel.refreshData()
                        }
                        .task {
                            let sections = apods.flatMap { $0 }
                            let result = sections.map { ApodModel(coreDataApod: $0) }
                            await viewModel.fetchThumbnails(for: result)
                        }
                    }
                }
                .searchable(text: searchQuery)
                .task {
                    try? await viewModel.refreshData()
                }
            }
            .accentColor(.white)
        }
    }

    @ViewBuilder
    private func makeApodCell(model: ApodModel) -> some View {
        ApodView(
            model: model,
            image: $viewModel.thumbnails[model.url],
            persistence: viewModel.persistence
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
