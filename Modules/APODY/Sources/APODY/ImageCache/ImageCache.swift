import Foundation
import UIKit

public actor ImageCache {
    let cache: NSCache<NSString, UIImage>

    public init() {
        cache = NSCache<NSString, UIImage>()
    }

    public func insert(image: UIImage, for key: String) {
        let nsstring = NSString(string: key)
        cache.setObject(image, forKey: nsstring)
    }

    public func remove(in key: String) {
        let nsstring = NSString(string: key)
        cache.removeObject(forKey: nsstring)
    }

    public func getImage(for key: String) -> UIImage? {
        let nsstring = NSString(string: key)
        return cache.object(forKey: nsstring)
    }
}
