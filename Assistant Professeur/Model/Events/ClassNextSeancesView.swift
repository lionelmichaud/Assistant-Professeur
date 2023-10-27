//
//  ClassNextSeances.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 07/07/2023.
//

import EventKit
import HelpersView
import SwiftUI

struct ClassNextSeancesView: View {
    @ObservedObject
    var classe: ClasseEntity

    // MARK: - Properties

    @ObservedObject
    private var pref = UserPrefEntity.shared

    @State
    private var loadingStatus: CalendarSeancesLoadingStatus = .pending

    @State
    private var period: PeriodEnum = .nextWeek
    private let horizon = 3 // mois

    @State
    private var classeSeances: SeancesInDateInterval = .init()

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
            Text("Exemple: pour la discipline de \(classe.disciplineEnum.pickerString),")
            Text("et la classe de \(classe.displayString): \"**\(classe.disciplineEnum.acronym) - \(classe.displayString)**\"")
        }
        .foregroundColor(.primary)
        .padding()
    }

    var body: some View {
        VStack {
            // Sélecteur de période de recherche dans Calendrier
            CasePicker(
                pickedCase: $period,
                label: "Période"
            )
            .pickerStyle(.segmented)
            .padding(.vertical)

            // Afficher le resultat de la recherche
            loadingStatus.view
        }
        .padding(.horizontal)
        .verticallyAligned(.top)
        .alert(
            alertTitle,
            isPresented: $alertIsPresented,
            actions: {},
            message: { Text(alertMessage) }
        )
        // Chargement des données recherchées depuis l'application Calendrier
        .task(id: classe.id!.uuidString + period.pickerString) {
            loadingStatus = .pending

            guard let schoolName = classe.school?.viewName else {
                return
            }

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
            var endDate: Date?
            switch period {
                case .today: endDate = 1.days.from(Calendar.current.startOfDay(for: .now))
                case .nextWeek: endDate = 1.weeks.fromNow
                case .all: endDate = horizon.months.fromNow
            }
            let dateInterval = DateInterval(
                start: Date.now,
                end: endDate!
            )

            loadingStatus = .loading

            // Recherche: `SeancesInDateInterval` contenant la liste des Séances à venir
            // pour une classe d'un établissement avec le contenu pédagogique de chaque séance.
            classeSeances = await SeancesInDateInterval.loadedNextSeancesForClasse(
                schoolName: schoolName,
                classe: classe,
                inCalendar: calendar,
                inEventStore: eventStore,
                inDateInterval: dateInterval
            )

            loadingStatus = .finished(seancesInInterval: classeSeances)
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

struct ClassNextSeances_Previews: PreviewProvider {
    static func initialize() {
        DataBaseManager.populateWithMockData(storeType: .inMemory)
    }

    static var previews: some View {
        initialize()
        let classe = ClasseEntity.all().first { classe in
            classe.levelEnum == .n5ieme
        }!
        print(classe)
        return Group {
            ClassNextSeancesView(classe: classe)
                .previewDevice("iPad mini (6th generation)")
            ClassNextSeancesView(classe: classe)
                .previewDevice("iPhone 13")
        }
    }
}
