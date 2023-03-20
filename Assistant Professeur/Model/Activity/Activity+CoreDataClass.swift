//
//  ActivityEntity+CoreDataClass.swift
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
    category: "ActivityEntity.Codable"
)

@objc(ActivityEntity)
public final class ActivityEntity: NSManagedObject, Codable, ModelEntityP {
    enum CodingKeys: CodingKey {
        case id, isEval, isEvalFormative, isProject, isTP
        case annotation, duration, name, number, url
        case progresses, document
    }

    /// Conformance to Decodable
    public required convenience init(from decoder: Decoder) throws {
        self.init(context: Self.viewContext)

        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(UUID.self, forKey: .id)
        self.isEval = try container.decode(Bool.self, forKey: .isEval)
        self.isEvalFormative = try container.decode(Bool.self, forKey: .isEvalFormative)
        self.isProject = try container.decode(Bool.self, forKey: .isProject)
        self.isTP = try container.decode(Bool.self, forKey: .isTP)
        self.name = try container.decode(String.self, forKey: .name)
        self.number = try container.decode(Int16.self, forKey: .number)
        self.duration = try container.decode(Double.self, forKey: .duration)
        self.annotation = try container.decodeIfPresent(String.self, forKey: .annotation)
        self.url = try container.decodeIfPresent(URL.self, forKey: .url)

//        // Les Documents doivent être chargés AVANT les Activity pour pouvoir
//        // établir la connection avec le document éventuellement associé à l'activité.
//        if let documentID = try container.decodeIfPresent(UUID.self, forKey: .documentID) {
//            if let document = DocumentEntity.byId(id: documentID) {
//                self.document = document
//            } else {
//                customLog.log(
//                    level: .error,
//                    "Erreur: Document associé à l'activité \(String(describing: self)) introuvable!"
//                )
//            }
//        }

        self.document = try container.decode(DocumentEntity.self, forKey: .document)
        self.progresses = try container.decode(Set<ActivityProgressEntity>.self, forKey: .progresses) as NSSet
    }

    /// Conformance to Encodable
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(isEval, forKey: .isEval)
        try container.encode(isEvalFormative, forKey: .isEvalFormative)
        try container.encode(isProject, forKey: .isProject)
        try container.encode(isTP, forKey: .isTP)
        try container.encode(name, forKey: .name)
        try container.encode(number, forKey: .number)
        try container.encode(duration, forKey: .duration)
        try container.encodeIfPresent(annotation, forKey: .annotation)
        try container.encodeIfPresent(url, forKey: .url)

//        try container.encodeIfPresent(document?.id, forKey: .documentID)

        try container.encodeIfPresent(document, forKey: .document)
        try container.encode(progresses as! Set<ActivityProgressEntity>, forKey: .progresses)
    }
}
