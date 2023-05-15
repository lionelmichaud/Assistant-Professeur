//
//  EventManager.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 15/05/2023.
//

import Foundation
import EventKit

enum EventManager {
    static func saveOrUpdate(
        event: EKEvent,
        toCalendarNamed calName: String
    ) async -> Bool {
        let eventStore = EKEventStore()
        do {
            try await eventStore.requestAccess(to: .event)

            // Find the calendar named `calName`
            let calendars = eventStore.calendars(for: .event)
            guard let myCalendar = calendars.first(where: { $0.title == calName }) else {
                print("The calendar named \(calName) was not found.")
                return false
            }

            // Check if an event with the same title exists in the "my calendar" calendar
//            let predicate = eventStore.predicateForEvents(withStart: startDate, end: endDate, calendars: [myCalendar])
//            let existingEvents = eventStore.events(matching: predicate)
//            if let existingEvent = existingEvents.first(where: { $0.title == title }) {
//                // If an event with the same title exists, update it
//                existingEvent.startDate = startDate
//                existingEvent.endDate = endDate
//                try await eventStore.save(existingEvent, span: .thisEvent)
//                print("Event updated successfully!")
//            } else {
//                // If no event with the same title exists, create a new event in the "my calendar" calendar
//                let event = EKEvent(eventStore: eventStore)
//                event.title = title
//                event.startDate = startDate
//                event.endDate = endDate
//                event.calendar = myCalendar
//
//                try await eventStore.save(event, span: .thisEvent)
//                print("Event created successfully!")
//            }

            return true

        } catch {
            print("Error accessing or saving event: \(error.localizedDescription)")
            return false
        }
    }
}
