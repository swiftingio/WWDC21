//
//  WWDC21App.swift
//  WWDC21
//
//  Created by mazurkk3 on 14/02/2022.
//

import APODY
import CoreData
import SwiftUI

@main
struct WWDC21App: App {
    let persistenceController = APODYPersistenceController.shared
    let context: NSManagedObjectContext = {
        APODYPersistenceController.shared.container.viewContext
    }()

    let networking = DefaultApodNetworking()
    let imageCache = ImageCache()

    var body: some Scene {
        WindowGroup {
            ApodyTabView(viewModel: ApodViewModel(
                networking: networking,
                persistence: DefaultApodStorage(
                    container: persistenceController.container
                ),
                dataSource: ThumbnailDataSource(
                    imageCache: imageCache,
                    networking: networking
                )
            ))
            .environment(\.managedObjectContext, context)
        }
    }
}
