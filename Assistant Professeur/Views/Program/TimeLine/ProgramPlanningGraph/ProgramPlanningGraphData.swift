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
    // MARK: - Nested Types

    /// Séries du graphiques
    enum Serie: String, Plottable {
        case activity = "Activité"
        case vacance = "Vacance"
    }

    // MARK: - Properties

    /// Nom de la séquence
    var name: String = ""
    /// Numéro de la séquence
    var number: Int = 1
    var serie = Serie.activity
    /// Elongation de la barre de temps à afficher
    var dateInterval = DateInterval()
    /// Première barre de tmps
    var isFirstInterval = false
    /// Dernière barre de tmps
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

/// Libellé des séquences sur le graphique
extension SequenceData: Plottable {
    var primitivePlottable: String {
        "S\(number) \(name)"
    }

    init?(primitivePlottable _: String) { nil }
}

/// Données nécessaires au Graph du Planning annuel des séquences pédagogiques
struct ProgramPlanningGraphData {
    // MARK: - Properties

    /// Période et vacances scolaires
    var schoolYear = SchoolYearPref()
    /// Intervalles d'activité des séquences
    var sequences = [SequenceData]()

    // MARK: - Initilizers

    init() {}

    init(schoolYear: SchoolYearPref) {
        self.schoolYear = schoolYear
    }
}
