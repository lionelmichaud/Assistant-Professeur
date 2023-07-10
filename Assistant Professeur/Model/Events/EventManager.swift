//
//  EventManager.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 15/05/2023.
//

import EventKit
import Foundation
import os

private let customLog = Logger(
    subsystem: "com.michaud.lionel.Assistant-Professeur",
    category: "EventManager"
)

/// Gestionnaire d'Evénements. Synchronize l'appli avec l'app Calendrier.
enum EventManager {
    /// Retourne la liste de tous les événements du clalendrier `calName`
    /// survenant dans la `period` et dont le titre contient **"Conseil - `classe`"**.
    /// - Parameters:
    ///   - classe: Acronym de la classe recherchée.
    ///   - calName: Nom du calendrier où ajouter l'événement.
    ///   - schoolYear: Intervalle de temps de l'année scolaire en cours.
    /// - Important: Convention de nommage:
    ///     Nom du calendrier = **Nom de l'établissement**
    ///     Titre de l'événement = **"Conseil - \(classe)"**
    ///     où **classe** = 5E2S
    static func getAllConseils(
        forClasseName classe: String,
        inCalendarNamed calName: String,
        during schoolYear: DateInterval
    ) async -> [EKEvent] {
        let eventName = "Conseil - \(classe)"

        return await getEvents(
            withTitleIncluding: eventName,
            inCalendarNamed: calName,
            startDate: schoolYear.start,
            endDate: schoolYear.end
        )
    }

    /// Retourne la liste de tous les événements du clalendrier `calName`
    /// survenant dans la `period` et dont le titre contient "`discipline` - `classe`".
    /// - Parameters:
    ///   - discipline: La discipline recherchée.
    ///   - classe: Acronym de la classe recherchée.
    ///   - calName: Nom du calendrier où ajouter l'événement.
    ///   - period: Intervalle de temps de recherche.
    /// - Important: Convention de nommage:
    ///  * Nom du calendrier = **Nom de l'établissement**
    ///  * Titre de l'événement = **"discipline - \(classe)"**
    ///  * où **discipline** = "TECHNO"
    ///  * et **classe** =" 5E2S"
    static func getAllSeances(
        forDiscipline discipline: Discipline,
        forClasseName classe: String,
        inCalendarNamed calName: String,
        during period: DateInterval
    ) async -> [EKEvent] {
        let eventName = "\(discipline.acronym) - \(classe)"

        return await getEvents(
            withTitleIncluding: eventName,
            inCalendarNamed: calName,
            startDate: period.start,
            endDate: period.end
        )
    }

    /// Retourne la liste de tous les événements du clalendrier `calName`
    /// de la journée en cours et dont  le titre contient "`discipline` - `classe`".
    /// - Parameters:
    ///   - discipline: La discipline recherchée.
    ///   - classe: Acronym de la classe recherchée.
    ///   - calName: Nom du calendrier où ajouter l'événement.
    /// - Important: Convention de nommage:
    ///  * Nom du calendrier = **Nom de l'établissement**
    ///  * Titre de l'événement = **"discipline - \(classe)"**
    ///  * où **discipline** = "TECHNO"
    ///  * et **classe** =" 5E2S"
    static func getTodaySeances(
        forDiscipline discipline: Discipline,
        forClasse classe: String,
        inCalendarNamed calName: String
    ) async -> [EKEvent] {
        let startOfDay = Calendar.current.startOfDay(for: .now)
        let secondsInOneDay = 60 * 60 * 24.0
        let endOfDay = startOfDay.addingTimeInterval(secondsInOneDay)
        let eventName = "\(discipline.acronym) - \(classe)"

        return await getEvents(
            withTitleIncluding: eventName,
            inCalendarNamed: calName,
            startDate: startOfDay,
            endDate: endOfDay
        )
    }

    /// Retourne la liste de tous les événements du clalendrier `calName`
    /// de la journée en cours.
    /// - Parameters:
    ///   - calName: Nom du calendrier où ajouter l'événement.
    static func getTodaySeances(
        inCalendarNamed calName: String
    ) async -> [EKEvent] {
        let startOfDay = Calendar.current.startOfDay(for: .now)
        let oneDay = 60 * 60 * 24.0
        let endOfDay = startOfDay.addingTimeInterval(oneDay)

        return await getEvents(
            inCalendarNamed: calName,
            startDate: startOfDay,
            endDate: endOfDay
        )
    }

