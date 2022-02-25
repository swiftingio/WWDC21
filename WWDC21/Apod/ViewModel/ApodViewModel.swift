//
//  ApodViewModel.swift
//  WWDC21
//
//  Created by mazurkk3 on 17/02/2022.
//

import APODY
import Foundation
import UIKit

@MainActor class ApodViewModel: ObservableObject {
    @Published var thumbnails: [String: UIImage] = [:]

    let persistence: ApodPersistence

    private let dataSource: ThumbnailDataSource
    private let networking: ApodNetworking

    init(
        networking: ApodNetworking,
        persistence: ApodPersistence,
        dataSource: ThumbnailDataSource
    ) {
        self.persistence = persistence
        self.networking = networking
        self.dataSource = dataSource
    }

    public func refreshData() async throws {
        let currentDate = Date()
        let endDate = Calendar.current.date(byAdding: .month, value: -1, to: currentDate)!

        let objects = try await networking.fetchApods(
            startDate: endDate,
            endDate: currentDate
        )
        try await persistence.save(apods: objects)
    }

    public func fetchThumbnails(for models: [ApodModel]) async {
        for await (url, image) in dataSource.getThumbnails(models: models) {
            thumbnails[url] = image
        }
    }
}
