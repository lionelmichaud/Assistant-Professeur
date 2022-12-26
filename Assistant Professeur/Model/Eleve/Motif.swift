//
//  Motif.swift
//  Cahier du Professeur
//
//  Created by Lionel MICHAUD on 25/04/2022.
//

import Foundation
import AppFoundation

enum MotifEnum: Int16, PickableEnumP, Codable {
    case defautDeCarnet = 0
    case attitudeIndaptee
    case bavardage
    case devoirNonrendu
    case leconNonApprise
    case oubliDeMateriel
    case travailNonFait
    case autre

    var pickerString: String {
        switch self {
            case .defautDeCarnet:
                return "Défaut de carnet"
            case .attitudeIndaptee:
                return "Attitude indaptée"
            case .bavardage:
                return "Bavardage"
            case .devoirNonrendu:
                return "Devoir non rendu"
            case .leconNonApprise:
                return "Leçon non apprise"
            case .oubliDeMateriel:
                return "Oubli de matériel"
            case .travailNonFait:
                return "Travail non fait"
            case .autre:
                return "Autre"
        }
    }
}

struct Motif: Codable, Hashable {
    var nature           : MotifEnum = .autre
    var descriptionMotif : String    = "motif"
}

extension Motif: CustomStringConvertible {
    var description: String {
        let natureStr = nature.displayString
        return nature == .autre ? natureStr + "\n \(descriptionMotif)" : natureStr
    }
}
