//
//  ProgramEntity+CoreDataClass.swift
//
//
//  Created by Lionel MICHAUD on 11/02/2023.
//
//

import CoreData
import Foundation

@objc(ProgramEntity)
public class ProgramEntity: NSManagedObject, Codable, ModelEntityP {
    enum CodingKeys: CodingKey {
        case id, discipline, level, segpa, url, annotation
        case sequences
    }

    /// Conformance to Decodable
    public required convenience init(from decoder: Decoder) throws {
        self.init(context: Self.viewContext)

        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(UUID.self, forKey: .id)
        self.discipline = try container.decode(String.self, forKey: .discipline)
        self.level = try container.decode(String.self, forKey: .level)
        self.segpa = try container.decode(Bool.self, forKey: .segpa)
        self.annotation = try container.decodeIfPresent(String.self, forKey: .annotation)
        self.url = try container.decodeIfPresent(URL.self, forKey: .url)

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

        try container.encode(sequences as! Set<SequenceEntity>, forKey: .sequences)
    }
}
