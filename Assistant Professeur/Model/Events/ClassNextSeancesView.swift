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

    @ObservedObject
    private var pref = UserPrefEntity.shared

    private let horizon = 3 // mois
    // TODO: - A mettre en préférence

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
        ScrollView(.vertical, showsIndicators: true) {
            ForEach(classeSeances.seances) { seance in
                SeanceRow(seance: seance)
            }
            .emptyListPlaceHolder(classeSeances.seances) {
                EmptyListMessage(
                    symbolName: "clock",
                    title: "Aucun événement trouvé dans le calendrier de cet établissement pour cette classe.",
                    message: "Les événements plannifiés dans votre agenda pour cette classe apparaîtront ici.",
                    showAsGroupBox: true
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
        .task {
            // Suite des Séances à venir pour cette classe sur un `horizon`
            if let schoolName = classe.school?.viewName {
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
                    // Liste des Progressions de la classe triée par numéro de Séquence / Activité
                    let sortedClasseProgresses = classe.allProgressesSortedBySequenceActivityNumber

                    let horizon = DateInterval(
                        start: Date.now,
                        end: horizon.months.fromNow!
                    )
                    classeSeances.loadSeancesFromCalendar(
                        forDiscipline: classe.disciplineEnum,
                        forClasseName: classe.displayString,
                        inCalendar: calendar,
                        inEventStore: eventStore,
                        during: horizon
                    )

                    // Synchroniser les Progressions avec les Séances
                    SequenceSeanceCoordinator.synchronize(
                        classeSeances: &classeSeances,
                        withProgresses: sortedClasseProgresses
                    )

                    // Insérer des pseudo-séances pour chaque période
                    // de vacances inclue dans la période
                    let vacancesIncludedInPeriod =
                        pref.viewSchoolYearPref
                            .vacancesContained(in: horizon)

                    vacancesIncludedInPeriod.forEach { vacance in
                        if classeSeances.seances.count >= 2 {
                            for idx in classeSeances.seances.startIndex ... classeSeances.seances.endIndex - 2
                                where (classeSeances[idx].interval.end ... classeSeances[idx + 1].interval.start).contains(vacance.interval.start) {
                                let pseudoSeance = Seance(
                                    name: vacance.name,
                                    interval: vacance.interval,
                                    isVacance: true
                                )
                                classeSeances
                                    .seances
                                    .insert(pseudoSeance, at: idx + 1)
                                break
                            }
                        }
                    }
                }
            }
        }
        #if os(iOS)
        .navigationTitle("Cours à venir")
        #endif
        .toolbar {
            ToolbarItem(placement: .automatic) {
                // Afficher le PopOver d'information surle format à utiliser
                Button {
                    popOverIsPresented = true
                } label: {
                    Image(systemName: "info.circle")
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
