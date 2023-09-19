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

    var body: some View {
        ScrollView(Axis.Set.vertical, showsIndicators: false) {
            headerView

            if sequence.nbOfActivities > 0 {
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
                        Circle().stroke(Color.sequenceTag, lineWidth: 1)
                    )
            }
            .foregroundColor(Color.sequenceTag)
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
                WCompTagList(
                    workedComps: sequence.workedCompSortedByAcronym,
                    font: .footnote
                )
            }
            // Compétences disciplinaires associées
            if sequence.disciplineCompSortedByAcronym.isNotEmpty {
                Text("Compétences disciplinaires associées:")
                    .bold()
                DCompTagList(
                    disciplineComps: sequence.disciplineCompSortedByAcronym,
                    font: .footnote
                )
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
            RoundedRectangle(cornerRadius: 8).stroke(.teal, lineWidth: 1)
        }
        .padding(.horizontal)
    }

    private var steps: [AnyView] {
        sequence
            .activitiesSortedByNumber
            .compactMap { activity in
                let classesInProgress =
                    ProgramManager
                        .classesAssociatedTo(thisActivity: activity)
                        .filter { $0.currentActivity == activity }

                if activity.viewDuration == 0 {
                    return nil
                } else {
                    return VStack(alignment: .leading, spacing: 0) {
                        Text(activity.viewName)
                            .bold()
                            .foregroundColor(Color.activityTag)
                            .textSelection(.enabled)
                        ClasseTagList(
                            classes: classesInProgress,
                            font: .body
                        )
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
                            color: Color.activityTag,
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
                        DurationSquareView(
                            duration: activity.duration,
                            withMargin: false,
                            margin: 0
                        )
                        .font(.callout)
                        .bold()
                        .padding(.bottom, 1)

                        ActivityAllSymbols(
                            activity: activity,
                            showTitle: true,
                            axis: .horizontal
                        )

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
                    return StepperLineOptions.custom(1, Color.activityTag)
                }
            }
    }
}

// struct SequenceStepperView_Previews: PreviewProvider {
//    static var previews: some View {
//        SequenceStepperView()
//    }
// }
