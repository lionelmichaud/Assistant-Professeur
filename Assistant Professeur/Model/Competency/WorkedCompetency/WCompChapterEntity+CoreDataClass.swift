//
//  WorkedCompetencyChapterEntity+CoreDataClass.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 04/06/2023.
//

import CoreData
import Foundation
import os

private let customLog = Logger(
    subsystem: "com.michaud.lionel.Assistant-Professeur",
    category: "WCompChapterEntity.Codable"
)

@objc(WCompChapterEntity)
public final class WCompChapterEntity: NSManagedObject, Codable, ModelEntityP {
    enum CodingKeys: CodingKey {
        case id, title, descrip, cycle, acronym, competencies
    }

    public required convenience init(from decoder: Decoder) throws {
        self.init(context: Self.context)

        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(UUID.self, forKey: .id)
        self.cycle = try container.decodeIfPresent(String.self, forKey: .cycle)
        self.acronym = try container.decodeIfPresent(String.self, forKey: .acronym)
        self.descrip = try container.decodeIfPresent(String.self, forKey: .descrip)

        self.competencies = try container.decode(
            Set<WCompEntity>.self,
            forKey: .competencies
        ) as NSSet
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encodeIfPresent(cycle, forKey: .cycle)
        try container.encodeIfPresent(descrip, forKey: .descrip)
        try container.encodeIfPresent(acronym, forKey: .acronym)

        try container.encode(
            competencies as! Set<WCompEntity>,
            forKey: .competencies
        )
    }
}
