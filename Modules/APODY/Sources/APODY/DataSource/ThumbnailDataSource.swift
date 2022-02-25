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
import UIKit

public actor ThumbnailDataSource {

    private let imageCache: ImageCache
    private let networking: ApodNetworking

    public init(
        imageCache: ImageCache,
        networking: ApodNetworking
    ) {
        self.imageCache = imageCache
        self.networking = networking
    }

    public nonisolated func getThumbnails(models: [ApodModel]) -> AsyncStream<[String: UIImage]> {
        return AsyncStream<[String: UIImage]> { [weak self] continuation in
            guard let self = self else { return }
            Task {
                try await withThrowingTaskGroup(of: (String, UIImage).self) { group in
                    var thumbnails: [String: UIImage] = [:]
                    for model in models.filter({ $0.media_type == .image }) {
                        group.addTask(priority: .background) {
                            (model.url, try await self.fetchImage(url: model.url))
                        }
                    }
                    for try await (url, image) in group {
                        thumbnails[url] = image
                        continuation.yield(thumbnails)
                    }
                    continuation.finish()
                }
            }
        }
    }

    // MARK: Helpers

    private func fetchImage(url: String) async throws -> UIImage {
        if let cachedImage = await imageCache.getImage(for: url) {
            return cachedImage
        } else {
            let image = try await networking.fetchImage(url: url)
            cacheImage(image: image, url: url)
            return image
        }
    }

    private func cacheImage(image: UIImage, url: String) {
        Task.detached(priority: .background) { [weak self] in
            if await self?.imageCache.getImage(for: url) == nil {
                await self?.imageCache.insert(image: image, for: url)
            }
        }
    }
}
