import APODYModel
import CoreData
import Foundation

public enum APODMediaType: String, Codable {
    case image
    case video
}

public struct APODModel: Codable, Equatable, Identifiable, Hashable {
    public var id: String {
        url
    }

    public let date: Date
    public let explanation: String
    public let hdurl: String?
    public let media_type: APODMediaType
    public let service_version: String
    public let title: String
    public let url: String

    public init(
        date: Date,
        explanation: String,
        hdurl: String?,
        media_type: APODMediaType,
        service_version: String,
        title: String,
        url: String
    ) {
        self.date = date
        self.explanation = explanation
        self.hdurl = hdurl
        self.service_version = service_version
        self.media_type = media_type
        self.title = title
        self.url = url
    }
}

extension APODModel {
    init(coreDataApod: APODYModel.Apod) {
        self.init(date: coreDataApod.date,
                  explanation: coreDataApod.explanation,
                  hdurl: coreDataApod.hdurl,
                  media_type: APODMediaType(rawValue: coreDataApod.media_type) ?? .image,
                  service_version: coreDataApod.service_version,
                  title: coreDataApod.title,
                  url: coreDataApod.url)
    }
}

extension APODYModel.Apod {
    convenience init(model: APODModel, context: NSManagedObjectContext) {
        self.init(context: context)
        date = model.date
        explanation = model.explanation
        hdurl = model.hdurl
        media_type = model.media_type.rawValue
        service_version = model.service_version
        title = model.title
        url = model.url
    }
}
