//
//  Zones.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 16/05/2023.
//

import Foundation
import AppFoundation

enum ZoneScolaire: PickableEnumP, Codable {
    case zoneA
    case ZoneB
    case ZoneC

    var pickerString: String {
        switch self {
            case .zoneA:
                return "Zone A"
            case .ZoneB:
                return "Zone B"
            case .ZoneC:
                return "Zone C"
        }
    }

    var academy: String {
        switch self {
            case .zoneA:
                return "Académies de Besançon, Bordeaux, Clermont-Ferrand, Dijon, Grenoble, Limoges, Lyon et Poitiers"
            case .ZoneB:
                return "Académies d'Aix-Marseille, Amiens, Caen, Lille, Nancy-Metz, Nantes, Nice, Orléans-Tours, Reims, Rennes, Rouen et Strasbourg"
            case .ZoneC:
                return "Académies de Créteil, Montpellier, Paris, Toulouse et Versailles"
        }
    }
}