    /// Retourne la liste de tous les événements entre `startDate` et `endDate`
    /// du clalendrier `calName` dont le titre contient `title`.
    ///
    /// Si `title` = `nil` alors ne tient pas compte de ce filtre.
    static func getEvents(
        withTitleIncluding title: String? = nil,
        inCalendarNamed calName: String,
        // inEventStore eventStore: EKEventStore,
        startDate: Date,
        endDate: Date
    ) async -> [EKEvent] {
        let eventStore = EKEventStore()
        // eventStore.reset()
        do {
            let granted = try await eventStore.requestAccess(to: .event)

            // Find the calendar named `calName`
            guard let myCalendar = try getOrCreateCalendar(
                named: calName,
                inEventStore: eventStore
            ) else {
                return []
            }

            let predicate = eventStore.predicateForEvents(
                withStart: startDate,
                end: endDate,
                calendars: [myCalendar]
            )

            let existingEvents = eventStore.events(matching: predicate)
            if let title {
                let selectedEvents = existingEvents.filter { event in
                    event.title.contains(title)
                }
                return selectedEvents
            } else {
                return existingEvents
            }

        } catch {
            customLog.log(
                level: .error,
                "Error accessing events: \(error.localizedDescription)"
            )
            return []
        }
    }

    /// Updates or saves an event to the Calendar app in the calendar named `calName`
    ///
    /// If the calendar named `calName` does not exist, creates the calendar.
    ///
    /// If the event already exists, updates the event, else, creates the event.
    /// - Parameters:
    ///   - eventTitle: Nom de l'événement.
    ///   - eventDateInterval: Intervalle de temps de l'événement.
    ///   - calName: Nom du calendrier où ajouter l'événement.
    ///   - period: Intervalle de temps de recherche.
    /// - Returns: True si l'enregistrement à réussi.
    static func saveOrUpdate(
        eventTitle: String,
        eventDateInterval: DateInterval,
        toCalendarNamed calName: String,
        during period: DateInterval
    ) async -> Bool {
        let eventStore = EKEventStore()
        do {
            try await eventStore.requestAccess(to: .event)

            // Find the calendar named `calName`
            guard let myCalendar = try getOrCreateCalendar(
                named: calName,
                inEventStore: eventStore
            ) else {
                return false
            }

            // Check if an event with the same title exists in the "myCalendar" calendar
            let predicate = eventStore.predicateForEvents(
                withStart: period.start,
                end: period.end,
                calendars: [myCalendar]
            )

            let existingEvents = eventStore.events(matching: predicate)
            if let existingEvent = existingEvents.first(where: { $0.title == eventTitle }) {
                // If an event with the same title exists, update it
                existingEvent.startDate = eventDateInterval.start
                existingEvent.endDate = eventDateInterval.end
                try eventStore.save(
                    existingEvent,
                    span: .thisEvent,
                    commit: true
                )
                customLog.log(
                    level: .info,
                    "Event updated successfully!"
                )
                return true

            } else {
                // If no event with the same title exists,
                // create a new event in the "my calendar" calendar
                let newEvent = EKEvent(eventStore: eventStore)
                newEvent.title = eventTitle
                newEvent.startDate = eventDateInterval.start
                newEvent.endDate = eventDateInterval.end
                newEvent.calendar = myCalendar

                try eventStore.save(
                    newEvent,
                    span: .thisEvent,
                    commit: true
                )
                customLog.log(
                    level: .info,
                    "Event created successfully!"
                )
                return true
            }

        } catch {
            customLog.log(
                level: .error,
                "Error accessing or saving event: \(error.localizedDescription)"
            )
            return false
        }
    }

    /// Cherche un calendrier  nommé `calName` dans l'app Calendrier.
    /// Si le calendrier n'existe pas, il est créé.
    /// - Parameter calName: Nom du calendrier recherché.
    /// - Returns: Le clendrier nommé `calName`.
    private static func getOrCreateCalendar(
        named calName: String,
        inEventStore eventStore: EKEventStore
    ) throws -> EKCalendar? {
        let calendars = eventStore.calendars(for: .event)

        if let existingCalendar = calendars.first(where: { $0.title == calName }) {
            return existingCalendar

        } else {
            // Créer le calendrier
            let newCalendar = EKCalendar(for: .event, eventStore: eventStore)
            newCalendar.title = calName

            guard let source = bestPossibleEKSource(of: eventStore) else {
                // source is required, otherwise calendar cannot be saved
                customLog.log(
                    level: .error,
                    "Calendar source not found!"
                )
                return nil
            }
            newCalendar.source = source

            // Save the new calendar to the event store
            try eventStore.saveCalendar(newCalendar, commit: true)
            customLog.log(
                level: .info,
                "Calendar created and saved successfully!"
            )

            return newCalendar
        }
    }

    private static func bestPossibleEKSource(of eventStore: EKEventStore) -> EKSource? {
        let `default` = eventStore.defaultCalendarForNewEvents?.source
        let iCloud = eventStore.sources.first(where: { $0.title == "iCloud" }) // this is fragile, user can rename the source
        let local = eventStore.sources.first(where: { $0.sourceType == .local })

        return `default` ?? iCloud ?? local
    }
}
