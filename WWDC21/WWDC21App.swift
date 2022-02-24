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

    var body: some Scene {
        WindowGroup {
            ApodyTabView(viewModel: ApodViewModel(
                persistence: DefaultApodStorage(
                    container: persistenceController.container
                ),
                dataSource: DefaultApodPersistenceDataSource(
                    context: persistenceController.container.newBackgroundContext())
            ))
            .environment(\.managedObjectContext, context)
        }
    }
}
