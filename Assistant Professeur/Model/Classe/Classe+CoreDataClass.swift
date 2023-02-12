//
//  ClasseEntity+CoreDataClass.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 07/02/2023.
//
//

import CoreData
import Foundation
import os

private let customLog = Logger(
    subsystem: "com.michaud.lionel.Assistant-Professeur",
    category: "ClasseEntity.Codable"
)

@objc(ClasseEntity)
public class ClasseEntity: NSManagedObject, Codable, ModelEntityP {
    enum CodingKeys: CodingKey {
        case id, level, numero, segpa, isFlagged
        case annotation, appreciation, discipline, heures
        case eleves, groups, exams, roomID
    }

    /// Conformance to Decodable
    public required convenience init(from decoder: Decoder) throws {
        self.init(context: Self.viewContext)

        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(UUID.self, forKey: .id)
        self.level = try container.decode(String.self, forKey: .level)
        self.numero = try container.decode(Int32.self, forKey: .numero)
        self.segpa = try container.decode(Bool.self, forKey: .segpa)
        self.isFlagged = try container.decode(Bool.self, forKey: .isFlagged)
        self.annotation = try container.decodeIfPresent(String.self, forKey: .annotation)
        self.appreciation = try container.decodeIfPresent(String.self, forKey: .appreciation)
        self.discipline = try container.decode(String.self, forKey: .discipline)
        self.heures = try container.decode(Double.self, forKey: .heures)

        // Les groupes doivent être chargés AVANT les élèves pour que les élèves puissent
        // établir la connection avec les groupes. Voir EleveEntity.init(from decoder: Decoder)
        self.groups = try container.decode(Set<GroupEntity>.self, forKey: .groups) as NSSet

        // Les eleves doivent être chargés AVANT les exams pour que les exam.marks puissent
        // établir la connection avec les élèves. Voir MarkEntity.init(from decoder: Decoder)
        self.eleves = try container.decode(Set<EleveEntity>.self, forKey: .eleves) as NSSet

        self.exams = try container.decode(Set<ExamEntity>.self, forKey: .exams) as NSSet

        // Les rooms doivent être chargés AVANT les classes pour que les classes puissent
        // établir la connection avec les rooms. Voir SchoolEntity.init(from decoder: Decoder)
        if let roomID = try container.decodeIfPresent(UUID.self, forKey: .roomID) {
            if let room = RoomEntity.byId(id: roomID) {
                self.room = room
            } else {
                customLog.log(
                    level: .error,
                    "Salle de classe de la classe \(self.displayString) introuvable!"
                )
            }
        }
    }

    /// Conformance to Encodable
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(level, forKey: .level)
        try container.encode(numero, forKey: .numero)
        try container.encode(segpa, forKey: .segpa)
        try container.encode(isFlagged, forKey: .isFlagged)
        try container.encodeIfPresent(annotation, forKey: .annotation)
        try container.encodeIfPresent(appreciation, forKey: .appreciation)
        try container.encode(discipline, forKey: .discipline)
        try container.encode(heures, forKey: .heures)

        try container.encode(eleves as! Set<EleveEntity>, forKey: .eleves)
        try container.encode(groups as! Set<GroupEntity>, forKey: .groups)
        try container.encode(exams as! Set<ExamEntity>, forKey: .exams)
        try container.encodeIfPresent(room?.id, forKey: .roomID)
    }
}
