//
//  Apod+CoreDataProperties.swift
//  WWDC21
//
//  Created by mazurkk3 on 17/02/2022.
//
//

import CoreData
import Foundation

public extension Apod {
    @objc var month: String {
        return date.formatted(.dateTime.month(.wide))
    }

    @objc var week: String {
        return date.formatted(.dateTime.month(.wide).week())
    }

    @nonobjc class func fetchRequest() -> NSFetchRequest<Apod> {
        return NSFetchRequest<Apod>(entityName: "Apod")
    }

    @NSManaged var date: Date!
    @NSManaged var explanation: String!
    @NSManaged var hdurl: String?
    @NSManaged var media_type: String!
    @NSManaged var service_version: String!
    @NSManaged var title: String!
    @NSManaged var url: String!
}

extension Apod: Identifiable {}

public extension Bundle {
    static var apodyModule: Bundle {
        module
    }
}
