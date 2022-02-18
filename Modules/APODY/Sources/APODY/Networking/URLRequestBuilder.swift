//
//  File.swift
//
//
//  Created by mazurkk3 on 17/02/2022.
//

import Foundation

public protocol URLParameter {
    var name: String { get }
    var value: String { get }

    func buildQueryItem() -> URLQueryItem
}

public enum ApodParameter: URLParameter {
    public typealias Value = String

    case apiKey
    case count(Value)
    case startDate(Date)
    case endDate(Date)

    private var dateFormatter: DateFormatter {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "YYYY-MM-dd"
        return dateFormatter
    }

    public var name: String {
        switch self {
        case .apiKey:
            return "api_key"
        case .count:
            return "count"
        case .startDate:
            return "start_date"
        case .endDate:
            return "end_date"
        }
    }

    public var value: String {
        switch self {
        case .apiKey:
            return "E0KqAaJyQaf8wdkbq5BaPcc5mP8gfVgN6GsGQ5ma"
        case let .count(value):
            return value
        case let .startDate(date):
            return dateFormatter.string(from: date)
        case let .endDate(date):
            return dateFormatter.string(from: date)
        }
    }

    public func buildQueryItem() -> URLQueryItem {
        URLQueryItem(name: name, value: value)
    }
}

public protocol URLBuilder {
    func build(endpoint: Endpoint, parameters: [URLParameter]) throws -> URL
}

enum URLBuilderError: Error {
    case invalidFullPath
    case invalidURL
}

public struct DefaultURLBuilder: URLBuilder {
    public func build(endpoint: Endpoint, parameters: [URLParameter]) throws -> URL {
        guard var urlComponents = URLComponents(string: endpoint.fullPath) else {
            throw URLBuilderError.invalidFullPath
        }
        let queryItems = parameters.map { $0.buildQueryItem() }
        urlComponents.queryItems = queryItems

        guard let url = urlComponents.url else {
            throw URLBuilderError.invalidURL
        }

        return url
    }
}
