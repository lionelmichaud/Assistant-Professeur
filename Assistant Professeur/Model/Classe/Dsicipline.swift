//
//  Dsicipline.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 23/12/2022.
//

import AppFoundation
import Foundation

/// Discipline d'enseignement
enum Discipline: String, PickableIdentifiableEnumP, Codable {
    case allemand
    case anglais
    case artPla
    case espagnol
    case francais
    case histoireGeo
    case latin
    case mathematiques
    case musique
    case nsi
    case physique
    case snt
    case svt
    case technologie
    case autre

    var id: String {
        rawValue
    }

    var pickerString: String {
        switch self {
            case .technologie:
                return "Technologie"
            case .mathematiques:
                return "Mathématiques"
            case .physique:
                return "Physique-Chimie"
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
                return "Arts Plastiques"
            case .svt:
                return "SVT"
            case .nsi:
                return "NSI"
            case .autre:
                return "Autre"
        }
    }
}
