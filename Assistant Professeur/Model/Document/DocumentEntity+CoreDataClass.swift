//
//  Document+CoreDataClass.swift
//
//
//  Created by Lionel MICHAUD on 10/02/2023.
//
//

import CoreData
import Foundation

@objc(DocumentEntity)
public final class DocumentEntity: NSManagedObject, Codable, ModelEntityP {
    enum CodingKeys: CodingKey {
        case id, docName
    }

    /// Conformance to Decodable
    public required convenience init(from decoder: Decoder) throws {
        self.init(context: Self.context)

        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(UUID.self, forKey: .id)
        self.docName = try container.decode(String.self, forKey: .docName)
    }

    /// Conformance to Encodable
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(docName, forKey: .docName)
    }
}
