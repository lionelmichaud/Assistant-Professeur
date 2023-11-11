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

    @Environment(\.horizontalSizeClass)
    private var hClass

    @EnvironmentObject
    private var userContext: UserContext

    private let horizon = 3 // mois

    @State
    private var classeSequences = [SequenceEntity]()

    @State
    private var classeSeances: SeancesInDateInterval = .init()

    @State
    private var progressChanged: Bool = false

    @State
    private var nbOfSeanceActualyCompleted: Double = 0.0
    @State
    private var nbOfSeanceInProgram: Double = 0.0
    @State
    private var actualProgressInProgram: Double = 0.0

    @State
    private var nbOfSeanceSuposidelyCompleted: Double = 0.0
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
                Text("**Progrès théorique: \(Int(theoricalProgressInProgram * 100.0))%** (\(nbOfSeanceSuposidelyCompleted, format: .number.precision(.fractionLength(0)))/\(nbOfSeanceInProgram, format: .number.precision(.fractionLength(0))) séances)")
                    .foregroundColor(.teal)
                ProgressView(value: theoricalProgressInProgram)
                    .tint(.teal)

                ProgressView(value: actualProgressInProgram)
                    .tint(barColor)
                HStack {
                    Text("**Progrès réel: \(Int(actualProgressInProgram * 100.0))%** (\(nbOfSeanceActualyCompleted, format: .number.precision(.fractionLength(0)))/\(nbOfSeanceInProgram, format: .number.precision(.fractionLength(0))))")
                    Spacer()
                    if let delta {
                        switch delta {
                            case ...(-1):
                                Text("en retard de \(-delta) séances")
                            case 1...:
                                Text("en avance de \(delta) séances")
                            default:
                                Text("")
                        }
                    }
                }
                .foregroundColor(barColor)
            }
            .font(hClass == .compact ? .footnote : .callout)

            ForEach(classeSequences) { sequence in
                if sequence.durationWithoutMargin > 0 {
                    ClassSequenceProgressEditView(
                        sequence: sequence,
                        classe: classe,
                        progressChanged: $progressChanged
                    )
                }
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
                return
            }

            await ClasseEntity.context.perform {
                let schoolYear = userContext.prefs.viewSchoolYearPref

                let horizon = DateInterval(
                    start: Date.now,
                    end: horizon.months.fromNow!
                )

                // Liste des Séances à venir pour cette classe
                classeSeances.loadClasseSeancesFromCalendar(
                    forDiscipline: classe.disciplineEnum,
                    forSchoolName: schoolName,
                    forClasseName: classe.displayString,
                    inCalendar: calendar,
                    inEventStore: eventStore,
                    during: horizon,
                    schoolYear: schoolYear
                )

                // Liste des Progressions de la classe triée par numéro de Séquence / Activité
                let sortedClasseProgresses = classe.allProgressesSortedBySequenceActivityNumber

                // Synchroniser les dates des Progressions d'activités
                // avec les dates des Séances à venir
                SequenceSeanceCoordinator.synchronize(
                    classeProgresses: sortedClasseProgresses,
                    withSeances: classeSeances
                )
            }

            // Avancement réel de la classe dans le programme annuel
            (
                nbOfSeanceActualyCompleted,
                nbOfSeanceInProgram,
                actualProgressInProgram
            ) = classe.actualProgressInProgram()

            // Avancement théorique de la classe dans le programme annuel
            (
                nbOfSeanceSuposidelyCompleted,
                nbOfSeanceInProgram,
                theoricalProgressInProgram
            ) = classe.theoricalProgressInProgram(schoolYear: userContext.prefs.viewSchoolYearPref)

            delta = Int(nbOfSeanceActualyCompleted - nbOfSeanceSuposidelyCompleted)
        }
        #if os(iOS)
        .navigationTitle("Progression \(classe.displayString) en \(classe.discipline!)")
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
