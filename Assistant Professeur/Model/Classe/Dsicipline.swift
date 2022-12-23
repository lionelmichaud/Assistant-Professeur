//
//  Dsicipline.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 23/12/2022.
//

import Foundation
import AppFoundation

/// Discipline d'enseignement
enum Discipline: Int16, PickableEnumP, Codable {
    case technologie
    case mathematiques
    case physique
    case histoireGeo
    case francais
    case anglais
    case espagnol
    case allemand
    case latin
    case musique
    case artPla
    case snt

    var pickerString: String {
        switch self {
            case .technologie:
                return "Technologie"
            case .mathematiques:
                return "Mathématiques"
            case .physique:
                return "Physique"
            case .snt:
                return "SNT"
            case .histoireGeo:
                return "Histoire-Géographie"
            case .francais:
                return "Français"
            case .anglais:
                return "Anglais"
            case .espagnol:
                return "Espagnol"
            case .allemand:
                return "Allemand"
            case .latin:
                return "Latin"
            case .musique:
                return "Musique"
            case .artPla:
                return "Art Plastique"
        }
    }
}
