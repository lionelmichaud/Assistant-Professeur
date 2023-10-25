//
//  SchoolPreviousSeancesView.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 24/10/2023.
//

import EventKit
import HelpersView
import SwiftUI

struct SchoolPreviousSeancesView: View {
    @ObservedObject
    var school: SchoolEntity

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
                SeanceRow(seance: seance, showWatchButton: false)
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
            // Demander les droits d'accès aux calendriers de l'utilisateur
            (
                calendar,
                alertIsPresented,
                alertTitle,
                alertMessage
            ) = await EventManager.shared
                .requestCalendarAccess(
                    eventStore: eventStore,
                    calendarName: school.viewName
                )
            if let calendar {
                await SchoolEntity.context.perform {
                    var schoolYear = SchoolYearPref()
                    schoolYear = UserPrefEntity.shared.viewSchoolYearPref
                    let startOfDay = Calendar.current.startOfDay(for: .now)

                    let dateInterval = DateInterval(
                        start: startOfDay,
                        end: .now
                    )

                    // `SeancesInDateInterval` contenant la liste des Séances à venir
                    // pour toutes classes d'un établissement avec le contenu pédagogique de chaque séance.
                    schoolSeances.loadSchoolSeancesFromCalendar(
                        school: school,
                        inCalendar: calendar,
                        inEventStore: eventStore,
                        during: dateInterval,
                        schoolYear: schoolYear
                    )

                    // Eliminer l'éventuel cours en cours d'éxécution
                    schoolSeances.seances =
                        schoolSeances.seances
                            .filter { seance in
                                !seance.interval.contains(.now)
                            }
                }
            }
        }
        #if os(iOS)
        .navigationTitle("Cours précédents")
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

// #Preview {
//    SchoolPreviousSeancesView()
// }
