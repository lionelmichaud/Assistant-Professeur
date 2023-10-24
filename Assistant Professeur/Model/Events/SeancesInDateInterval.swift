//
//  DateIntervalSeances.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 06/07/2023.
//

import EventKit
import Foundation
import SwiftUI

// Proxy vers DateIntervalSeances
// Refer to : [Calling Mutating Async Functions from SwiftUI Views](https://diegolavalle.com/posts/2022-11-29-calling-mutating-async-functions/)
// @MainActor
// extension Binding where Value == SeancesInDateInterval {
//    func loadSeancesFromCalendar(
//        forDiscipline discipline: Discipline,
//        forSchoolName school: String,
//        forClasse classe: String,
//        inCalendar calendar: EKCalendar,
//        inEventStore eventStore: EKEventStore,
//        during period: DateInterval,
//        schoolYear: SchoolYearPref
//    ) async {
//        await wrappedValue.loadSeancesFromCalendar(
//            forDiscipline: discipline,
//            forSchoolName: school,
//            forClasseName: classe,
//            inCalendar: calendar,
//            inEventStore: eventStore,
//            during: period, 
//            schoolYear: schoolYear
//        )
//    }
// }

/// Un cours et son contenu en activités pédagogique.
/// Plusieurs activités peuvent être abordées pendant le même cours.
struct Seance: Identifiable, CustomStringConvertible {
    var id = UUID()
    /// Acronym de la classe concernée par la séance ou nom de la période de vacance
    var name: String?
    /// Nom de l'établissement
    var schoolName: String?
    /// Interval de temps correspondant à la séance
    var interval: DateInterval
    /// Activité pédagogique menée pendant la séance
    var activities = [ActivityEntity]()
    /// True si cette séance est en réalité une période de vacance
    var isVacance: Bool = false

    var description: String {
        """

        SEANCE:
           Etablissement    : \(String(describing: self.schoolName))
           Nom              : \(String(describing: self.name))
           Plage temporelle : \(String(describing: interval))
           Vacances         : \(isVacance.frenchString)
           Nb d'activités   : \(activities.count)
           Activités  : \(String(describing: activities).withPrefixedSplittedLines("     "))
        """
    }
}

/// Suite de séances (cours) pour une classe donnée et sur un horizon de temps donné.
/// Recherche dans l'App Calendar les séances à venir d'une classe.
/// - Warning: A utiliser avec le proxy ci-dessus
///
/// Refer to : [Calling Mutating Async Functions from SwiftUI Views](https://diegolavalle.com/posts/2022-11-29-calling-mutating-async-functions/)
struct SeancesInDateInterval {
    // MARK: - Properties

    /// Séances de la période
    var seances: [Seance]

    // MARK: - Initializers

    /// Initiialize une suite de séances vide (ne contenant aucune séance)
    init() {
        self.seances = [Seance]()
    }

    /// Initiialize une suite de séances avec pour contenu initial les `seances`.
    init(from seances: [Seance]) {
        self.seances = seances
    }

    // MARK: - Subscript

    subscript(idx: Int) -> Seance {
        get {
            self.seances[idx]
        }
        set {
            self.seances[idx] = newValue
        }
    }

    // MARK: - Methods

    /// Charge depuis l'App Calendar toutes les séance de la `period` pour les
    /// `discipline`, `classe` et `school`. Les périodes de vacances scolaires sont
    /// touvées dans `schoolYear`.
    /// - Important: Élimine toutes les séances trouvées tombant pendant les vacances scolaires.
    /// - Parameters:
    ///   - discipline: La discipline recherchée.
    ///   - school: Le nom de l'école recherchée.
    ///   - classe: Le nom de la classe recherchée.
    ///   - calendar: Calendrier à utiliser dans l'application Calendrier.
    ///   - eventStore: Le store des événements du calendrier.
    ///   - period: Intervalle de temps de recherche.
    ///   - schoolYear: Calendrier de l'année scolaires (début, fin, vacances).
    mutating func loadClasseSeancesFromCalendar( // // swiftlint:disable:this function_parameter_count
        forDiscipline discipline: Discipline,
        forSchoolName school: String,
        forClasseName classe: String,
        inCalendar calendar: EKCalendar,
        inEventStore eventStore: EKEventStore,
        during period: DateInterval,
        schoolYear: SchoolYearPref
    ) {
        self.seances = EventManager.getAllSeances(
            forDiscipline: discipline,
            forClasseName: classe,
            inCalendar: calendar,
            inEventStore: eventStore,
            during: period
        ).compactMap { event in
            if !schoolYear.vacancesContain(
                period: .init(
                    start: event.startDate,
                    end: event.endDate
                )
            ) {
                return Seance(
                    name: classe,
                    schoolName: school,
                    interval: DateInterval(
                        start: event.startDate,
                        end: event.endDate
                    )
                )
            } else {
                // Élimine toutes les séances tombant pendant les vacances scolaires prévue des les péréfrences
                return nil
            }
        }
    }
    /// Retourne un objet `SeancesInDateInterval` contenant la liste des Séances à venir
    /// pour toutes classes d'un établissement avec le contenu pédagogique de chaque séance.
    static func loadedNextSeancesForSchool(
        schoolClasses: [ClasseEntity],
        schoolName: String,
        inCalendar calendar: EKCalendar,
        inEventStore eventStore: EKEventStore,
        overHorizon horizon: Int
    ) async -> SeancesInDateInterval {
        var foundSeances = [Seance]()

        await withTaskGroup(of: [Seance].self) { group in
            for classe in schoolClasses {
                group.addTask {
                    var sortedClasseProgresses = [ActivityProgressEntity]()
                    var classeSeances = SeancesInDateInterval()
                    var forDiscipline = Discipline.autre
                    var forClasseName = ""
                    var schoolYear = SchoolYearPref()

                    await ClasseEntity.context.perform {
                        // Liste des Progressions de la classe triée par numéro de Séquence / Activité
                        sortedClasseProgresses = classe.allProgressesSortedBySequenceActivityNumber
                        forDiscipline = classe.disciplineEnum
                        forClasseName = classe.displayString
                        schoolYear = UserPrefEntity.shared.viewSchoolYearPref
                    }

                    let horizon = DateInterval(
                        start: Date.now,
                        end: horizon.months.fromNow!
                    )

                    // Liste des Séances à venir pour cette classe
                    classeSeances.loadClasseSeancesFromCalendar(
                        forDiscipline: forDiscipline,
                        forSchoolName: schoolName,
                        forClasseName: forClasseName,
                        inCalendar: calendar,
                        inEventStore: eventStore,
                        during: horizon,
                        schoolYear: schoolYear
                    )

                    await ClasseEntity.context.perform {
                        // Synchroniser les Progressions de la classe avec les Séances de la classe
                        SequenceSeanceCoordinator.synchronize(
                            classeSeances: &classeSeances,
                            withProgresses: sortedClasseProgresses
                        )
                    }

                    return classeSeances.seances
                }
            }
            for await seances in group {
                foundSeances.append(contentsOf: seances)
            }
        }

        // remettre les séances dans l'ordre (async => désordre)
        foundSeances.sort(by: {
            $0.interval.start < $1.interval.start
        })

        return .init(from: foundSeances)
    }

    func print() {
        Swift.print(self.seances)
    }
}
