//
//  ExamTypeEnum.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 29/01/2023.
//

import Foundation
import AppFoundation

/// Nature d'une évaluation
enum ExamTypeEnum: String, PickableIdentifiableEnumP, Codable {
    case global
    case multiStep

    var pickerString: String {
        switch self {
            case .global:
                return "Globale"
            case .multiStep:
                return "Echelonnée"
        }
    }

    var id: String {
        rawValue
    }
}
