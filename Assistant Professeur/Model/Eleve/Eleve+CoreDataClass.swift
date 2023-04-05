//
//  EleveEntity+CoreDataClass.swift
//
//
//  Created by Lionel MICHAUD on 10/02/2023.
//
//

import CoreData
import Foundation
import os

private let customLog = Logger(
    subsystem: "com.michaud.lionel.Assistant-Professeur",
    category: "EleveEntity.Codable"
)

@objc(EleveEntity)
public final class EleveEntity: NSManagedObject, Codable, ModelEntityP {
    enum CodingKeys: CodingKey {
        case id, familyName, givenName, sex, trouble, isFlagged
        case annotation, appreciation, bonus, hasAddTime
        case observs, colles, groupeID, seatID
    }

    /// Conformance to Decodable
    public required convenience init(from decoder: Decoder) throws {
        self.init(context: Self.context)

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

        // Les groupes doivent être chargés AVANT les élèves pour que les élèves puissent
        // établir la connection avec les groupes. Voir GroupEntity.init(from decoder: Decoder)
        if let groupID = try container.decodeIfPresent(UUID.self, forKey: .groupeID) {
            if let groupe = GroupEntity.byId(id: groupID) {
                self.group = groupe
            } else {
                customLog.log(
                    level: .error,
                    "Erreur: Groupe de l'élève \(self.displayName) introuvable!"
                )
            }
        }

        // Les seats doivent être chargés AVANT les élèves pour que les élèves puissent
        // établir la connection avec les groupes. Voir SchoolEntity.init(from decoder: Decoder)
        if let seatID = try container.decodeIfPresent(UUID.self, forKey: .seatID) {
            if let seat = SeatEntity.byId(id: seatID) {
                self.seat = seat
            } else {
                customLog.log(
                    level: .error,
                    "Erreur: Siège de l'élève \(self.displayName) introuvable dans sa salle de classe!"
                )
            }
        }
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
        try container.encodeIfPresent(group?.id, forKey: .groupeID)
        try container.encodeIfPresent(seat?.id, forKey: .seatID)
    }
}
