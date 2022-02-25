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

    public typealias ThumbnailsStream = AsyncStream<(String, UIImage)>

    public nonisolated func getThumbnails(models: [ApodModel]) -> ThumbnailsStream {
        return ThumbnailsStream { continuation in
            Task {
                try await fetchThumbnails(from: models, continuation: continuation)
            }
        }
    }

    private func fetchThumbnails(
        from apody: [ApodModel],
        continuation: ThumbnailsStream.Continuation
    ) async throws {
        try await withThrowingTaskGroup(of: (String, UIImage).self) { group in
            for apod in apody.filter({ $0.media_type == .image }) {
                group.addTask(priority: .background) {
                    (apod.url, try await self.fetchImage(url: apod.url))
                }
            }
            for try await data in group {
                continuation.yield(data)
            }
            continuation.finish()
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
