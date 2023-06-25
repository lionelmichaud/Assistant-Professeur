//
//  Mastery.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 25/06/2023.
//

import AppFoundation
import Foundation
import SwiftUI

/// Niveau de maîtrise d'une compétence par un élève
enum MasteryLevel: Int, PickableEnumP, Codable, Identifiable {
    case insuffisant = 0
    case fragile
    case satisfaisant
    case tresBonneMaitrise

    var id: Int {
        self.rawValue
    }

    var levelIndex: Int {
        self.rawValue
    }

    var pickerString: String {
        switch self {
            case .insuffisant: return "Insuffisant"
            case .fragile: return "Fragile"
            case .satisfaisant: return "Satisfaisant"
            case .tresBonneMaitrise: return "Tres Bonne Maîtrise"
        }
    }

    var imageColor: Color {
        switch self {
            case .insuffisant: return .red
            case .fragile: return .orange
            case .satisfaisant: return .yellow
            case .tresBonneMaitrise: return .green
        }
    }
}

/// Dictionnaire des définitions des niveaux de maîtrise d'une compétence
typealias MasteryLevelDictionary = [MasteryLevel: String]

extension MasteryLevelDictionary {
    /// Initialize le dictionnaire avec un élément pas niveau de maîtrise.
    /// Chaque niveau de maîtrise aura une définition "indéfini"
    init() {
        self = [:]
        MasteryLevel.allCases.forEach { level in
            self[level] = "indéfini"
        }
    }
}
