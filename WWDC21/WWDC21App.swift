//
//  WWDC21App.swift
//  WWDC21
//
//  Created by mazurkk3 on 14/02/2022.
//

import APODY
import SwiftUI

@main
struct WWDC21App: App {
    let persistenceController = APODYPersistenceController.shared
    let presentedObject = PresentedView()

    var body: some Scene {
        WindowGroup {
            TabView {
                ContentView(viewModel: HomeViewModel(
                    persistence: DefaultApodStorage(
                        container: persistenceController.container
                    ),
                    dataSource: DefaultApodPersistenceDataSource(
                        context: persistenceController.container.newBackgroundContext())
                ))
                .tabItem {
                    Image(systemName: "globe.europe.africa")
                    Text("Browse")
                }

                FavoritesView()
                    .tabItem {
                        Image(systemName: "star")
                        Text("Favorites")
                    }
            }
            .colorScheme(.dark)
            .font(.headline)
            .environment(\.managedObjectContext, persistenceController.container.viewContext)
            .environmentObject(presentedObject)
        }
    }
}
