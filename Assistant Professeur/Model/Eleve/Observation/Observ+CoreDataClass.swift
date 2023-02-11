//
//  Observ+CoreDataClass.swift
//
//
//  Created by Lionel MICHAUD on 11/02/2023.
//
//

import CoreData
import Foundation

@objc(ObservEntity)
public class ObservEntity: NSManagedObject, Codable, ModelEntityP {
    enum CodingKeys: CodingKey {
        case id, descriptionMotif, date
        case isConsignee, isVerified, motif
    }

    /// Conformance to Decodable
    public required convenience init(from decoder: Decoder) throws {
        self.init(context: Self.viewContext)

        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(UUID.self, forKey: .id)
        self.descriptionMotif = try container.decode(String.self, forKey: .descriptionMotif)
        self.date = try container.decode(Date.self, forKey: .date)
        self.isConsignee = try container.decode(Bool.self, forKey: .isConsignee)
        self.isVerified = try container.decode(Bool.self, forKey: .isVerified)
        self.motif = try container.decode(Int16.self, forKey: .motif)
    }

    /// Conformance to Encodable
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(descriptionMotif, forKey: .descriptionMotif)
        try container.encode(date, forKey: .date)
        try container.encode(isConsignee, forKey: .isConsignee)
        try container.encode(isVerified, forKey: .isVerified)
        try container.encode(motif, forKey: .motif)
    }
}
