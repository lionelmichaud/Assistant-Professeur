//
//  Sequence+CoreDataClass.swift
//
//
//  Created by Lionel MICHAUD on 11/02/2023.
//
//

import CoreData
import Foundation

@objc(SequenceEntity)
public class SequenceEntity: NSManagedObject, Codable, ModelEntityP {
    enum CodingKeys: CodingKey {
        case id, annotation
        case name, number, url
        case activities
    }

    /// Conformance to Decodable
    public required convenience init(from decoder: Decoder) throws {
        self.init(context: Self.viewContext)

        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(UUID.self, forKey: .id)
        self.name = try container.decode(String.self, forKey: .name)
        self.number = try container.decode(Int16.self, forKey: .number)
        self.annotation = try container.decodeIfPresent(String.self, forKey: .annotation)
        self.url = try container.decodeIfPresent(URL.self, forKey: .url)

        self.activities = try container.decode(Set<ActivityEntity>.self, forKey: .activities) as NSSet
    }

    /// Conformance to Encodable
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(number, forKey: .number)
        try container.encodeIfPresent(annotation, forKey: .annotation)
        try container.encodeIfPresent(url, forKey: .url)

        try container.encode(activities as! Set<ActivityEntity>, forKey: .activities)
    }
}
