//
//  ActivityProgressEntity+CoreDataClass.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 19/02/2023.
//
//

import CoreData
import Foundation
import os

private let customLog = Logger(
    subsystem: "com.michaud.lionel.Assistant-Professeur",
    category: "ActivityProgressEntity.Codable"
)

@objc(ActivityProgressEntity)
public final class ActivityProgressEntity: NSManagedObject, Codable, ModelEntityP {
    enum CodingKeys: CodingKey {
        case id, annotation, progress, classeID, isPrinted
    }

    /// Conformance to Decodable
    public required convenience init(from decoder: Decoder) throws {
        self.init(context: Self.context)

        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(UUID.self, forKey: .id)
        self.progress = try container.decode(Double.self, forKey: .progress)
        self.annotation = try container.decodeIfPresent(String.self, forKey: .annotation)
        self.isPrinted = try container.decode(Bool.self, forKey: .isPrinted)

        // Les Classes doivent être chargés AVANT les Progress pour que les exam.marks puissent
        // établir la connection avec les élèves. Voir ClassEntity.init(from decoder: Decoder)
        if let classeID = try container.decodeIfPresent(UUID.self, forKey: .classeID) {
            if let classe = ClasseEntity.byId(id: classeID) {
                self.classe = classe
            } else {
                customLog.log(
                    level: .error,
                    "Erreur: Classe associée à la progression \(String(describing: self)) introuvable!"
                )
            }
        }
    }

    /// Conformance to Encodable
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(progress, forKey: .progress)
        try container.encodeIfPresent(annotation, forKey: .annotation)
        try container.encode(isPrinted, forKey: .isPrinted)

        try container.encodeIfPresent(classe?.id, forKey: .classeID)
    }
}
