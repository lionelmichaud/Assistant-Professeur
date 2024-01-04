//
//  ClasseSeancesViewModel.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 05/11/2023.
//

import EventKit
import SwiftUI

@MainActor
@Observable final class ClasseSeancesViewModel {
    private(set) var state: SeancesLoadingStatus = .pending
    
    var seancesListView: some View {
        state.view
    }

    /// Recherche des séances dans la tranche de temps `dateInterval`
    /// pour l'établissement `school`.
    /// - Parameters:
    ///   - classe: Uniquement pour cette classe.
    ///   - dateInterval: Tranche de temps où rechercher.
    ///   - schoolYear: Périodes scolaires.
    /// - Returns: Alerte si nécessaire.
    func updateItems(
        forClasse classe: ClasseEntity,
        inDateInterval dateInterval: DateInterval,
        schoolYear: SchoolYearPref
    ) async -> AlertInfo {
        self.state = .pending

        var alert = AlertInfo()
        guard let schoolName = classe.school?.viewName else {
            state = .failed
            return alert // silently fail
        }

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
            state = .failed
            return alert
        }

        state = .loading

        // Recherche: `SeancesInDateInterval` contenant la liste des Séances à venir
        // pour toutes classes d'un établissement avec le contenu pédagogique de chaque séance.
        let classeSeances = SeancesInDateInterval
            .nextSeancesForClasse(
                schoolName: schoolName,
                classe: classe,
                inCalendar: calendar,
                inEventStore: eventStore,
                inDateInterval: dateInterval, 
                schoolYear: schoolYear
            )

        state = .finished(seancesInInterval: classeSeances)
        return alert
    }
}
