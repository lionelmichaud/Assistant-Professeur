//
//  DThemeEntity.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 07/06/2023.
//

import CoreData
import Foundation
import OSLog

private let customLog = Logger(
    subsystem: "com.michaud.lionel.Assistant-Professeur",
    category: "DThemeEntity.Codable"
)

@objc(DThemeEntity)
public final class DThemeEntity: NSManagedObject, Codable, ModelEntityP {
    enum CodingKeys: CodingKey {
        case id, descrip, cycle, acronym, discipline, sections
    }

    public required convenience init(from decoder: Decoder) throws {
        self.init(context: Self.context)

        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(UUID.self, forKey: .id)
        self.cycle = try container.decodeIfPresent(String.self, forKey: .cycle)
        self.acronym = try container.decodeIfPresent(String.self, forKey: .acronym)
        self.discipline = try container.decodeIfPresent(String.self, forKey: .discipline)
        self.descrip = try container.decodeIfPresent(String.self, forKey: .descrip)

        self.sections = try container.decode(
            Set<DSectionEntity>.self,
            forKey: .sections
        ) as NSSet
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encodeIfPresent(cycle, forKey: .cycle)
        try container.encodeIfPresent(acronym, forKey: .acronym)
        try container.encodeIfPresent(discipline, forKey: .discipline)
        try container.encodeIfPresent(descrip, forKey: .descrip)

        try container.encode(
            sections as! Set<DSectionEntity>,
            forKey: .sections
        )
    }
}
