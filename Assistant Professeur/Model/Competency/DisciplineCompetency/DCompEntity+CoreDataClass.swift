//
//  DCompEntity.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 09/06/2023.
//

import CoreData
import Foundation
import os

private let customLog = Logger(
    subsystem: "com.michaud.lionel.Assistant-Professeur",
    category: "DCompEntity.Codable"
)

@objc(DCompEntity)
public final class DCompEntity: NSManagedObject, Codable, ModelEntityP {
    enum CodingKeys: CodingKey {
        case id, number, descrip, knowledges, wCompIDs
    }

    public required convenience init(from decoder: Decoder) throws {
        self.init(context: Self.context)

        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(UUID.self, forKey: .id)
        self.number = try container.decode(Int16.self, forKey: .number)
        self.descrip = try container.decode(String.self, forKey: .descrip)

        // Les WCompChapter doivent être chargés AVANT les DTheme pour que les DCompEntity puissent
        // établir la connection avec les WCompEntity. Voir WCompEntity.init(from decoder: Decoder)
        if let wCompSetIds = try container.decodeIfPresent([UUID?].self, forKey: .wCompIDs) {
            wCompSetIds.forEach { wCompId in
                if let wCompId,
                   let wComp = WCompEntity.byId(id: wCompId) {
                    self.workedCompetencies?.adding(wComp)
                } else {
                    customLog.log(
                        level: .error,
                        "Erreur: Compétence travaillée associée à la Compétence disciplianire \(String(describing: self)) introuvable!"
                    )
                }
            }
        }

        self.knowledges = try container.decode(
            Set<DKnowledgeEntity>.self,
            forKey: .knowledges
        ) as NSSet
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(number, forKey: .number)
        try container.encode(descrip, forKey: .descrip)

        let wCompSet = workedCompetencies as? Set<WCompEntity>
        let wCompSetIds = wCompSet?.map { $0.id }
        try container.encodeIfPresent(wCompSetIds, forKey: .wCompIDs)

        try container.encodeIfPresent(
            knowledges as? Set<DKnowledgeEntity>,
            forKey: .knowledges
        )
    }
}
