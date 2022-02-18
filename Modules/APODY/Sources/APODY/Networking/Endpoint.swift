//
//  Endpoint.swift
//  WWDC21
//
//  Created by mazurkk3 on 17/02/2022.
//

import Foundation
import System

public protocol Endpoint {
    var base: String { get }
    var path: String { get }
    var fullPath: String { get }
}

public extension Endpoint {
    var fullPath: String {
        return base + path
    }
}

public enum ApodEndpoint: Endpoint {
    case apody

    public var base: String {
        return "https://api.nasa.gov"
    }

    public var path: String {
        switch self {
        case .apody:
            return "/planetary/apod"
        }
    }
}
