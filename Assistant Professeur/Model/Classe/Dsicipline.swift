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
    case technologie
    case artPla
    case francais
    case histoireGeo
    case latin
    case lv1
    case lv2
    case mathematiques
    case musique
    case nsi
    case physique
    case si
    case snt
    case svt
    case general
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
            case .latin:
                return "Latin"
            case .lv1:
                return "Langue vivante 1"
            case .lv2:
                return "Langue vivante 2"
            case .musique:
                return "Musique"
            case .artPla:
                return "Arts Plastiques"
            case .si:
                return "Sciences de l'Ingénieur"
            case .svt:
                return "SVT"
            case .nsi:
                return "NSI"
            case .autre:
                return "Autre"
            case .general:
                return "Ens. Générale"
        }
    }

    var acronym: String {
        switch self {
            case .technologie:
                return "TECHNO"
            case .mathematiques:
                return "MATH"
            case .physique:
                return "P-C"
            case .snt:
                return "SNT"
            case .histoireGeo:
                return "H-G"
            case .francais:
                return "FR"
            case .latin:
                return "LAT"
            case .lv1:
                return "LV1"
            case .lv2:
                return "LV2"
            case .musique:
                return "MUS"
            case .artPla:
                return "ARTPLA"
            case .si:
                return "SI"
            case .svt:
                return "SVT"
            case .nsi:
                return "NSI"
            case .general:
                return "GEN"
            case .autre:
                return "Autre"
        }
    }
    
    func nbHeurePerWeek(level: LevelClasse) -> Double {
        // TODO: - Adapter en fonction du niveau de la classe
        switch self {
            case .artPla: return 1
            case .francais: return 4.5
            case .histoireGeo: return 3
            case .latin: return 1
            case .lv1: return 3
            case .lv2: return 2.5
            case .mathematiques: return 3.5
            case .musique: return 1
            case .nsi: return 2
            case .physique: return 1.5
            case .si: return 1.5
            case .snt: return 1.5
            case .svt: return 1.5
            case .technologie: return 1.5
            case .general: return 26
            case .autre: return 1
        }
    }
}
