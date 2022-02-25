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
    @ObservedObject var viewModel: ApodViewModel

    // MARK: Core data properties

    @FetchRequest(
        entity: Apod.entity(),
        sortDescriptors: [
            NSSortDescriptor(keyPath: \Apod.date, ascending: false),
        ],
        predicate: NSPredicate(format: "favorite == %@", NSNumber(value: true))
    ) var apods: FetchedResults<Apod>

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
                                makeApodCell(model: model)
                            }
                            .navigationTitle("Favorites")
                            .listStyle(.plain)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .animation(.default)
            }
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
}
