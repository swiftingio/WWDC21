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
    @ObservedObject var viewModel: HomeViewModel
    @EnvironmentObject var presentedObject: PresentedView

    @Namespace var favoritesNamespace
    @State private var showDetails: Bool = false

    @FetchRequest(
        entity: Apod.entity(),
        sortDescriptors: [
            NSSortDescriptor(keyPath: \Apod.date, ascending: true),
        ],
        predicate: NSPredicate(format: "favorite == %@", NSNumber(value: true))
    ) var apods: FetchedResults<Apod>

    var body: some View {
        ZStack {
            NavigationView {
                ZStack {
                    if apods.isEmpty {
                        EmptyView()
                    } else {
                        List {
                            ForEach(apods) { apod in
                                let model = APODModel(coreDataApod: apod)
                                ApodView(
                                    namespace: favoritesNamespace,
                                    model: model,
                                    image: viewModel.thumbnails[model.url],
                                    persistence: viewModel.persistence,
                                    showDetails: $showDetails
                                )
                                .listRowBackground(Color.clear)
                                .listRowSeparator(.hidden)
                            }

                            .navigationTitle("Favorites")
                            .listStyle(.plain)
                        }
                    }
                }
            }

            if showDetails, let apod = presentedObject.model {
                DetailsView(
                    model: apod,
                    showDetails: $showDetails,
                    image: presentedObject.image,
                    namespace: favoritesNamespace
                )
            }
        }
    }
}
