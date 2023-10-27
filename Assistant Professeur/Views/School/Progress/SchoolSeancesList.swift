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

    var dateInterval: DateInterval

    @State
    private var loadingStatus: CalendarSeancesLoadingStatus = .pending

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
        // Afficher le resultat de la recherche
        VStack {
            loadingStatus.view
        }
        // Chargement des données recherchées depuis l'application Calendrier
        .task(id: school.id!.uuidString + dateInterval.description) {
            loadingStatus = .pending

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
                loadingStatus = .failed
                return
            }

            // Période de recherche
            loadingStatus = .loading

            // Recherche: `SeancesInDateInterval` contenant la liste des Séances à venir
            // pour toutes classes d'un établissement avec le contenu pédagogique de chaque séance.
            schoolSeances = await SeancesInDateInterval.loadedNextSeancesForSchool(
                school: school,
                inCalendar: calendar,
                inEventStore: eventStore,
                inDateInterval: dateInterval
            )

            loadingStatus = .finished(seancesInInterval: schoolSeances)
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
