//
//  SchoolNextSeancesView.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 10/07/2023.
//

import AppFoundation
import EventKit
import HelpersView
import SwiftUI

struct SchoolNextSeancesView: View {
    @ObservedObject
    var school: SchoolEntity

    enum PeriodEnum: String, PickableEnumP {
        case today
        case oneWeek
        case all

        var pickerString: String {
            switch self {
                case .today: "Aujourd'hui"
                case .oneWeek: "Semaine à venir"
                case .all: "3 prochains mois"
            }
        }
    }

    @State
    private var period: PeriodEnum = .oneWeek
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

    // MARK: - Computed Properties

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
        VStack {
            CasePicker(
                pickedCase: $period,
                label: "Période"
            )
            .pickerStyle(.segmented)
            .padding(.vertical)

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
        }
        .padding(.horizontal)
        .verticallyAligned(.top)
        .alert(
            alertTitle,
            isPresented: $alertIsPresented,
            actions: {},
            message: { Text(alertMessage) }
        )
        .task(id: school.id!.uuidString + period.pickerString) {
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
                var endDate: Date?
                switch period {
                    case .today: endDate = 1.days.from(Calendar.current.startOfDay(for: .now))
                    case .oneWeek: endDate = 1.weeks.fromNow
                    case .all: endDate = horizon.months.fromNow
                }
                let dateInterval = DateInterval(
                    start: Date.now,
                    end: endDate!
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
