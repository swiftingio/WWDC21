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

public typealias ApodDataSubject = CurrentValueSubject<[APODModel], Never>

public protocol ContinousApodPersistenceDataSource {
    func getObjects() -> AsyncStream<[APODModel]>
}

public class DefaultApodPersistenceDataSource: NSObject, ContinousApodPersistenceDataSource {
    private var newDataAppeared: (([APODModel]) -> Void)?
    private let context: NSManagedObjectContext
    private var fetchedResultController: NSFetchedResultsController<Apod>?

    public init(context: NSManagedObjectContext) {
        self.context = context

        super.init()
        setupSubscription()
    }

    public func getObjects() -> AsyncStream<[APODModel]> {
        return AsyncStream<[APODModel]> { [weak self] continuation in
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

    private var currentData: [APODModel] {
        let fetchedData = fetchedResultController?.fetchedObjects ?? []
        let mappedData = fetchedData.compactMap { APODModel(coreDataApod: $0) }
        return mappedData
    }

    public func setupSubscription() {
        context.automaticallyMergesChangesFromParent = true
        context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        let fetchRequest = Apod.fetchRequest()
        fetchRequest
            .sortDescriptors = [NSSortDescriptor(keyPath: \Apod.date, ascending: false)]
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

extension DefaultApodPersistenceDataSource: NSFetchedResultsControllerDelegate {
    public func controllerDidChangeContent(_: NSFetchedResultsController<NSFetchRequestResult>) {
        newDataAppeared?(currentData)
    }
}
