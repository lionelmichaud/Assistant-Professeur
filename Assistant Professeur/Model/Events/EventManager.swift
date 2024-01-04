//
//  EventManager.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 15/05/2023.
//

import EventKit
import Foundation
import OSLog

private let customLog = Logger(
    subsystem: "com.michaud.lionel.Assistant-Professeur",
    category: "EventManager"
)

/// Gestionnaire d'Evénements. Synchronize l'appli avec l'app Calendrier.
actor EventManager { // swiftlint:disable:this type_body_length
    // MARK: - SINGLETON

    static var shared = EventManager()

    // MARK: - Initializer

    private init() {}

    // MARK: - Properties

    private var autorizationStatus: EKAuthorizationStatus?

    /// True si l'accès à déjà été demandé à l'utilisateur
    var isAccessChecked: Bool {
        autorizationStatus != nil
    }

    var isFullAccessAuthorized: Bool {
        autorizationStatus == .fullAccess
    }

    // MARK: - Methods

    func requestCalendarAccess( // swiftlint:disable:this cyclomatic_complexity
        eventStore: EKEventStore,
        calendarName: String
    ) async -> (
        calendar: EKCalendar?,
        alertIsPresented: Bool,
        alertTitle: String,
        alertMessage: String
    ) {
        // TODO: - To access the user’s Calendar data, all sandboxed macOS apps must include the com.apple.security.personal-information.calendars entitlement. To learn more about entitlements related to App Sandbox, see Enabling App Sandbox.
        do {
            if try await eventStore.requestFullAccessToEvents() {
                // Succès
                self.autorizationStatus = EKEventStore.authorizationStatus(for: .event)
                let (
                    calendar,
                    alertIsPresented,
                    alertTitle,
                    alertMessage
                ) = EventManager.getOrCreateCalendar(
                    named: calendarName,
                    inEventStore: eventStore
                )
                if let calendar {
                    // Succès
                    return (calendar, false, "", "")
                } else {
                    return (
                        calendar: nil,
                        alertIsPresented: alertIsPresented,
                        alertTitle: alertTitle,
                        alertMessage: alertMessage
                    )
                }

            } else if isAccessChecked {
                // Echec déjà signalé
                return (nil, false, "", "")

            } else {
                // Echec jamais signalé
                let authorizationStatus = EKEventStore.authorizationStatus(for: .event)
                self.autorizationStatus = authorizationStatus
                var reason = ""
                switch authorizationStatus {
                    case .notDetermined:
                        reason = "L'utilisateur n'a pas défini s'il accepte ou non l'accès à ses données de Calendrier."
                    case .restricted:
                        reason = "L'application n'est pas autorisée à accéder aux données du Calendrier de l'utilisateur."
                    case .denied:
                        reason = "L'utilisateur a explicitement refusé l'accès à ses données de Calendrier."
                    case .fullAccess:
                        reason = "L'application est autorisée à accéder en lecture et écriture aux données du Calendrier de l'utilisateur."
                    case .writeOnly:
                        reason = "L'application n'est autorisée à accéder qu'en écriture aux données du Calendrier de l'utilisateur."
                    @unknown default:
                        reason = "inconnue"
                }
                let alertTitle: String = "Accès à l'application Calendrier non autorisé"
                customLog.log(level: .error, "\(alertTitle, privacy: .public)")
                return (
                    calendar: nil,
                    alertIsPresented: true,
                    alertTitle: alertTitle,
                    alertMessage: reason
                )
            }

        } catch {
            if !isAccessChecked {
                customLog.log(
                    level: .error,
                    "Echec de la demande d'accès au Calendrier: \(error.localizedDescription)"
                )
                self.autorizationStatus = EKEventStore.authorizationStatus(for: .event)
                return (
                    calendar: nil,
                    alertIsPresented: true,
                    alertTitle: "Echec de la demande d'accès au Calendrier",
                    alertMessage: error.localizedDescription
                )
            } else {
                // Echec déjà signalé
                return (nil, false, "", "")
            }
        }
    }

    /// Retourne la liste de tous les événements du clalendrier `calendar`
    /// survenant dans la `period` et dont le titre contient **"Arrêt notes - `classeLevel`"**.
    /// - Parameters:
    ///   - classeLevel: Acronym du niveau de classe recherchée.
    ///   - calendar: Calendrier où rechercher l'événement.
    ///   - schoolYear: Intervalle de temps de l'année scolaire en cours.
    /// - Important: Convention de nommage:
    ///     Nom du calendrier = **Nom de l'établissement**
    ///     Titre de l'événement = **"Arrêt notes - classeLevel"**
    ///     où **classeLevel** = 5E
    static func getAllArretsNotes(
        forClasseLevel classeLevel: LevelClasse,
        inCalendar calendar: EKCalendar,
        inEventStore eventStore: EKEventStore,
        during schoolYear: DateInterval,
        after thisEarliestdate: Date? = nil
    ) -> [EKEvent] {
        let eventName = "Arrêt notes - \(classeLevel.displayString)"

        return getEvents(
            withTitleIncluding: eventName,
            inCalendar: calendar,
            inEventStore: eventStore,
            startDate: thisEarliestdate ?? schoolYear.start,
            endDate: schoolYear.end
        )
    }

    // MARK: - Dates d'examens

    static func getBrevet(
        inCalendar calendar: EKCalendar,
        inEventStore eventStore: EKEventStore,
        during schoolYear: DateInterval
    ) -> EKEvent? {
        let eventName = "Brevet"

        return getEvents(
            withTitleIncluding: eventName,
            inCalendar: calendar,
            inEventStore: eventStore,
            startDate: schoolYear.start,
            endDate: schoolYear.end
        ).first
    }

    static func getBac(
        inCalendar calendar: EKCalendar,
        inEventStore eventStore: EKEventStore,
        during schoolYear: DateInterval
    ) -> EKEvent? {
        let eventName = "Bac"

        return getEvents(
            withTitleIncluding: eventName,
            inCalendar: calendar,
            inEventStore: eventStore,
            startDate: schoolYear.start,
            endDate: schoolYear.end
        ).first
    }

    // MARK: - Dates de conseils de classe

    /// Retourne la liste de tous les événements du clalendrier `calendar`
    /// survenant dans la `period` et dont le titre contient **"Conseil - `classe`"**.
    /// - Parameters:
    ///   - classe: Acronym de la classe recherchée.
    ///   - calendar: Calendrier où rechercher l'événement.
    ///   - schoolYear: Intervalle de temps de l'année scolaire en cours.
    /// - Important: Convention de nommage:
    ///     Nom du calendrier = **Nom de l'établissement**
    ///     Titre de l'événement = **"Conseil - classe"**
    ///     où **classe** = 5E2S
    static func getAllConseils(
        forClasseName classe: String,
        inCalendar calendar: EKCalendar,
        inEventStore eventStore: EKEventStore,
        during schoolYear: DateInterval,
        after thisEarliestdate: Date? = nil
    ) -> [EKEvent] {
        let eventName = "Conseil - \(classe)"

        return getEvents(
            withTitleIncluding: eventName,
            inCalendar: calendar,
            inEventStore: eventStore,
            startDate: thisEarliestdate ?? schoolYear.start,
            endDate: schoolYear.end
        )
    }

    // MARK: - Séances du jour

    /// Retourne la liste de tous les événements du clalendrier `calName`
    /// de la journée en cours et dont  le titre contient "`discipline` - `classe`".
    /// - Parameters:
    ///   - discipline: La discipline recherchée.
    ///   - classe: Acronym de la classe recherchée.
    ///   - calendar: Calendrier où rechercher l'événement.
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

    /// Retourne la liste de tous les événements du clalendrier `calendar`
    /// de la journée en cours.
    /// - Parameters:
    ///   - calendar: Calendrier où rechercher l'événement.
    static func getTodayEvents(
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

    // MARK: - Séances sur une période de temps

    /// Retourne la liste de tous les événements du clalendrier `calName`
    /// survenant dans la `period` et dont le titre contient "`discipline` - `classe`".
    /// - Parameters:
    ///   - discipline: La discipline recherchée.
    ///   - classe: Acronym de la classe recherchée.
    ///   - calendar: Calendrier où rechercher l'événement.
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

    // MARK: - Tous les événements sur une période de temps

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

    // MARK: - Sauvegarde événements dans Calendrier

    /// Updates or saves an event to the Calendar app in the calendar named `calName`
    ///
    /// If the calendar named `calName` does not exist, creates the calendar.
    ///
    /// If the event already exists, updates the event, else, creates the event.
    /// - Parameters:
    ///   - eventTitle: Nom de l'événement.
    ///   - eventDateInterval: Intervalle de temps de l'événement.
    ///   - calendar: Calendrier où ajouter l'événement.
    ///   - period: Intervalle de temps de recherche.
    /// - Returns: True si l'enregistrement à réussi.
    static func saveOrUpdate(
        eventTitle: String,
        eventDateInterval: DateInterval,
        during period: DateInterval,
        inCalendar calendar: EKCalendar,
        inEventStore eventStore: EKEventStore
    ) -> Bool {
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
                    "Echec de l'opération sur le calendrier. Source \(calName) du calendrier introuvable."
                )
                // Echec
                return (
                    calendar: nil,
                    alertIsPresented: true,
                    alertTitle: "Echec de l'opération sur le calendrier.",
                    alertMessage: "Source \(calName) du calendrier introuvable."
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
                customLog.log(
                    level: .error,
                    "Echec de l'opération sur le calendrier. La création d'un nouveau calendrier \(calName) a échouée."
                )
                // Echec
                return (
                    calendar: nil,
                    alertIsPresented: true,
                    alertTitle: "Echec de l'opération sur le calendrier.",
                    alertMessage: "La création d'un nouveau calendrier \(calName) a échouée."
                )
            }
        }
    }

    private static func bestPossibleEKSource(of eventStore: EKEventStore) -> EKSource? {
        let `default` = eventStore.defaultCalendarForNewEvents?.source
        let iCloud = eventStore.sources.first(where: { $0.title == "iCloud" }) // this is fragile, user can rename the source
        let local = eventStore.sources.first(where: { $0.sourceType == .local })

        return `default` ?? iCloud ?? local
    }
}
