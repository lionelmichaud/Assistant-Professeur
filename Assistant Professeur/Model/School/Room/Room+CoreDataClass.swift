//
//  RoomEntity+CoreDataClass.swift
//
//
//  Created by Lionel MICHAUD on 10/02/2023.
//
//

import CoreData
import Foundation

@objc(RoomEntity)
public final class RoomEntity: NSManagedObject, Codable, ModelEntityP {
    enum CodingKeys: CodingKey {
        case id, name, capacity, seats
    }

    /// Conformance to Decodable
    public required convenience init(from decoder: Decoder) throws {
        self.init(context: Self.context)

        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(UUID.self, forKey: .id)
        self.name = try container.decode(String.self, forKey: .name)
        self.capacity = try container.decode(Int16.self, forKey: .capacity)

        self.seats = try container.decode(Set<SeatEntity>.self, forKey: .seats) as NSSet
    }

    /// Conformance to Encodable
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(capacity, forKey: .capacity)

        try container.encode(seats as! Set<SeatEntity>, forKey: .seats)
    }
}
