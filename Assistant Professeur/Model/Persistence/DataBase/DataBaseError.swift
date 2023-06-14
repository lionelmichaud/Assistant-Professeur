//
//  DataBaseError.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 07/06/2023.
//

import Foundation

/// Erreur dans la base de donnée
enum DataBaseError: LocalizedError {
    case some(entity: String, name: String, id: UUID?)
    case noOwner(entity: String, name: String, id: UUID?)
    case outOfBound(entity: String, name: String, attribute: String, id: UUID?)
    case internalInconsistency(entity: String, name: String, attribute1: String, attribute2: String, id: UUID?)

    public var errorDescription: String? {
        switch self {
            case let .some(entity, name, _):
                return "L'objet de type \(entity) '\(name)' présente une erreur."

            case let .noOwner(entity, name, _):
                return "L'objet de type \(entity) '\(name)' est orphelin."

            case let .outOfBound( entity, name, attribute, _):
                return "L'objet de type \(entity) '\(name)' possède un attribut '\(attribute)' hors limites."

            case let .internalInconsistency( entity, name, attribute1, attribute2, _):
                return "L'objet de type \(entity) '\(name)' possède une valeur d'attribut '\(attribute1)' incompatible de la valeur de l'attribut '\(attribute2)'."
        }
    }

    public var failureReason: String? {
        switch self {
            default: return ""
        }
    }

    public var recoverySuggestion: String? {
        switch self {
            case .some:
                return ""

            case let .noOwner(entity, name, _):
                return "Supprimer l'objet de type \(entity) '\(name)'."

            case let .outOfBound(entity, name, attribute, _):
                return "Modifier la valeur de l'attribut'\(attribute)' hors limites pour \(entity) '\(name)'."

            case let .internalInconsistency(entity, name, attribute1, attribute2, _):
                return "Modifier une des valeurs des attributs '\(attribute1)' ou '\(attribute2)' pour \(entity) '\(name)'."
        }
    }
}

extension DataBaseError: CustomStringConvertible {
    var description: String {
        localizedDescription
    }
}

typealias DataBaseErrorList = [DataBaseError]
