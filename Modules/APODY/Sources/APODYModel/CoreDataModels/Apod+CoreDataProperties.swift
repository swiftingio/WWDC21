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
