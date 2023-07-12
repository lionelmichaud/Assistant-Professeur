//
//  ProgramPlanningGraphData.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 12/07/2023.
//

import Charts
import Foundation

/// Intervalle d'activité d'une séquence
struct SequenceData: Identifiable {
    // MARK: - Types

    enum Serie: String, Plottable {
        case activity = "Activité"
        case vacance = "Vacance"
    }

    var name: String = ""
    var number: Int = 1
    var serie = Serie.activity
    var dateInterval = DateInterval()
    var isFirstInterval = false
    var isLastInterval = false

    var id: Int { number }

    // MARK: - Initializer

    internal init(
        name: String = "",
        number: Int = 1,
        serie: Serie = .activity,
        dateInterval: DateInterval = DateInterval(),
        isFirstInterval: Bool = false,
        isLastInterval: Bool = false
    ) {
        self.name = name
        self.number = number
        self.serie = serie
        self.dateInterval = dateInterval
        self.isFirstInterval = isFirstInterval
        self.isLastInterval = isLastInterval
    }
}

extension SequenceData: Plottable {
    var primitivePlottable: String {
        "S\(number) \(name)"
    }
    init?(primitivePlottable _: String) { nil }
}

/// Données nécessaires au Graph du Planning annuel des séquences pédagogiques
struct ProgramPlanningGraphData {
    // MARK: - Properties

    var schoolYear = SchoolYearPref()
    var sequences = [SequenceData]()

    // MARK: - Initilizers

    init() {}

    init(schoolYear: SchoolYearPref) {
        self.schoolYear = schoolYear
    }
}
