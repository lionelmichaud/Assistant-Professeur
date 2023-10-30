//
//  NextSeancesList.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 27/10/2023.
//

import EventKit
import SwiftUI

struct SchoolSeancesList: View {
    @ObservedObject
    var school: SchoolEntity
    let dateInterval: DateInterval
    let showOnlyOngoingSeance: Bool
    let showToDoList: Bool

    @State
    private var seancesLoadingStatus: CalendarSeancesLoadingStatus = .pending

    @State
    private var schoolSeances: SeancesInDateInterval = .init()

    @State
    private var eventStore = EKEventStore()
    @State
    private var calendar: EKCalendar?

    @State
    private var alertTitle = ""
    @State
    private var alertMessage = ""
    @State
    private var alertIsPresented = false

    var body: some View {
        // Afficher la ToDo liste
        VStack(alignment: .leading) {
            if showToDoList {
                switch seancesLoadingStatus {
                    case .pending, .loading, .failed:
                        EmptyView()

                    case .finished(let seancesInInterval):
                        if seancesInInterval.seances.isNotEmpty {
                            NavigationLink(value: SchoolNavigationRoute.toDoList(seancesInInterval.seances)) {
                                Label("A faire avant ces cours...", systemImage: "checklist")
                                    .font(.headline)
                                    .fontWeight(.bold)
                            }
                            .padding(.bottom)
                        } else {
                            EmptyView()
                        }
                }
            }

            // Afficher toutes les séances trouvées
            seancesLoadingStatus.view
        }
        // Chargement des données recherchées depuis l'application Calendrier
        .task(id: school.id!.uuidString + dateInterval.description) {
            seancesLoadingStatus = .pending

            let schoolName = school.viewName

            // Demander les droits d'accès aux calendriers de l'utilisateur
            (
                calendar,
                alertIsPresented,
                alertTitle,
                alertMessage
            ) = await EventManager.shared
                .requestCalendarAccess(
                    eventStore: eventStore,
                    calendarName: schoolName
                )
            guard let calendar else {
                seancesLoadingStatus = .failed
                return
            }

            seancesLoadingStatus = .loading

            // Recherche: `SeancesInDateInterval` contenant la liste des Séances à venir
            // pour toutes classes d'un établissement avec le contenu pédagogique de chaque séance.
            schoolSeances = await SeancesInDateInterval.loadedNextSeancesForSchool(
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
                            seance.interval.contains(.now)
                        }
            }

            seancesLoadingStatus = .finished(seancesInInterval: schoolSeances)
        }
        .alert(
            alertTitle,
            isPresented: $alertIsPresented,
            actions: {},
            message: { Text(alertMessage) }
        )
    }
}

// #Preview {
//    NextSeancesList()
// }
