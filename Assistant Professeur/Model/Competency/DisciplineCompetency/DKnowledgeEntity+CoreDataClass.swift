//
//  DKnowledgeEntity+CoreDataClass.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 11/06/2023.
//

import CoreData
import Foundation
import os

private let customLog = Logger(
    subsystem: "com.michaud.lionel.Assistant-Professeur",
    category: "DKnowledgeEntity.Codable"
)

@objc(DKnowledgeEntity)
public final class DKnowledgeEntity: NSManagedObject, Codable, ModelEntityP {
    enum CodingKeys: CodingKey {
        case id, number, descrip
    }

    public required convenience init(from decoder: Decoder) throws {
        self.init(context: Self.context)

        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(UUID.self, forKey: .id)
        self.number = try container.decode(Int16.self, forKey: .number)
        self.descrip = try container.decode(String.self, forKey: .descrip)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(number, forKey: .number)
        try container.encode(descrip, forKey: .descrip)
    }
}
