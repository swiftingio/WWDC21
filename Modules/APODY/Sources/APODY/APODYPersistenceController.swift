//
//  Persistence.swift
//  WWDC21
//
//  Created by mazurkk3 on 14/02/2022.
//

import APODYModel
import CoreData

public struct APODYPersistenceController {
    public static let shared = APODYPersistenceController()

    public static var preview: APODYPersistenceController = {
        let result = APODYPersistenceController(inMemory: true)
        let viewContext = result.container.viewContext
        for _ in 0 ..< 2 {
            let newApod = Apod(context: viewContext)
        }

        do {
            try viewContext.save()
        } catch {
            // Replace this implementation with code to handle the error appropriately.
            // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
        return result
    }()

    public let container: NSPersistentContainer

    init(inMemory: Bool = false) {
        let dbName = "WWDC21"
        guard let modelURL = Bundle.apodyModule.url(forResource: dbName, withExtension: "momd") else {
            fatalError("Error loading model from bundle")
        }

        guard let mom = NSManagedObjectModel(contentsOf: modelURL) else {
            fatalError("Error initializing mom from: \(modelURL)")
        }

        container = NSPersistentContainer(name: "WWDC21", managedObjectModel: mom)
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        container.loadPersistentStores(completionHandler: { _, error in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.

                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
    }
}

public extension Bundle {
    static var apodyModel: Bundle {
        module
    }
}
