import Foundation

public struct ApodSort: Hashable, Identifiable {
    public let id: Int
    public let name: String
    public let descriptors: [SortDescriptor<Apod>]
    public let section: KeyPath<Apod, String>

    public static let sorts: [ApodSort] = [
        ApodSort(
            id: 0,
            name: "Month | Descending",
            descriptors: [
                SortDescriptor(\Apod.date, order: .reverse),
            ],
            section: \Apod.month
        ),
        ApodSort(
            id: 1,
            name: "Week | Ascending",
            descriptors: [
                SortDescriptor(\Apod.date, order: .forward),
            ],
            section: \Apod.week
        ),
    ]

    public static var `default`: ApodSort { sorts[0] }
}
