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
    @Published var thumbnails: [String: UIImage] = [:]

    let networking: ApodNetworking
    let persistence: ApodPersistence
    let dataSource: ContinousApodPersistenceDataSource
    let imageCache = ImageCache()

    private var currentModels: [APODModel] = []

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
            currentModels = newObjects
            do {
                try await fetchThumbnails()
            } catch {
                print("error: \(error)")
            }
        }
    }

    private func fetchThumbnails() async throws {
        try await withThrowingTaskGroup(of: (String, UIImage).self) { group in
            for model in currentModels.filter({ $0.media_type == .image }) {
                group.addTask {
                    (model.url, try await self.fetchImage(url: model.url))
                }
            }
            for try await (url, image) in group {
                self.append(image: image, url: url)
            }
        }
    }

    private func append(image: UIImage, url: String) {
        thumbnails[url] = image
    }

    public func fetchImage(url: String) async throws -> UIImage {
        if let cachedImage = await imageCache.getImage(for: url) {
            return cachedImage
        } else {
            let image = try await networking.fetchImage(url: url)
            cacheImage(image: image, url: url)
            return image
        }
    }

    // MARK: Helper

    private func cacheImage(image: UIImage, url: String) {
        Task.detached(priority: .background) { [weak self] in
            if await self?.imageCache.getImage(for: url) == nil {
                await self?.imageCache.insert(image: image, for: url)
            }
        }
    }
}
