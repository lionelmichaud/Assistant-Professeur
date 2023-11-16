//
//  SequenceStepperView.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 22/02/2023.
//

import StepperView
import SwiftUI

/// Vue en chemin de fer d'une séquence complète
struct SequenceStepperView: View {
    @ObservedObject
    var sequence: SequenceEntity

    let forPdfExport: Bool

    var body: some View {
        if forPdfExport {
            VStack(alignment: .leading) {
                headerView

                if sequence.nbOfActivities > 0 {
                    stepperView
                }
            }
            .padding()

        } else {
            ScrollView(Axis.Set.vertical, showsIndicators: false) {
                headerView

                if sequence.nbOfActivities > 0 {
                    stepperView
                }
            }
            .padding(.bottom)
        }
    }
}

// MARK: - Subviews

extension SequenceStepperView {
    var headerView: some View {
        VStack(alignment: .leading) {
            Label {
                Text(sequence.viewName)
            } icon: {
                Text("S\(sequence.viewNumber)")
                    .padding(6)
                    .background(
                        Circle().stroke(Color.blue4, lineWidth: 1)
                    )
            }
            .bold()
            .foregroundColor(Color.blue4)
            .padding(.bottom, 6)

            if sequence.viewAnnotation.isNotEmpty {
                Text("Problématique:")
                    .bold()
                Text(sequence.viewAnnotation)
                    .padding(.leading)
                    .padding(.bottom, 6)
            }
            // Compétences socle associées
            if sequence.workedCompSortedByAcronym.isNotEmpty {
                Text("Compétences socle associées:")
                    .bold()
                if !forPdfExport {
                    WCompTagList(
                        workedComps: sequence.workedCompSortedByAcronym,
                        font: .footnote
                    )
                } else {
                    HStack {
                        ForEach(sequence.workedCompSortedByAcronym) { comp in
                            Text("(\(comp.viewAcronym))")
                                .foregroundStyle(Color.blue4)
                                .bold()
                        }
                    }
                    .padding(.bottom, 6)
                }
            }
            // Compétences disciplinaires associées
            if sequence.disciplineCompSortedByAcronym.isNotEmpty {
                Text("Compétences disciplinaires associées:")
                    .bold()
                if !forPdfExport {
                    DCompTagList(
                        disciplineComps: sequence.disciplineCompSortedByAcronym,
                        font: .footnote
                    )
                } else {
                    HStack {
                        ForEach(sequence.disciplineCompSortedByAcronym) { comp in
                            Text("(\(comp.viewAcronym))")
                                .foregroundStyle(Color.blue4)
                                .bold()
                        }
                    }
                    .padding(.bottom, 6)
                }
            }
            // Durée de la séquence
            DurationView(
                duration: sequence.durationWithoutMargin,
                withMargin: false
            )
        }
        .textSelection(.enabled)
        .padding(8)
        .background {
            RoundedRectangle(cornerRadius: 8).stroke(Color.blue4, lineWidth: 1)
        }
        .padding(.horizontal)
    }

    var stepperView: some View {
        StepperView()
            .addSteps(steps)
            .indicators(indicators)
            .addPitStops(pitStops)
            .pitStopLineOptions(pitStopLineOptions)
            .spacing(100)
            .loadingAnimationTime(0.01)
            // .autoSpacing(true)
            // .lineOptions(StepperLineOptions.custom(2, Color.teal))
            // .spacing(80) // auto calculates spacing between steps based on the content.
            .padding([.horizontal, .top])
            .padding(.bottom, 50)
    }

    private var steps: [AnyView] {
        sequence
            .activitiesSortedByNumber
            .compactMap { activity in
                if activity.viewDuration == 0 {
                    return nil

                } else {
                    let classesInProgress =
                    ProgramManager
                        .classesAssociatedTo(thisActivity: activity)
                        .filter { $0.currentActivity == activity }

                    return VStack(alignment: .leading, spacing: 0) {
                        Text(activity.viewName)
                            .foregroundColor(Color.blue4)
                            .textSelection(.enabled)
                        if !forPdfExport {
                            ClasseTagList(
                                classes: classesInProgress,
                                font: .body
                            )
                        } else if let annotation = activity.annotation {
                            Text(annotation)
                                .foregroundColor(Color.blue4)
                                .textSelection(.enabled)
                        }
                    }
                    .eraseToAnyView()
                }
            }
    }

    private var indicators: [StepperIndicationType<AnyView>] {
        sequence
            .activitiesSortedByNumber
            .compactMap { activity in
                if activity.viewDuration == 0 {
                    return nil
                } else {
                    return StepperIndicationType
                        .custom(NumberedCircleView(
                            text: "A\(activity.viewNumber)",
                            color: Color.blue4,
                            triggerAnimation: true
                        )
                        .eraseToAnyView())
                }
            }
    }

    private var pitStops: [AnyView] {
        sequence
            .activitiesSortedByNumber
            .compactMap { activity in
                if activity.viewDuration == 0 {
                    return nil
                } else {
                    return VStack(alignment: .leading) {
                        HStack {
                            DurationSquareView(
                                duration: activity.duration,
                                withMargin: false,
                                margin: 0
                            )
                            .font(.callout)
                            .bold()
                            .padding(.bottom, 1)

                            Spacer()

                            ActivityAllSymbols(
                                activity: activity,
                                showTitle: true,
                                axis: .horizontal
                            )
                        }

                        // Compétences disciplinaires associées
                        if activity.allDisciplineCompetencies.isNotEmpty {
                            DCompTagList(
                                disciplineComps: activity.disciplineCompSortedByAcronym,
                                font: .footnote
                            )
                            .padding([.top, .bottom], 1)
                        }
                    }
                    .eraseToAnyView()
                }
            }
    }

    private var pitStopLineOptions: [StepperLineOptions] {
        sequence
            .activitiesSortedByNumber
            .compactMap { activity in
                if activity.viewDuration == 0 {
                    return nil
                } else {
                    return StepperLineOptions.custom(1, Color.blue4)
                }
            }
    }
}

// struct SequenceStepperView_Previews: PreviewProvider {
//    static var previews: some View {
//        SequenceStepperView()
//    }
// }
