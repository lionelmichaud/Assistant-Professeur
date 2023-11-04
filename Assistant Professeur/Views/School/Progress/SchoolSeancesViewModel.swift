//
//  SchoolSeancesViewModel.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 04/11/2023.
//

import EventKit
import SwiftUI

struct AlertInfo {
    var isPresented: Bool = false
    var title: String = ""
    var message: String = ""
}

@MainActor
class SchoolSeancesViewModel: ObservableObject {
    @Published
    var state: CalendarSeancesLoadingStatus = .pending
    private var showToDoListButton: Bool = false

    var seancesListView: some View {
        state.view
    }

    var toDoListButton: some View {
        Group {
            if showToDoListButton {
                // Bouton de navigation vers la liste des ToDo
                switch state {
                    case .pending, .loading, .failed:
                        EmptyView()

                    case let .finished(seancesInInterval):
                        if seancesInInterval.seances.isNotEmpty {
                            NavigationLink(
                                value: SchoolNavigationRoute.toDoList(seancesInInterval.seances)
                            ) {
                                Label(
                                    "A faire avant ces cours...",
                                    systemImage: "checklist"
                                )
                                .imageScale(.large)
                                .font(.headline)
                                .fontWeight(.bold)
                            }
                            .padding(.bottom)
                        } else {
                            EmptyView()
                        }
                }
            }
        }
    }

    func updateItems(
        forSchool school: SchoolEntity,
        inDateInterval dateInterval: DateInterval,
        showOnlyOngoingSeance: Bool,
        showToDoListButton: Bool
    ) async -> AlertInfo {
        self.showToDoListButton = showToDoListButton
        self.state = .pending

        var alert = AlertInfo()
        let schoolName = school.viewName

        // Demander les droits d'accès aux calendriers de l'utilisateur
        var eventStore = EKEventStore()
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
        var schoolSeances = await SeancesInDateInterval.loadedNextSeancesForSchool(
            school: school,
            inCalendar: calendar,
            inEventStore: eventStore,
            inDateInterval: dateInterval
        )

        if showOnlyOngoingSeance {
            // Filtrer pour ne garder que la séance en cours
            schoolSeances.seances =
                schoolSeances.seances
                    .filter { seance in
                        seance.interval.contains(Date.now)
                    }
        }

        state = .finished(seancesInInterval: schoolSeances)
        return alert
    }
}
