//
//  Eleve+ItemProvider.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 10/04/2023.
//

import Foundation

extension EleveEntity: NSItemProviderWriting {
    static let typeIdentifier = "com.michaud.lionel.Assistant-Professeur.eleve"

    public static var writableTypeIdentifiersForItemProvider: [String] {
        [typeIdentifier]
    }

    public func loadData(
        withTypeIdentifier _: String,
        forItemProviderCompletionHandler completionHandler: @escaping @Sendable (Data?, Error?) -> Void
    ) -> Progress? {
        do {
            // 5
            let encoder = JSONEncoder()
            encoder.outputFormatting = .prettyPrinted
            completionHandler(try encoder.encode(self), nil)
        } catch {
            // 6
            completionHandler(nil, error)
        }

        // 7
        return nil
    }
}

extension EleveEntity: NSItemProviderReading {
    // 1
    public static var readableTypeIdentifiersForItemProvider: [String] {
        [typeIdentifier]
    }

    // 2
    public static func object(
        withItemProviderData data: Data,
        typeIdentifier: String
    ) throws -> EleveEntity {
        // 3
        let decoder = JSONDecoder()
        return try decoder.decode(EleveEntity.self, from: data)
    }
}
