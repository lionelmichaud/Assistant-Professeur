//
//  ProgramPlanningGraphData.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 12/07/2023.
//

import Charts
import Foundation

/// Une période d'activité d'une séquence d'un programme d'un niveau de classe.
///
/// - Note: Il peut y avoir plusieurs périodes d'activité pour une même séquence,
/// entre-coupées par une période de vacances scolaires.
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
    /// Série du graphique à laquelle appartient la période (activité / vacance)
    var serie = Serie.activity
    /// Elongation temporelle de la barre de temps à afficher
    var dateInterval = DateInterval()
    /// True si première période (barre de temps) de la séquence
    var isFirstInterval = false
    /// True si dernière période (barre de temps) de la séquence
    var isLastInterval = false

    var id: Int { number }

    // MARK: - Initializer

    /// - Parameters:
    ///   - name: Nom de la séquence
    ///   - number: Numéro de la séquence
    ///   - serie: Série du graphique à laquelle appartient la période (activité / vacance)
    ///   - dateInterval: Elongation temporelle de la barre de temps à afficher
    ///   - isFirstInterval: True si première période (barre de temps) de la séquence
    ///   - isLastInterval: True si dernière période (barre de temps) de la séquence
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
        "S\(number) - \(name)"
    }

    init?(primitivePlottable _: String) { nil }
}

/// Données nécessaires au Graphe du Planning annuel des séquences pédagogiques
struct ProgramPlanningGraphData {
    // MARK: - Properties

    /// Année scolaire et vacances scolaires
    private(set) var schoolYear: SchoolYearPref?
    /// Matière du programme
    private(set) var program: (discipline: Discipline, level: LevelClasse, segpa: Bool)?
    /// Périodes d'activité des séquences et des vacances scolaires
    private(set) var sequences = [SequenceData]()
    /// Dates d'avancement réel de chacune des classes [Acronym: Date]
    var datesClasses = [String: Date]()

    // MARK: - Initilizers

    init() {}

    init(
        forProgram program: ProgramEntity,
        schoolYear: SchoolYearPref
    ) {
        self.schoolYear = schoolYear
        self.program = (
            discipline: program.disciplineEnum,
            level: program.levelEnum,
            segpa: program.segpa
        )

        let programSequencesData = ProgramManager.getProgramSequencesPeriods(
            program: program,
            schoolYear: schoolYear
        )
        self.sequences = programSequencesData

        // Calcul des périodes de vacance de chaque séquence du programme
        program.sequencesSortedByNumber.forEach { sequence in
            // Ajout des périodes de vacances de la Séquence
            self.schoolYear!.vacances.forEach { vacance in
                self.sequences.append(
                    SequenceData(
                        name: sequence.viewName,
                        number: sequence.viewNumber,
                        serie: .vacance,
                        dateInterval: vacance.interval
                    )
                )
            }
        }
    }
}
