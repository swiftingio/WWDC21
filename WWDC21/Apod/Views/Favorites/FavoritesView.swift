//
//  Favorites.swift
//  WWDC21
//
//  Created by mazurkk3 on 22/02/2022.
//

import APODY
import APODYModel
import CoreData
import Foundation
import SwiftUI

struct FavoritesView: View {
    @Namespace var favoritesNamespace
    @ObservedObject var viewModel: ApodViewModel

    // MARK: Core data properties

    @FetchRequest(
        entity: Apod.entity(),
        sortDescriptors: [
            NSSortDescriptor(keyPath: \Apod.date, ascending: false),
        ],
        predicate: NSPredicate(format: "favorite == %@", NSNumber(value: true))
    ) var apods: FetchedResults<Apod>

    // MARK: Details View properties

    @State private var showDetails: Bool = false
    @State private var presentedModel: ApodModel?
    @State private var presentedImage: UIImage?

    // MARK: Views

    var body: some View {
        ZStack {
            NavigationView {
                ZStack {
                    if apods.isEmpty {
                        FavoritesEmptyView()
                    } else {
                        List {
                            ForEach(apods) { apod in
                                let model = ApodModel(coreDataApod: apod)

                                ApodView(
                                    namespace: favoritesNamespace,
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
                            .navigationTitle("Favorites")
                            .listStyle(.plain)
                        }
                    }
                }
                .animation(.default)
            }

            if showDetails, let apod = presentedModel {
                DetailsView(
                    model: apod,
                    showDetails: $showDetails,
                    presentedImage: $presentedImage,
                    image: presentedImage,
                    namespace: favoritesNamespace
                )
            }
        }
    }

    @ViewBuilder
    private func makeApodCell() -> some View {}
}
