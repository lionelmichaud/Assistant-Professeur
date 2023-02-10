//
//  SeatEntity+CoreDataClass.swift
//
//
//  Created by Lionel MICHAUD on 10/02/2023.
//
//

import CoreData
import Foundation

@objc(SeatEntity)
public class SeatEntity: NSManagedObject, Codable, ModelEntityP {
    enum CodingKeys: CodingKey {
        case id, numero, x, y
    }

    /// Conformance to Decodable
    public required convenience init(from decoder: Decoder) throws {
        self.init(context: Self.viewContext)

        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(UUID.self, forKey: .id)
        self.numero = try container.decode(Int16.self, forKey: .numero)
        self.x = try container.decode(Double.self, forKey: .x)
        self.y = try container.decode(Double.self, forKey: .y)
    }

    /// Conformance to Encodable
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(numero, forKey: .numero)
        try container.encode(x, forKey: .x)
        try container.encode(y, forKey: .y)
    }
}
