//
//  EleveEntity+CoreDataClass.swift
//
//
//  Created by Lionel MICHAUD on 10/02/2023.
//
//

import CoreData
import Foundation

@objc(EleveEntity)
public class EleveEntity: NSManagedObject, Codable, ModelEntityP {
    enum CodingKeys: CodingKey {
        case id, familyName, givenName, sex, trouble, isFlagged
        case annotation, appreciation, bonus, hasAddTime, observs, colles
    }

    /// Conformance to Decodable
    public required convenience init(from decoder: Decoder) throws {
        self.init(context: Self.viewContext)

        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(UUID.self, forKey: .id)
        self.familyName = try container.decode(String.self, forKey: .familyName)
        self.givenName = try container.decode(String.self, forKey: .givenName)
        self.sex = try container.decode(Bool.self, forKey: .sex)
        self.trouble = try container.decode(Int16.self, forKey: .trouble)
        self.isFlagged = try container.decode(Bool.self, forKey: .isFlagged)
        self.hasAddTime = try container.decode(Bool.self, forKey: .hasAddTime)
        self.bonus = try container.decode(Int16.self, forKey: .bonus)
        self.annotation = try container.decodeIfPresent(String.self, forKey: .annotation)
        self.appreciation = try container.decodeIfPresent(String.self, forKey: .appreciation)

        self.observs = try container.decode(Set<ObservEntity>.self, forKey: .observs) as NSSet
        self.colles = try container.decode(Set<ColleEntity>.self, forKey: .colles) as NSSet
        //        self.eleves = try container.decode(Set<EleveEntity>.self, forKey: .eleves) as NSSet
    }

    /// Conformance to Encodable
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(familyName, forKey: .familyName)
        try container.encode(givenName, forKey: .givenName)
        try container.encode(sex, forKey: .sex)
        try container.encode(trouble, forKey: .trouble)
        try container.encode(isFlagged, forKey: .isFlagged)
        try container.encode(hasAddTime, forKey: .hasAddTime)
        try container.encode(bonus, forKey: .bonus)
        try container.encodeIfPresent(annotation, forKey: .annotation)
        try container.encodeIfPresent(appreciation, forKey: .appreciation)

        try container.encode(observs as! Set<ObservEntity>, forKey: .observs)
        try container.encode(colles as! Set<ColleEntity>, forKey: .colles)
        //        try container.encode(eleves as! Set<EleveEntity>, forKey: .eleves)
    }
}
