//
//  School+CoreDataClass.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 06/02/2023.
//

import CoreData
import Foundation

@objc(SchoolEntity)
public class SchoolEntity: NSManagedObject, Codable, ModelEntityP {
    enum CodingKeys: CodingKey {
        case id, name, level, annotation, classes
    }

    /// Conformance to Decodable
    required convenience public init(from decoder: Decoder) throws {
        self.init(context: Self.viewContext)

        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(UUID.self, forKey: .id)
        self.name = try container.decode(String.self, forKey: .name)
        self.level = try container.decode(String.self, forKey: .level)
        self.annotation = try container.decodeIfPresent(String.self, forKey: .annotation)
        self.classes = try container.decode(Set<ClasseEntity>.self, forKey: .classes) as NSSet
    }

    /// Conformance to Encodable
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(level, forKey: .level)
        try container.encodeIfPresent(annotation, forKey: .annotation)
        try container.encode(classes as! Set<ClasseEntity>, forKey: .classes)
    }
}
