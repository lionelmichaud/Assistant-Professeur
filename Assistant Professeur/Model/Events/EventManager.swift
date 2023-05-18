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

enum EventManager {
    static func saveOrUpdate(
        eventTitle: String,
        eventDateInterval: DateInterval,
        toCalendarNamed calName: String,
        during schoolYear: DateInterval
    ) async -> Bool {
        let eventStore = EKEventStore()
        do {
            try await eventStore.requestAccess(to: .event)

            // Find the calendar named `calName`
            guard let myCalendar = try getOrCreateCalendar(named: calName) else {
                return false
            }

            // Check if an event with the same title exists in the "myCalendar" calendar
            let predicate = eventStore.predicateForEvents(
                withStart: schoolYear.start,
                end: schoolYear.end,
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
    private static func getOrCreateCalendar(named calName: String) throws -> EKCalendar? {
        let eventStore = EKEventStore()
        let calendars = eventStore.calendars(for: .event)

        if let existingCalendar = calendars.first(where: { $0.title == calName }) {
            return existingCalendar

        } else {
            // Créer le calendrier
            let newCalendar = EKCalendar(for: .event, eventStore: eventStore)
            newCalendar.title = calName

            guard let source = bestPossibleEKSource() else {
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

    private static func bestPossibleEKSource() -> EKSource? {
        let eventStore = EKEventStore()
        let `default` = eventStore.defaultCalendarForNewEvents?.source
        let iCloud = eventStore.sources.first(where: { $0.title == "iCloud" }) // this is fragile, user can rename the source
        let local = eventStore.sources.first(where: { $0.sourceType == .local })

        return `default` ?? iCloud ?? local
    }
}
