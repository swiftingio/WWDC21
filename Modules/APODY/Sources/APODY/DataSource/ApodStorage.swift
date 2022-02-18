import APODYModel
import CoreData
import Foundation

public protocol ApodPersistence {
    var container: NSPersistentContainer { get set }

    func save(apods: [APODModel]) async throws
    func purge() async throws
}

public class DefaultApodStorage: ApodPersistence {
    public var container: NSPersistentContainer

    public init(container: NSPersistentContainer) {
        self.container = container
    }

    public func save(apods: [APODModel]) async throws {
        let context = container.newBackgroundContext()
        context.automaticallyMergesChangesFromParent = true
        context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        try await context.perform {
            apods.forEach { apod in
                _ = Apod(model: apod, context: context)
            }
            try context.save()
        }
    }

    public func purge() async throws {
        let context = container.newBackgroundContext()
        try await context.perform {
            let request: NSFetchRequest<NSFetchRequestResult> = Apod.fetchRequest()
            let deleteRequest = NSBatchDeleteRequest(fetchRequest: request)
            try context.execute(deleteRequest)
        }
    }
}
