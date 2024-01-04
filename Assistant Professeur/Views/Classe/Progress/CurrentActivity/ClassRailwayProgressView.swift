//
//  RailwayView.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 27/02/2023.
//

import EventKit
import HelpersView
import StepperView
import SwiftUI
import TagKit

struct ClassRailwayProgressView: View {
    @ObservedObject
    var classe: ClasseEntity

    @Environment(\.horizontalSizeClass)
    private var hClass

    @Environment(UserContext.self)
    private var userContext

    // MARK: - Properties

    private let horizon = 3 // mois

    @State
    private var classeSequencesEnCours = [SequenceEntity]()

    @State
    private var classeSeances: SeancesInDateInterval = .init()

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

    // MARK: - Methods

    var body: some View {
        ForEach(classeSequencesEnCours) { sequence in
            let sortedProgressesInSequence = classe
                .sortedProgressesInSequence(sequence)

            GroupBox {
                sequenceTitleView(sequence: sequence)
                    .padding(.bottom)
                    .frame(maxWidth: .infinity)
                StepperView()
                    .indicators(
                        indicators(classeProgresses: sortedProgressesInSequence)
                    )
                    .addSteps(
                        steps(
                            classeProgresses: sortedProgressesInSequence,
                            classeSeances: classeSeances
                        )
                    )
                    .stepIndicatorMode(.horizontal)
                    .lineOptions(
                        StepperLineOptions.custom(4, Color.teal)
                    )
                    .spacing(hClass == .compact ? 50 : 75)
                    // .alignments(alignments(sequence: sequence))
                    // .stepLifeCycles(stepLifeCycles(sequence: sequence))
                    // .autoSpacing(true)
                    // .loadingAnimationTime(0.01)
                    .padding([.top, .leading])
            }
            .padding(.horizontal)
        }
        .emptyListPlaceHolder(classeSequencesEnCours) {
            Text("Aucune séquence en cours ou à venir pour cette classe")
        }
        .alert(
            alertTitle,
            isPresented: $alertIsPresented,
            actions: {},
            message: { Text(alertMessage) }
        )
        .task(id: classe.objectID) {
            // Séquences en cours pour cette classe
            ClasseEntity.context.performAndWait {
                classeSequencesEnCours = classe.currentSequences
            }

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

            ClasseEntity.context.performAndWait {
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
        }
    }
}

// MARK: - Subviews

extension ClassRailwayProgressView {
    private func formattedDate(_ date: Date) -> String {
        let delta = date.days(between: Date.now)
        switch delta {
            case 1:
                return "dem."

            case 2 ... 6:
                return date
                    .formatted(Date.FormatStyle()
                        .weekday(.abbreviated))

            default:
                return date
                    .formatted(Date.FormatStyle()
                        .day(.twoDigits)
                        .month(.twoDigits))
        }
    }

    private func steps(
        classeProgresses progresses: [ActivityProgressEntity],
        // paramètre non utilisé mais oblige la vue à se rafraichire quand le paramètre change
        classeSeances _: SeancesInDateInterval
    ) -> [AnyView] {
        progresses
            .compactMap { progress in
                if progress.activity!.viewDuration == 0 {
                    return nil
                } else {
                    return HStack {
                        // Tag de l'activité
                        NumberedCircleView(
                            text: "A\(progress.activity!.viewNumber)",
                            color: .teal,
                            triggerAnimation: false
                        )
                        // Nombre de séances / Dates des séances à venir
                        VStack(alignment: .leading) {
                            switch progress.status {
                                case .completed:
                                    // Nombre de séances
                                    Text("\(progress.activity!.viewDurationString)s")

                                case .inProgress, .notStarted:
                                    // Nombre de séances
                                    Text("\(progress.activity!.viewDurationString)s")
                                        .font(.footnote)

                                    if let startDate = progress.startDate {
                                        // Date à laquelle débutera l'activité
                                        Text(formattedDate(startDate))
                                            .font(.footnote)
                                        if let endDate = progress.endDate,
                                           endDate.day != startDate.day {
                                            // Date à laquelle se terminera l'activité
                                            Text(formattedDate(endDate))
                                                .font(.footnote)
                                        }
                                    }

                                case .invalid:
                                    EmptyView()
                            }
                        }
                    }
                    .eraseToAnyView()
                }
            }
    }

    private func indicators(
        classeProgresses progresses: [ActivityProgressEntity]
    ) -> [StepperIndicationType<AnyView>] {
        progresses
            .compactMap { progress in
                if progress.activity!.viewDuration == 0 {
                    return nil
                } else {
                    return StepperIndicationType
                        .custom(IndicatorImageView(
                            name: progress.status.imageName,
                            size: 30
                        )
                        .eraseToAnyView())
                }
            }
    }

    //    private func alignments(sequence: SequenceEntity) -> [StepperAlignment] {
    //        classe
    //            .sortedProgressesInSequence(sequence)
    //            .map { _ in
    //                StepperAlignment.bottom
    //            }
    //    }

    private func sequenceTitleView(sequence: SequenceEntity) -> some View {
        HStack(alignment: .center) {
            IndicatorImageView(
                name: sequence.statusFor(classe: classe).imageName,
                size: 32
            )
            SequenceTag(
                sequenceNumber: sequence.viewNumber,
                font: .body
            )
            Text(sequence.viewName)
        }
    }
}

struct ClassRailwayProgressView_Previews: PreviewProvider {
    static func initialize() {
        DataBaseManager.populateWithMockData(storeType: .inMemory)
    }

    static var previews: some View {
        initialize()
        let classe = ClasseEntity.all().first!
        return Group {
            List {
                ClassRailwayProgressView(classe: classe)
            }
            .previewDevice("iPad mini (6th generation)")
            List {
                ClassRailwayProgressView(classe: classe)
            }
            .previewDevice("iPhone 13")
        }
        .environmentObject(NavigationModel(selectedClasseMngObjId: ClasseEntity.all().first!.objectID))
        .environment(\.managedObjectContext, CoreDataManager.shared.context)
    }
}
