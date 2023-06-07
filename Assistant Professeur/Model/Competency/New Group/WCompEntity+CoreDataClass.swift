//
//  WCompEntity+CoreDataClass.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 04/06/2023.
//

import CoreData
import Foundation
import os

private let customLog = Logger(
    subsystem: "com.michaud.lionel.Assistant-Professeur",
    category: "WCompEntity.Codable"
)

@objc(WCompEntity)
public final class WCompEntity: NSManagedObject, Codable, ModelEntityP {
    enum CodingKeys: CodingKey {
        case id, number, descrip, chapter, acronym, disciplineCompetencies
    }

    public required convenience init(from decoder: Decoder) throws {
        self.init(context: Self.context)

        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(UUID.self, forKey: .id)
        self.number = try container.decode(Int16.self, forKey: .number)
        self.descrip = try container.decode(String.self, forKey: .descrip)

        //        self.competencies = try container.decode(
        //            Set<WorkedCompetencyEntity>.self,
        //            forKey: .competencies
        //        ) as NSSet
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(number, forKey: .number)
        try container.encode(descrip, forKey: .descrip)

//        try container.encode(
//            disciplineCompetencies as! Set<DCompEntity>,
//            forKey: .disciplineCompetencies
//        )
    }
}
