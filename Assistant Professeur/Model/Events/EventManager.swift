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
    static func requestCalendarAccess(
        eventStore: EKEventStore
    ) async -> (
        alertIsPresented: Bool,
        alertTitle: String,
        alertMessage: String
    ) {
        // TODO: - To access the user’s Calendar data, all sandboxed macOS apps must include the com.apple.security.personal-information.calendars entitlement. To learn more about entitlements related to App Sandbox, see Enabling App Sandbox.
        do {
            if try await eventStore.requestAccess(to: .event) {
                // Succès
                return (false, "", "")

            } else {
                // Echec
                let authorizationStatus = EKEventStore.authorizationStatus(for: .event)
                var reason = ""
                switch authorizationStatus {
                    case .notDetermined:
                        reason = "indéfinie"
                    case .restricted:
                        reason = "accès restreint"
                    case .denied:
                        reason = "accès refusé"
                    case .authorized:
                        reason = "accès autorisé"
                    @unknown default:
                        reason = "inconnue"
                }
                let alertTitle: String = "Accès au calendrier non autorisé: raison \(reason)"
                customLog.log(level: .error, "\(alertTitle, privacy: .public)")
                return (
                    alertIsPresented: true,
                    alertTitle: alertTitle,
                    alertMessage: "The app doesn't have permission to access calendar data. Please grant the app access to Calendar in Settings."
                )
            }

        } catch {
            customLog.log(
                level: .error,
                "Echec de la demande d'accès au Calendrier: \(error.localizedDescription)"
            )
            return (
                alertIsPresented: true,
                alertTitle: "Echec de la demande d'accès au Calendrier",
                alertMessage: error.localizedDescription
            )
        }
    }

    /// Retourne la liste de tous les événements du clalendrier `calName`
    /// survenant dans la `period` et dont le titre contient **"Conseil - `classe`"**.
    /// - Parameters:
    ///   - classe: Acronym de la classe recherchée.
    ///   - calName: Nom du calendrier où ajouter l'événement.
    ///   - schoolYear: Intervalle de temps de l'année scolaire en cours.
    /// - Important: Convention de nommage:
    ///     Nom du calendrier = **Nom de l'établissement**
    ///     Titre de l'événement = **"Conseil - classe"**
    ///     où **classe** = 5E2S
    static func getAllConseils(
        forClasseName classe: String,
        inCalendar calendar: EKCalendar,
        inEventStore eventStore: EKEventStore,
        during schoolYear: DateInterval
    ) -> [EKEvent] {
        let eventName = "Conseil - \(classe)"

        return getEvents(
            withTitleIncluding: eventName,
            inCalendar: calendar,
            inEventStore: eventStore,
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
        inCalendar calendar: EKCalendar,
        inEventStore eventStore: EKEventStore,
        during period: DateInterval
    ) -> [EKEvent] {
        let eventName = "\(discipline.acronym) - \(classe)"

        return getEvents(
            withTitleIncluding: eventName,
            inCalendar: calendar,
            inEventStore: eventStore,
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
        inCalendar calendar: EKCalendar,
        inEventStore eventStore: EKEventStore
    ) -> [EKEvent] {
        let startOfDay = Calendar.current.startOfDay(for: .now)
        let secondsInOneDay = 60 * 60 * 24.0
        let endOfDay = startOfDay.addingTimeInterval(secondsInOneDay)
        let eventName = "\(discipline.acronym) - \(classe)"

        return getEvents(
            withTitleIncluding: eventName,
            inCalendar: calendar,
            inEventStore: eventStore,
            startDate: startOfDay,
            endDate: endOfDay
        )
    }

    /// Retourne la liste de tous les événements du clalendrier `calName`
    /// de la journée en cours.
    /// - Parameters:
    ///   - calName: Nom du calendrier où ajouter l'événement.
    static func getTodaySeances(
        inCalendar calendar: EKCalendar,
        inEventStore eventStore: EKEventStore
    ) -> [EKEvent] {
        let startOfDay = Calendar.current.startOfDay(for: .now)
        let oneDay = 60 * 60 * 24.0
        let endOfDay = startOfDay.addingTimeInterval(oneDay)

        return getEvents(
            inCalendar: calendar,
            inEventStore: eventStore,
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
        inCalendar calendar: EKCalendar,
        inEventStore eventStore: EKEventStore,
        startDate: Date,
        endDate: Date
    ) -> [EKEvent] {
        // Find the calendar named `calName`
        let predicate = eventStore.predicateForEvents(
            withStart: startDate,
            end: endDate,
            calendars: [calendar]
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
        during period: DateInterval,
        inCalendar calendar: EKCalendar,
        inEventStore eventStore: EKEventStore
    ) async -> Bool {
        do {
            // Check if an event with the same title exists in the "myCalendar" calendar
            let predicate = eventStore.predicateForEvents(
                withStart: period.start,
                end: period.end,
                calendars: [calendar]
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
                newEvent.calendar = calendar

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
                "Error creating event: \(error.localizedDescription)"
            )
            return false
        }
    }

    /// Cherche un calendrier  nommé `calName` dans l'app Calendrier.
    /// Si le calendrier n'existe pas, il est créé.
    /// - Parameter calName: Nom du calendrier recherché.
    /// - Returns: Le clendrier nommé `calName`.
    static func getOrCreateCalendar(
        named calName: String,
        inEventStore eventStore: EKEventStore
    ) -> (
        calendar: EKCalendar?,
        alertIsPresented: Bool,
        alertTitle: String,
        alertMessage: String
    ) {
        let calendars = eventStore.calendars(for: .event)

        if let existingCalendar = calendars.first(where: { $0.title == calName }) {
            // Succès
            return (
                calendar: existingCalendar,
                alertIsPresented: false,
                alertTitle: "",
                alertMessage: ""
            )

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
                // Echec
                return (
                    calendar: nil,
                    alertIsPresented: true,
                    alertTitle: "Calendrier \(calName) introuvable.",
                    alertMessage: "Echec de la tentative de création du calendrier: destination du calendrier introuvable."
                )
            }
            newCalendar.source = source

            do {
                // Save the new calendar to the event store
                try eventStore.saveCalendar(newCalendar, commit: true)
                customLog.log(
                    level: .info,
                    "Calendar named \(calName) created and saved successfully!"
                )
                // Succès
                return (
                    calendar: newCalendar,
                    alertIsPresented: false,
                    alertTitle: "",
                    alertMessage: ""
                )
            } catch {
                // Echec
                return (
                    calendar: nil,
                    alertIsPresented: true,
                    alertTitle: "Calendrier \(calName) introuvable.",
                    alertMessage: "Echec de la tentative de création du calendrier."
                )
            }
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
                "Calendar named \(calName) created and saved successfully!"
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
