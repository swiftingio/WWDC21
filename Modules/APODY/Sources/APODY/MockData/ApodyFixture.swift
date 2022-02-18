import Foundation

public enum ApodyFixtures {
    public static func example1() throws -> [APODModel] {
        let jsonDecoder = JSONDecoderFactory.defaultApodJSONDecoder()
        let jsonData = try JSONDataProvider.loadJSONFile(filename: "SampleApody")
        let result = try jsonDecoder.decode([APODModel].self, from: jsonData)
        return result
    }
}

enum JSONDataProvider {
    static func loadJSONFile(filename: String) throws -> Data {
        let bundle = Bundle.module
        guard let url = bundle.url(forResource: filename, withExtension: "json") else {
            throw JSONProviderError.cannotFindURLResource
        }
        return try Data(contentsOf: url)
    }

    enum JSONProviderError: Error {
        case cannotFindURLResource
    }
}
