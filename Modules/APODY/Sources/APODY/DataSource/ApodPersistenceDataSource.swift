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
    var objects: AsyncStream<[APODModel]>? { get }
}

public enum ApodDataSourceError: Error {
    case objectWasReleased
}

public class DefaultApodPersistenceDataSource: NSObject, NSFetchedResultsControllerDelegate, ContinousApodPersistenceDataSource {
    public var objects: AsyncStream<[APODModel]>?

    private let context: NSManagedObjectContext
    private var fetchedResultController: NSFetchedResultsController<Apod>?
    private var continuation: AsyncStream<[APODModel]>.Continuation?

    public init(context: NSManagedObjectContext) {
        self.context = context

        super.init()
        objects = AsyncStream([APODModel].self) { [weak self] continuation in
            self?.continuation = continuation
        }
        setupSubscription()
    }

    public func controllerDidChangeContent(_: NSFetchedResultsController<NSFetchRequestResult>) {
        continuation!.yield(currentData)
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
            continuation!.yield(currentData)
        } catch {
            fatalError("\(error.localizedDescription)")
        }
    }
}
