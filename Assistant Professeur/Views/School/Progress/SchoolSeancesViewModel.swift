//
//  SchoolSeancesViewModel.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 04/11/2023.
//

import EventKit
import SwiftUI

@MainActor
@Observable final class SchoolSeancesViewModel {
    private(set) var seancesLoadingState: SeancesLoadingStatus = .pending
    
    /// Recherche des séances dans la tranche de temps `dateInterval`
    /// pour l'établissement `school`.
    /// - Parameters:
    ///   - school: Uniquement pour cet établissement.
    ///   - dateInterval: Tranche de temps où rechercher.
    ///   - showOnlyOngoingSeance: Si vrai alors ne concernver que la séance en cours.
    ///   - schoolYear: Périodes scolaires.
    /// - Returns: Alerte si nécessaire.
    func updateItems(
        forSchool school: SchoolEntity,
        inDateInterval dateInterval: DateInterval,
        showOnlyOngoingSeance: Bool,
        schoolYear: SchoolYearPref
    ) async -> AlertInfo {
        self.seancesLoadingState = .pending

        var alert = AlertInfo()
        let schoolName = school.viewName

        // Demander les droits d'accès aux calendriers de l'utilisateur
        let eventStore = EKEventStore()
        var calendar: EKCalendar?
        (
            calendar,
            alert.isPresented,
            alert.title,
            alert.message
        ) = await EventManager.shared
            .requestCalendarAccess(
                eventStore: eventStore,
                calendarName: schoolName
            )
        guard let calendar else {
            seancesLoadingState = .failed
            return alert
        }

        seancesLoadingState = .loading

        // Recherche: `SeancesInDateInterval` contenant la liste des Séances à venir
        // pour toutes classes d'un établissement avec le contenu pédagogique de chaque séance.
        let schoolSeances = await SeancesInDateInterval
            .nextSeancesForSchool(
                school: school,
                inCalendar: calendar,
                inEventStore: eventStore,
                inDateInterval: dateInterval,
                schoolYear: schoolYear
            )

        if showOnlyOngoingSeance {
            // Filtrer pour ne garder que la séance en cours
            let filteredSeances =
                SeancesInDateInterval(
                    from: schoolSeances
                        .seances
                        .filter { seance in
                            seance.interval.contains(Date.now)
                        })
            seancesLoadingState = .finished(seancesInInterval: filteredSeances)

        } else {
            seancesLoadingState = .finished(seancesInInterval: schoolSeances)
        }

        return alert
    }
}
