//
//  ApodViewModel.swift
//  WWDC21
//
//  Created by mazurkk3 on 18/02/2022.
//

import APODY
import UIKit

@MainActor public class ApodViewModel: ObservableObject, Identifiable {
    private let apod: APODModel
    private let networking: ApodNetworking
    private let imageCache: ImageCache
    private let persistence: ApodPersistence

    private var dateFormatter: DateFormatter {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "YY/MM/dd"
        return dateFormatter
    }

    @Published var image: UIImage?

    var title: String {
        apod.title
    }

    var date: String {
        dateFormatter.string(from: apod.date)
    }

    var url: String {
        apod.url
    }

    var description: String {
        apod.explanation
    }

    var type: APODMediaType {
        apod.media_type
    }

    var favorite: Bool {
        apod.favorite
    }

    init(apod: APODModel, networking: ApodNetworking, imageCache: ImageCache, persistence: ApodPersistence) {
        self.apod = apod
        self.networking = networking
        self.imageCache = imageCache
        self.persistence = persistence
    }

    public func toggleFavorite() async throws {
        try await persistence.toggleFavorite(apod: apod)
    }

    public func getApodContent() async throws {
        if apod.media_type == .image {
            try await getImageFromCacheOrFetchAndCatch()
        }
    }

    // MARK: Helper

    private func getImageFromCacheOrFetchAndCatch() async throws {
        if let cachedImage = await imageCache.getImage(for: apod.url) {
            image = cachedImage
        } else {
            let image = try await networking.fetchImage(url: apod.url)
            self.image = image
            let url = apod.url
            cacheImage(image: image, url: url)
        }
    }

    private func cacheImage(image: UIImage, url: String) {
        Task.detached(priority: .background) { [weak self] in
            await self?.imageCache.insert(image: image, for: url)
        }
    }
}
