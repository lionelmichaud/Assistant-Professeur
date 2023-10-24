//
//  SchoolNextSeancesView.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 10/07/2023.
//

import EventKit
import HelpersView
import SwiftUI

struct SchoolNextSeancesView: View {
    @ObservedObject
    var school: SchoolEntity

    private let horizon = 3 // mois

    @State
    private var schoolSeances: SeancesInDateInterval = .init()

    @State
    private var popOverIsPresented: Bool = false

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

    private var infoView: some View {
        VStack {
            Text("Pour apparaître ici les noms des événements")
            Text("du calendrier de cet établissement doivent contenir:")
            Text("\"**Acronyme Discipline - Classe**\"\n")
            Text("Exemple: pour la discipline de \(Discipline.technologie.pickerString),")
            Text("et la classe de 4ième 2: \"**TECHNO - 4E2)**\"")
        }
        .foregroundColor(.primary)
        .padding()
    }

    var body: some View {
        ScrollView(.vertical, showsIndicators: true) {
            ForEach(schoolSeances.seances) { seance in
                SeanceRow(seance: seance)
            }
            .emptyListPlaceHolder(schoolSeances.seances) {
                ContentUnavailableView(
                    "Aucun cours trouvé dans votre agenda...",
                    systemImage: "clock",
                    description: Text("Les cours plannifiés dans votre agenda pour les classes de cet établissement apparaîtront ici.")
                )
            }
        }
        .padding(.horizontal)
        .verticallyAligned(.top)
        .alert(
            alertTitle,
            isPresented: $alertIsPresented,
            actions: {},
            message: { Text(alertMessage) }
        )
        .task(id: school.objectID) {
            var foundSeances = [Seance]()
            let schoolClasses = school.classesSortedByLevelNumber
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
            if let calendar {
                let dateInterval = DateInterval(
                    start: Date.now,
                    end: horizon.months.fromNow!
                )

                // `SeancesInDateInterval` contenant la liste des Séances à venir
                // pour toutes classes d'un établissement avec le contenu pédagogique de chaque séance.
                schoolSeances = await SeancesInDateInterval.loadedNextSeancesForSchool(
                    school: school,
                    inCalendar: calendar,
                    inEventStore: eventStore,
                    inDateInterval: dateInterval
                )
            }
        }
        #if os(iOS)
        .navigationTitle("Cours à venir")
        #endif
        .toolbar {
            ToolbarItem(placement: .automatic) {
                // Afficher le PopOver d'information sur le format à utiliser
                Button {
                    popOverIsPresented = true
                } label: {
                    Image(systemName: "info.bubble")
                }
                .popover(isPresented: $popOverIsPresented) {
                    infoView
                }
            }
        }
        .navigationBarTitleDisplayModeInline()
    }
}

// struct SchoolNextSeancesView_Previews: PreviewProvider {
//    static var previews: some View {
//        SchoolNextSeancesView()
//    }
// }
