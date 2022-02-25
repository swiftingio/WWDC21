//
//  ApodNetworking.swift
//  WWDC21
//
//  Created by mazurkk3 on 17/02/2022.
//

import Foundation
import UIKit

public protocol ApodNetworking: Sendable {
    func fetchApods(count: Int) async throws -> [ApodModel]
    func fetchApods(startDate: Date, endDate: Date) async throws -> [ApodModel]

    func fetchImage(url: String) async throws -> UIImage
}

enum ApodNetworkingError: Error {
    case invalidServerResponse
    case parsingFailure
    case invalidURL
    case unableToCreateImage
}

public actor DefaultApodNetworking: ApodNetworking {
    let decoder: JSONDecoder
    let urlBuilder: URLBuilder

    public init(urlBuilder: URLBuilder, jsonDecoder: JSONDecoder) {
        decoder = jsonDecoder
        self.urlBuilder = urlBuilder
    }

    public convenience init() {
        let defaultBuilder = DefaultURLBuilder()
        let defaultJsonDecoder = JSONDecoderFactory.defaultApodJSONDecoder()
        self.init(urlBuilder: defaultBuilder, jsonDecoder: defaultJsonDecoder)
    }

    public func fetchApods(count: Int) async throws -> [ApodModel] {
        let endpoint = ApodEndpoint.apody

        let parameters = [
            ApodParameter.count("\(count)"),
            ApodParameter.apiKey,
        ]
        let url = try urlBuilder.build(endpoint: endpoint, parameters: parameters)
        let (data, response) = try await URLSession.shared.data(from: url)

        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw ApodNetworkingError.invalidServerResponse
        }

        let parsedData = try decoder.decode([ApodModel].self, from: data)

        return parsedData
    }

    public func fetchApods(startDate: Date, endDate: Date) async throws -> [ApodModel] {
        let endpoint = ApodEndpoint.apody
        let parameters = [
            ApodParameter.startDate(startDate),
            ApodParameter.endDate(endDate),
            ApodParameter.apiKey,
        ]

        let url = try urlBuilder.build(endpoint: endpoint, parameters: parameters)
        let (data, response) = try await URLSession.shared.data(from: url)

        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw ApodNetworkingError.invalidServerResponse
        }

        let parsedData = try decoder.decode([ApodModel].self, from: data)

        return parsedData
    }

    public func fetchImage(url: String) async throws -> UIImage {
        guard let url = URL(string: url) else {
            throw ApodNetworkingError.invalidURL
        }

        let (data, response) = try await URLSession.shared.data(from: url)
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw ApodNetworkingError.invalidServerResponse
        }

        guard let image = UIImage(data: data) else {
            throw ApodNetworkingError.unableToCreateImage
        }
        return image
    }
}
