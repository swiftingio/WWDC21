//
//  HomeViewModel.swift
//  WWDC21
//
//  Created by mazurkk3 on 17/02/2022.
//

import APODY
import Foundation
import UIKit

@MainActor class HomeViewModel: ObservableObject {
    @Published var objects: [ApodViewModel] = []

    let networking: ApodNetworking
    let persistence: ApodPersistence
    let dataSource: ContinousApodPersistenceDataSource
    let imageCache = ImageCache()

    init(networking: ApodNetworking, persistence: ApodPersistence, dataSource: ContinousApodPersistenceDataSource) {
        self.persistence = persistence
        self.networking = networking
        self.dataSource = dataSource

        Task {
            await setupDataSource()
        }
    }

    convenience init(persistence: ApodPersistence, dataSource: ContinousApodPersistenceDataSource) {
        let defaultNetworking = DefaultApodNetworking()
        self.init(networking: defaultNetworking, persistence: persistence, dataSource: dataSource)
    }

    public func refreshData() async throws {
        let currentDate = Date()
        let endDate = Calendar.current.date(byAdding: .month, value: -1, to: currentDate)!

        let objects = try await networking.fetchApods(startDate: endDate, endDate: currentDate)
        try await persistence.save(apods: objects)
    }

    public func setupDataSource() async {
        for await newObjects in dataSource.getObjects() {
            objects = newObjects.map { ApodViewModel(apod: $0, networking: networking, imageCache: imageCache, persistence: persistence) }
        }
    }
}
