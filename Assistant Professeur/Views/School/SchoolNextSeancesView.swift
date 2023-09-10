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
                EmptyListMessage(
                    symbolName: "clock",
                    title: "Aucun cours trouvé dans votre agenda.",
                    message: "Les cours plannifiés dans votre agenda pour les classes de cet établissement apparaîtront ici.",
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
                await withTaskGroup(of: [Seance].self) { group in
                    for classe in schoolClasses {
                        group.addTask {
                            var sortedClasseProgresses = [ActivityProgressEntity]()
                            await ClasseEntity.context.perform {
                                // Liste des Progressions de la classe triée par numéro de Séquence / Activité
                                sortedClasseProgresses = classe.allProgressesSortedBySequenceActivityNumber
                            }

                            var classeSeances: SeancesInDateInterval = .init()
                            var forDiscipline = Discipline.autre
                            var forClasseName = ""

                            await ClasseEntity.context.perform {
                                forDiscipline = classe.disciplineEnum
                                forClasseName = classe.displayString
                            }

                            // Liste des Séances à venir pour cette classe
                            await classeSeances.loadSeancesFromCalendar(
                                forDiscipline: forDiscipline,
                                forClasseName: forClasseName,
                                inCalendar: calendar,
                                inEventStore: eventStore,
                                during: DateInterval(
                                    start: Date.now,
                                    end: horizon.months.fromNow!
                                )
                            )

                            await ClasseEntity.context.perform {
                                // Synchroniser les Progressions de la classe avec les Séances de la classe
                                SequenceSeanceCoordinator.synchronize(
                                    classeSeances: &classeSeances,
                                    withProgresses: sortedClasseProgresses
                                )
                            }

                            return classeSeances.seances
                        }
                    }
                    for await seances in group {
                        foundSeances.append(contentsOf: seances)
                    }
                }

                // remettre les séances dans l'ordre (async => désordre)
                foundSeances.sort(by: {
                    $0.interval.start < $1.interval.start
                })

                // Ajouter les séances de cette classe à celles de l'établissement
                schoolSeances = SeancesInDateInterval(from: foundSeances)
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

// struct SchoolNextSeancesView_Previews: PreviewProvider {
//    static var previews: some View {
//        SchoolNextSeancesView()
//    }
// }
