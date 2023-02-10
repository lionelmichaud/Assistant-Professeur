//
//  RoomEntity+CoreDataClass.swift
//  
//
//  Created by Lionel MICHAUD on 10/02/2023.
//
//

import Foundation
import CoreData

@objc(RoomEntity)
public class RoomEntity: NSManagedObject, Codable, ModelEntityP {

    enum CodingKeys: CodingKey {
        case id, name, capacity
    }

    /// Conformance to Decodable
    required convenience public init(from decoder: Decoder) throws {
        self.init(context: Self.viewContext)

        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(UUID.self, forKey: .id)
        self.name = try container.decode(String.self, forKey: .name)
        self.capacity = try container.decode(Int16.self, forKey: .capacity)

//        self.classes = try container.decode(Set<ClasseEntity>.self, forKey: .classes) as NSSet
    }

    /// Conformance to Encodable
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(capacity, forKey: .capacity)

//        try container.encode(classes as! Set<ClasseEntity>, forKey: .classes)
    }
}
