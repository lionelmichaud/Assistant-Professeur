//
//  CalendarChooser.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 18/05/2023.
//

import SwiftUI
import EventKitUI

/// This code below is intended as a starting point for folks who need to work with EKCalendarChooser in their SwiftUI project.
///
/// Usage:
///
///     @Published var selectedCalendars: Set<EKCalendar>?
///
///     .sheet(isPresented: $showingCalendarChooser) {
///          CalendarChooser(
///              calendars: self.$eventsRepository.selectedCalendars,
///              eventStore: self.eventsRepository.eventStore
///          )
///     }
///
struct CalendarChooser: UIViewControllerRepresentable {
    func makeCoordinator() -> Coordinator {
        return Coordinator(self)
    }

    @Environment(\.presentationMode) var presentationMode
    @Binding var calendars: Set<EKCalendar>?

    let eventStore: EKEventStore

    func makeUIViewController(context: UIViewControllerRepresentableContext<CalendarChooser>) -> UINavigationController {
        let chooser = EKCalendarChooser(selectionStyle: .multiple, displayStyle: .allCalendars, entityType: .event, eventStore: eventStore)
        chooser.selectedCalendars = calendars ?? []
        chooser.delegate = context.coordinator
        chooser.showsDoneButton = true
        chooser.showsCancelButton = true
        return UINavigationController(rootViewController: chooser)
    }

    func updateUIViewController(_ uiViewController: UINavigationController, context: UIViewControllerRepresentableContext<CalendarChooser>) {
    }

    class Coordinator: NSObject, UINavigationControllerDelegate, EKCalendarChooserDelegate {
        let parent: CalendarChooser

        init(_ parent: CalendarChooser) {
            self.parent = parent
        }

        func calendarChooserDidFinish(_ calendarChooser: EKCalendarChooser) {
            parent.calendars = calendarChooser.selectedCalendars
            parent.presentationMode.wrappedValue.dismiss()
        }

        func calendarChooserDidCancel(_ calendarChooser: EKCalendarChooser) {
            parent.presentationMode.wrappedValue.dismiss()
        }
    }
}

//struct CalendarChooser_Previews: PreviewProvider {
//    static var previews: some View {
//        CalendarChooser()
//    }
//}
