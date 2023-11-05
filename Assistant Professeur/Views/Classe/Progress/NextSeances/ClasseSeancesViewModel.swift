//
//  ClasseSeancesViewModel.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 05/11/2023.
//

import EventKit
import SwiftUI

@MainActor
class ClasseSeancesViewModel: ObservableObject {
    @Published
    var state: SeancesLoadingStatus = .pending
    private var showToDoListButton: Bool = false

    var seancesListView: some View {
        state.view
    }

//    var toDoListButton: some View {
//        Group {
//            if showToDoListButton {
//                // Bouton de navigation vers la liste des ToDo
//                switch state {
//                    case .pending, .loading, .failed:
//                        EmptyView()
//
//                    case let .finished(seancesInInterval):
//                        if seancesInInterval.seances.isNotEmpty {
//                            NavigationLink(
//                                value: SchoolNavigationRoute.toDoList(seancesInInterval.seances)
//                            ) {
//                                Label(
//                                    "A faire avant ces cours...",
//                                    systemImage: "checklist"
//                                )
//                                .imageScale(.large)
//                                .font(.headline)
//                                .fontWeight(.bold)
//                            }
//                            .padding(.bottom)
//                        } else {
//                            EmptyView()
//                        }
//                }
//            }
//        }
//    }

    func updateItems(
        forClasse classe: ClasseEntity,
        inDateInterval dateInterval: DateInterval,
        showToDoListButton: Bool
    ) async -> AlertInfo {
        self.showToDoListButton = showToDoListButton
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
        var classeSeances = await SeancesInDateInterval.loadedNextSeancesForClasse(
            schoolName: schoolName,
            classe: classe,
            inCalendar: calendar,
            inEventStore: eventStore,
            inDateInterval: dateInterval
        )

        state = .finished(seancesInInterval: classeSeances)
        return alert
    }
}
