//
//  ClasseEventsViewModel.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 05/11/2023.
//

import EventKit
import Foundation

@MainActor
class ClasseEventsViewModel: ObservableObject {
    /// Avancement de la recherche des contacts
    @Published
    private(set) var state: LoadingFromCalendarStatus = .pending

    @Published
    private(set) var conseils = [EKEvent]()

    @Published
    private(set) var arretsNotes = [EKEvent]()

    /// Récupérer les événements de la classe dans l'appli "Calendrier"
    func getAllEvents(
        forClasse classe: ClasseEntity,
        during schoolYear: DateInterval,
        after thisEarliestdate: Date? = nil
    ) async -> AlertInfo {
        self.state = .pending

        var alert = AlertInfo()

        guard let school = classe.school else {
            self.state = .failed
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
                calendarName: school.viewName
            )
        guard let calendar else {
            self.state = .failed
            return alert
        }

        // Récupérer les dates d'arrêt des notes avant conseils de classe
        arretsNotes = EventManager.getAllArretsNotes(
            forClasseLevel: classe.levelEnum,
            inCalendar: calendar,
            inEventStore: eventStore,
            during: schoolYear,
            after: thisEarliestdate
        )
        // Récupérer les dates de conseils de classe
        conseils = EventManager.getAllConseils(
            forClasseName: classe.displayString,
            inCalendar: calendar,
            inEventStore: eventStore,
            during: schoolYear,
            after: thisEarliestdate
        )
        self.state = .finished
        return alert
    }
}
