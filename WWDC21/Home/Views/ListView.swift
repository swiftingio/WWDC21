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
    @Published var presentedViewModel: APODModel?
    @Published var image: UIImage?
}

struct ContentView: View {
    @ObservedObject var viewModel: HomeViewModel
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject var presentedObject: PresentedView

    @Namespace var namespace
    @State private var showDetails: Bool = false

    @SectionedFetchRequest(
        sectionIdentifier: \.date,
        sortDescriptors: [SortDescriptor(\.title, order: .reverse)]
    )
    public var apods: SectionedFetchResults<String, Apod>

    var body: some View {
        ZStack {
            NavigationView {
                ZStack {
                    List {
                        ForEach(apods) { section in
                            Section(header: Text(section.id)) {
                                ForEach(section) { apod in
                                    ApodView(
                                        namespace: namespace,
                                        viewModel: ApodViewModel(apod: APODModel(coreDataApod: apod),
                                                                 networking: viewModel.networking,
                                                                 imageCache: viewModel.imageCache),
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
            if showDetails, let apod = presentedObject.presentedViewModel {
                DetailsView(
                    viewModel: ApodViewModel(apod: apod,
                                             networking: viewModel.networking,
                                             imageCache: viewModel.imageCache),
                    showDetails: $showDetails,
                    image: presentedObject.image,
                    namespace: namespace
                )
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
