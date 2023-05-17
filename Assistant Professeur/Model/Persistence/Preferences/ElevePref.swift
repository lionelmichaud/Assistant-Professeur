//
//  ElevePref.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 17/05/2023.
//

import Foundation

struct ElevePref: Codable {
    /// Champ appéciation
    var appreciationEnabled: Bool = true
    /// Champ annotation
    var annotationEnabled: Bool = true
    /// Champ trombine
    var trombineEnabled: Bool = true
    /// Champ bonus / malus
    var bonusEnabled: Bool = true
    var maxBonusMalus: Int = 100
    var maxBonusIncrement: Int = 1
}
