//
//  ExamEntity+CoreDataClass.swift
//
//
//  Created by Lionel MICHAUD on 11/02/2023.
//
//

import CoreData
import Foundation

@objc(ExamEntity)
public final class ExamEntity: NSManagedObject, Codable, ModelEntityP {
    enum CodingKeys: CodingKey {
        case id, coef, dateExecuted, examType
        case maxMark, steps, sujet
        case marks
    }

    /// Conformance to Decodable
    public required convenience init(from decoder: Decoder) throws {
        self.init(context: Self.viewContext)

        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(UUID.self, forKey: .id)
        self.maxMark = try container.decode(Int16.self, forKey: .maxMark)
        self.coef = try container.decode(Double.self, forKey: .coef)
        self.dateExecuted = try container.decode(Date.self, forKey: .dateExecuted)
        self.examType = try container.decode(String.self, forKey: .examType)
        self.sujet = try container.decode(String.self, forKey: .sujet)
        self.steps = try container.decode(String.self, forKey: .steps)

        self.marks = try container.decode(Set<MarkEntity>.self, forKey: .marks) as NSSet
    }

    /// Conformance to Encodable
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(maxMark, forKey: .maxMark)
        try container.encode(coef, forKey: .coef)
        try container.encode(dateExecuted, forKey: .dateExecuted)
        try container.encode(examType, forKey: .examType)
        try container.encode(sujet, forKey: .sujet)
        try container.encode(steps, forKey: .steps)

        try container.encode(marks as! Set<MarkEntity>, forKey: .marks)
    }
}
