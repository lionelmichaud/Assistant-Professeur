//
//  DailySchedulePref.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 17/05/2023.
//

import Foundation

struct DailySchedulePref: Codable {
    /// Durée d'une séance de cours en minutes
    var seanceDuration: Int = 55

    /// Durée inter-cours en minutes
    var interSeancesDuration: Int = 0

    /// Durée de la récréation en minutes
    var recreationDuration: Int = 20

    /// Durée de la pause déjeuner en minutes
    var lunchDuration: Int = 75

    /// Heure du début de la journée de cours
    var hourOfFirstSeance: Int = 8
    var minutesOfFirstSeance: Int = 15
}
