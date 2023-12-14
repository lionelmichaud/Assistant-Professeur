//
//  Mark+CoreDataClass.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 11/02/2023.
//
//

import CoreData
import Foundation
import OSLog

private let customLog = Logger(
    subsystem: "com.michaud.lionel.Assistant-Professeur",
    category: "MarkEntity.Codable"
)

@objc(MarkEntity)
public final class MarkEntity: NSManagedObject, Codable, ModelEntityP {
    enum CodingKeys: CodingKey {
        case id, examType, mark, markType, steps
        case eleveID
    }

    /// Conformance to Decodable
    public required convenience init(from decoder: Decoder) throws {
        self.init(context: Self.context)

        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(UUID.self, forKey: .id)
        self.examType = try container.decode(String.self, forKey: .examType)
        self.mark = try container.decode(Double.self, forKey: .mark)
        self.markType = try container.decode(Int16.self, forKey: .markType)
        self.steps = try container.decode(String.self, forKey: .steps)

        // Les eleves doivent être chargés AVANT les exams pour que les exam.marks puissent
        // établir la connection avec les élèves. Voir ClassEntity.init(from decoder: Decoder)
        if let eleveID = try container.decodeIfPresent(UUID.self, forKey: .eleveID) {
            if let eleve = EleveEntity.byId(id: eleveID) {
                self.eleve = eleve
            } else {
                customLog.log(
                    level: .error,
                    "Erreur: Eleve associé à la note \(String(describing: self)) introuvable!"
                )
            }
        }
    }

    /// Conformance to Encodable
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(examType, forKey: .examType)
        try container.encode(mark, forKey: .mark)
        try container.encode(markType, forKey: .markType)
        try container.encode(steps, forKey: .steps)

        try container.encodeIfPresent(eleve?.id, forKey: .eleveID)
    }
}
