//
//  ProgramEntity+CoreDataClass.swift
//
//
//  Created by Lionel MICHAUD on 11/02/2023.
//
//

import CoreData
import Foundation
import OSLog

private let customLog = Logger(
    subsystem: "com.michaud.lionel.Assistant-Professeur",
    category: "ProgramEntity.Codable"
)

@objc(ProgramEntity)
public final class ProgramEntity: NSManagedObject, Codable, ModelEntityP {
    enum CodingKeys: CodingKey {
        case id, discipline, level, segpa, url, annotation
        case sequences, document
    }

    /// Conformance to Decodable
    public required convenience init(from decoder: Decoder) throws {
        self.init(context: Self.context)

        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(UUID.self, forKey: .id)
        self.discipline = try container.decode(String.self, forKey: .discipline)
        self.level = try container.decode(String.self, forKey: .level)
        self.segpa = try container.decode(Bool.self, forKey: .segpa)
        self.annotation = try container.decodeIfPresent(String.self, forKey: .annotation)
        self.url = try container.decodeIfPresent(URL.self, forKey: .url)

//        // Les Documents doivent être chargés AVANT les Programmes pour pouvoir
//        // établir la connection avec le document éventuellement associé au programme.
//        if let documentID = try container.decodeIfPresent(UUID.self, forKey: .documentID) {
//            if let document = DocumentEntity.byId(id: documentID) {
//                self.document = document
//            } else {
//                customLog.log(
//                    level: .error,
//                    "Erreur: Document associé au programme \(String(describing: self)) introuvable!"
//                )
//            }
//        }

        self.document = try container.decodeIfPresent(DocumentEntity.self, forKey: .document)
        self.sequences = try container.decode(Set<SequenceEntity>.self, forKey: .sequences) as NSSet
    }

    /// Conformance to Encodable
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(discipline, forKey: .discipline)
        try container.encode(level, forKey: .level)
        try container.encode(segpa, forKey: .segpa)
        try container.encodeIfPresent(annotation, forKey: .annotation)
        try container.encodeIfPresent(url, forKey: .url)

//        try container.encodeIfPresent(document?.id, forKey: .documentID)

        try container.encodeIfPresent(document, forKey: .document)
        try container.encode(sequences as! Set<SequenceEntity>, forKey: .sequences)
    }
}
