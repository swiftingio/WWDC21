//
//  ApodPersistenceDataSource.swift
//  WWDC21
//
//  Created by mazurkk3 on 17/02/2022.
//

import APODYModel
import Combine
import CoreData
import Foundation

public protocol ContinousApodPersistenceDataSource {
    func getObjects() -> AsyncStream<[ApodModel]>
}

public class DefaultApodPersistenceDataSource: NSObject, ContinousApodPersistenceDataSource {
    private var newDataAppeared: (([ApodModel]) -> Void)?
    private let context: NSManagedObjectContext
    private var fetchedResultController: NSFetchedResultsController<Apod>?

    private var currentData: [ApodModel] {
        let fetchedData = fetchedResultController?.fetchedObjects ?? []
        let mappedData = fetchedData.compactMap { ApodModel(coreDataApod: $0) }
        return mappedData
    }

    public init(context: NSManagedObjectContext) {
        self.context = context

        super.init()
        setupSubscription()
    }

    public func getObjects() -> AsyncStream<[ApodModel]> {
        return AsyncStream<[ApodModel]> { [weak self] continuation in
            guard let self = self else {
                continuation.finish()
                return
            }
            continuation.yield(self.currentData)

            self.newDataAppeared = { newData in
                continuation.yield(newData)
            }
        }
    }

    public func setupSubscription() {
        context.automaticallyMergesChangesFromParent = true
        context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy

        let fetchRequest = Apod.fetchRequest()
        fetchRequest.sortDescriptors = [
            NSSortDescriptor(keyPath: \Apod.date, ascending: false),
        ]
        fetchRequest.returnsObjectsAsFaults = false
        let fetchController = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: context,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
        fetchController.delegate = self

        fetchedResultController = fetchController

        do {
            try fetchController.performFetch()
        } catch {
            fatalError("\(error.localizedDescription)")
        }
    }
}

// MARK: Delegate methods

extension DefaultApodPersistenceDataSource: NSFetchedResultsControllerDelegate {
    public func controllerDidChangeContent(_: NSFetchedResultsController<NSFetchRequestResult>) {
        newDataAppeared?(currentData)
    }
}
