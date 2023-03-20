//
//  Sequence+CoreDataClass.swift
//
//
//  Created by Lionel MICHAUD on 11/02/2023.
//
//

import CoreData
import Foundation
import os

private let customLog = Logger(
    subsystem: "com.michaud.lionel.Assistant-Professeur",
    category: "SequenceEntity.Codable"
)

@objc(SequenceEntity)
public final class SequenceEntity: NSManagedObject, Codable, ModelEntityP {
    enum CodingKeys: CodingKey {
        case id, annotation
        case name, number, url
        case activities, document
    }

    /// Conformance to Decodable
    public required convenience init(from decoder: Decoder) throws {
        self.init(context: Self.viewContext)

        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(UUID.self, forKey: .id)
        self.name = try container.decode(String.self, forKey: .name)
        self.number = try container.decode(Int16.self, forKey: .number)
        self.annotation = try container.decodeIfPresent(String.self, forKey: .annotation)
        self.url = try container.decodeIfPresent(URL.self, forKey: .url)

//        // Les Documents doivent être chargés AVANT les Séquences pour pouvoir
//        // établir la connection avec le document éventuellement associé à la séquence.
//        if let documentID = try container.decodeIfPresent(UUID.self, forKey: .documentID) {
//            if let document = DocumentEntity.byId(id: documentID) {
//                self.document = document
//            } else {
//                customLog.log(
//                    level: .error,
//                    "Document associé à la séquence \(String(describing: self)) introuvable!"
//                )
//            }
//        }

        self.document = try container.decode(DocumentEntity.self, forKey: .document)
        self.activities = try container.decode(Set<ActivityEntity>.self, forKey: .activities) as NSSet
    }

    /// Conformance to Encodable
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(number, forKey: .number)
        try container.encodeIfPresent(annotation, forKey: .annotation)
        try container.encodeIfPresent(url, forKey: .url)

//        try container.encodeIfPresent(document?.id, forKey: .documentID)

        try container.encodeIfPresent(document, forKey: .document)
        try container.encode(activities as! Set<ActivityEntity>, forKey: .activities)
    }
}
