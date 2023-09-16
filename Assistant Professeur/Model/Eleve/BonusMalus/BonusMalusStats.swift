//
//  BonusMalusStats.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 16/09/2023.
//

import Charts
import Foundation

/// Statistiques des Bonus / Malus d'un ensemble d'élèves (Classe ou Etablissement)
struct BonusMalusStats {
    var label: String
    var min: Int
    var max: Int
    var average: Double
}

/// Libellé des statistiques sur le graphique
extension BonusMalusStats: Plottable {
    var primitivePlottable: String {
        label
    }
    init?(primitivePlottable _: String) { nil }
}
