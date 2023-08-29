//
//  ClassGlobalProgress.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 18/02/2023.
//

import EventKit
import HelpersView
import SwiftUI

/// Situation de la progression d'une classe par Séquence / Activité
struct ClassProgressesView: View {
    @ObservedObject
    var classe: ClasseEntity

    private let horizon = 3 // mois

    @State
    private var classeSequences = [SequenceEntity]()

    @State
    private var classeSeances: SeancesInDateInterval = .init()

    @State
    private var progressChanged: Bool = false

    @State
    private var actualProgressInProgram: Double = 0.0

    @State
    private var theoricalProgressInProgram: Double = 0.0

    @State
    private var delta: Int?

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

    private var barColor: Color {
        if let delta {
            return delta < 0 ? .red : .green
        } else {
            return .green
        }
    }

    var body: some View {
        List {
            VStack(alignment: .leading) {
                Text("Progression théorique: \(Int(theoricalProgressInProgram * 100.0))%")
                    .foregroundColor(.teal)
                ProgressView(value: theoricalProgressInProgram)
                    .tint(.teal)

                ProgressView(value: actualProgressInProgram)
                    .tint(barColor)
                HStack {
                    Text("Progression réelle: \(Int(actualProgressInProgram * 100.0))%")
                    Spacer()
                    if let delta {
                        if delta < 0 {
                            Text("en retard de \(-delta) séances")
                        } else {
                            Text("en avance de \(delta) séances")
                        }
                    }
                }
                .foregroundColor(barColor)
            }
            .font(.footnote)

            ForEach(classeSequences) { sequence in
                ClassSequenceProgressEditView(
                    sequence: sequence,
                    classe: classe,
                    progressChanged: $progressChanged
                )
            }
            .emptyListPlaceHolder(classeSequences) {
                Text("Aucune séquence suivie par cette classe")
            }
        }
        .alert(
            alertTitle,
            isPresented: $alertIsPresented,
            actions: {},
            message: { Text(alertMessage) }
        )
        .task(id: progressChanged) {
            progressChanged = false

            // Liste des Séquences suivies par une classe triée par numéro de Séquence
            classeSequences = classe.allFollowedSequencesSortedBySequenceNumber

            // Liste des Séances à venir pour cette classe
            if let schoolName = classe.school?.viewName {
                // Demander les droits d'accès aux calendriers de l'utilisateur
                (
                    alertIsPresented,
                    alertTitle,
                    alertMessage
                ) = await EventManager.requestCalendarAccess(eventStore: eventStore)

                if !alertIsPresented {
                    // Récupérer le calendrier
                    (
                        calendar,
                        alertIsPresented,
                        alertTitle,
                        alertMessage
                    ) = EventManager.getOrCreateCalendar(
                        named: schoolName,
                        inEventStore: eventStore
                    )

                    if let calendar {
                        // Liste des Progressions de la classe triée par numéro de Séquence / Activité
                        let sortedClasseProgresses = classe.allProgressesSortedBySequenceActivityNumber

                        classeSeances.loadSeancesFromCalendar(
                            forDiscipline: classe.disciplineEnum,
                            forClasseName: classe.displayString,
                            inCalendar: calendar,
                            inEventStore: eventStore,
                            during: DateInterval(
                                start: Date.now,
                                end: horizon.months.fromNow!
                            )
                        )

                        // Synchroniser les Progressions avec les Séances
                        SequenceSeanceCoordinator.synchronize(
                            classeProgresses: sortedClasseProgresses,
                            withSeances: classeSeances
                        )
                    }
                }
            }

            // Avancement réel de la classe dans le programme annuel
            actualProgressInProgram = classe.actualProgressInProgram()

            // Avancement théorique de la classe dans le programme annuel
            theoricalProgressInProgram = classe.theoricalProgressInProgram()

            if let program = ProgramManager.programAssociatedTo(thisClasse: classe) {
                delta = Int((actualProgressInProgram - theoricalProgressInProgram) * program.durationWithoutMargin)
            } else {
                delta = nil
            }
        }
        #if os(iOS)
        .navigationTitle("Progression en \(classe.discipline!)")
        #endif
        .navigationBarTitleDisplayModeInline()
    }
}

struct ClassProgressesView_Previews: PreviewProvider {
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
            List {
                ClassProgressesView(classe: classe)
            }
            .padding()
            .previewDevice("iPad mini (6th generation)")
            List {
                ClassProgressesView(classe: classe)
            }
            .padding()
            .previewDevice("iPhone 13")
        }
        .environmentObject(NavigationModel(selectedClasseMngObjId: ClasseEntity.all().first!.objectID))
        .environment(\.managedObjectContext, CoreDataManager.shared.context)
    }
}
