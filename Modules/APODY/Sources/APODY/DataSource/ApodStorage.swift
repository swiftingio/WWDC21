import APODYModel
import CoreData
import Foundation

public protocol ApodPersistence: Sendable {
    func save(apods: [ApodModel]) async throws
    func toggleFavorite(apod: ApodModel) async throws
    func purge() async throws
}

enum StorageError: Error {
    case noElements
}

public actor DefaultApodStorage: ApodPersistence {
    public var container: NSPersistentContainer

    public init(container: NSPersistentContainer) {
        self.container = container
    }

    public func save(apods: [ApodModel]) async throws {
        assert(!Thread.isMainThread)
        let context = container.newBackgroundContext()
        context.automaticallyMergesChangesFromParent = true
        context.mergePolicy = NSMergeByPropertyStoreTrumpMergePolicy

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

    public func toggleFavorite(apod: ApodModel) async throws {
        assert(!Thread.isMainThread)
        let context = container.newBackgroundContext()
        context.automaticallyMergesChangesFromParent = true
        context.mergePolicy = NSMergeByPropertyStoreTrumpMergePolicy

        try await context.perform {
            let request: NSFetchRequest<Apod> = Apod.fetchRequest()
            request.fetchLimit = 1
            request.predicate = NSPredicate(format: "url = %@", apod.url)
            guard let result = try context.fetch(request).first else {
                throw StorageError.noElements
            }
            let isFavorite = result.favorite.boolValue
            result.favorite = NSNumber(booleanLiteral: !isFavorite)
            try context.save()
        }
    }
}
