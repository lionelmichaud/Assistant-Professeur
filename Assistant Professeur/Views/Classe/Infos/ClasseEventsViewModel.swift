//
//  ClasseEventsViewModel.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 05/11/2023.
//

import EventKit
import Foundation

@MainActor
@Observable final class ClasseEventsViewModel {
    /// Avancement de la recherche des événements
    private(set) var state: LoadingFromCalendarStatus = .pending
    private(set) var conseils = [EKEvent]()
    private(set) var arretsNotes = [EKEvent]()
    private(set) var brevet: EKEvent?
    private(set) var bac: EKEvent?

    /// Récupérer les événements de la classe dans l'appli "Calendrier"
    func getAllEvents(
        forClasse classe: ClasseEntity,
        during schoolYear: SchoolYearPref,
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
            during: schoolYear.interval,
            after: thisEarliestdate
        )
        // Récupérer les dates de conseils de classe
        conseils = EventManager.getAllConseils(
            forClasseName: classe.displayString,
            inCalendar: calendar,
            inEventStore: eventStore,
            during: schoolYear.interval,
            after: thisEarliestdate
        )

        if classe.levelEnum == .n3ieme || classe.levelEnum == .n0terminale {
            // Demander les droits d'accès aux calendriers de l'utilisateur
            var schoolYearcalendar: EKCalendar?
            (
                schoolYearcalendar,
                alert.isPresented,
                alert.title,
                alert.message
            ) = await EventManager.shared
                .requestCalendarAccess(
                    eventStore: eventStore,
                    calendarName: schoolYear.calName
                )
            guard let schoolYearcalendar else {
                self.state = .failed
                return alert
            }

            if classe.levelEnum == .n3ieme {
                // Récupérer les dates du brevet des collèges
                brevet = EventManager.getBrevet(
                    inCalendar: schoolYearcalendar,
                    inEventStore: eventStore,
                    during: schoolYear.interval
                )
            } else if classe.levelEnum == .n0terminale {
                // Récupérer les dates du baccalauréat
                bac = EventManager.getBac(
                    inCalendar: schoolYearcalendar,
                    inEventStore: eventStore,
                    during: schoolYear.interval
                )
            }
        }

        self.state = .finished
        return alert
    }
}
