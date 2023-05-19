//
//  EventEditView.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 18/05/2023.
//

import EventKitUI
import SwiftUI

/// Bridging the EKEventEditViewController.
/// This ready-made controller will let you create new event and save it as well and also edit existing events that you can pass in.
///
/// Usage:
///
///     EventEditView(
///        eventStore: self.eventsRepository.eventStore,
///        event: self.selectedEvent
///     )
///
struct EventEditView: UIViewControllerRepresentable {
    func makeCoordinator() -> Coordinator {
        return Coordinator(self)
    }

    @Environment(\.presentationMode)
    var presentationMode

    let eventStore: EKEventStore
    let event: EKEvent?

    func makeUIViewController(context: UIViewControllerRepresentableContext<EventEditView>) -> EKEventEditViewController {
        let eventEditViewController = EKEventEditViewController()
        eventEditViewController.eventStore = eventStore

        if let event = event {
            eventEditViewController.event = event // when set to nil the controller would not display anything
        }
        eventEditViewController.editViewDelegate = context.coordinator

        return eventEditViewController
    }

    func updateUIViewController(
        _: EKEventEditViewController,
        context _: UIViewControllerRepresentableContext<EventEditView>
    ) {}

    class Coordinator: NSObject, EKEventEditViewDelegate {
        let parent: EventEditView

        init(_ parent: EventEditView) {
            self.parent = parent
        }

        func eventEditViewController(_: EKEventEditViewController, didCompleteWith action: EKEventEditViewAction) {
            parent.presentationMode.wrappedValue.dismiss()

            if action != .canceled {
//                NotificationCenter.default.post(name: .eventsDidChange, object: nil) // custom notification to reload UI when events changed
            }
        }
    }
}

// struct EventEditView_Previews: PreviewProvider {
//    static var previews: some View {
//        EventEditView()
//    }
// }
