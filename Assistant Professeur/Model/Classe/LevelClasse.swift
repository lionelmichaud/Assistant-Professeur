//
//  Niveau.swift
//  Cahier du Professeur
//
//  Created by Lionel MICHAUD on 14/04/2022.
//

import AppFoundation
import SwiftUI

/// Niveau d'une classe du CP à la Terminale
enum LevelClasse: String, PickableEnumP, Codable, Identifiable {
    case nbCP
    case naCE1
    case n9CE2
    case n8CM1
    case n7CM2
    case n6ieme
    case n5ieme
    case n4ieme
    case n3ieme
    case n2nd
    case n1ere
    case n0terminale

    var id: String {
        self.rawValue
    }

    var pickerString: String {
        switch self {
            case .nbCP: return "CP"
            case .naCE1: return "CE1"
            case .n9CE2: return "CE2"
            case .n8CM1: return "CM1"
            case .n7CM2: return "CM2"
            case .n6ieme: return "6ième"
            case .n5ieme: return "5ième"
            case .n4ieme: return "4ième"
            case .n3ieme: return "3ième"
            case .n2nd: return "2nd"
            case .n1ere: return "1ère"
            case .n0terminale: return "Terminale"
        }
    }

    var displayString: String {
        switch self {
            case .nbCP: return "CP"
            case .naCE1: return "CE1-"
            case .n9CE2: return "CE2-"
            case .n8CM1: return "CM1-"
            case .n7CM2: return "CM2-"
            case .n6ieme: return "6E"
            case .n5ieme: return "5E"
            case .n4ieme: return "4E"
            case .n3ieme: return "3E"
            case .n2nd: return "2E"
            case .n1ere: return "1E"
            case .n0terminale: return "T"
        }
    }

    var imageColor: Color {
        switch self {
            case .nbCP: return ColorOptions.all[0]
            case .naCE1: return ColorOptions.all[1]
            case .n9CE2: return ColorOptions.all[2]
            case .n8CM1: return ColorOptions.all[3]
            case .n7CM2: return ColorOptions.all[4]
            case .n6ieme: return ColorOptions.all[0]
            case .n5ieme: return ColorOptions.all[1]
            case .n4ieme: return ColorOptions.all[2]
            case .n3ieme: return ColorOptions.all[3]
            case .n2nd: return ColorOptions.all[4]
            case .n1ere: return ColorOptions.all[5]
            case .n0terminale: return ColorOptions.all[6]
        }
    }

    var sortOrder: Int {
        switch self {
            case .nbCP: return 1
            case .naCE1: return 2
            case .n9CE2: return 3
            case .n8CM1: return 4
            case .n7CM2: return 5
            case .n6ieme: return 6
            case .n5ieme: return 7
            case .n4ieme: return 8
            case .n3ieme: return 9
            case .n2nd: return 10
            case .n1ere: return 11
            case .n0terminale: return 12
        }
    }

    func isCompatible(
        withSchool school: SchoolEntity
    ) -> Bool {
        switch self {
            case .nbCP, .naCE1, .n9CE2, .n8CM1, .n7CM2:
                return school.levelEnum == .aecole

            case .n6ieme, .n5ieme, .n4ieme, .n3ieme:
                return school.levelEnum == .college

            case .n2nd, .n1ere, .n0terminale:
                return school.levelEnum == .lycee
        }
    }
}
