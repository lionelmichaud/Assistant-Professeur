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
                    .background(Circle().stroke(Color.blue4, lineWidth: 1))
            }
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
        .background(RoundedRectangle(cornerRadius: 8).stroke(.teal, lineWidth: 1))
    }

    private var steps: [AnyView] {
        sequence
            .activitiesSortedByNumber
            .map { activity in
                let classes = ProgramManager.classesAssociatedTo(thisActivity: activity)
                return VStack(alignment: .leading) {
                    HStack {
                        Text(activity.viewName)
                            .bold()
                            .foregroundColor(Color.blue4)
                            .textSelection(.enabled)
                        ForEach(classes) { classe in
                            if classe.currentActivity == activity {
                                ClasseCapsule(classe: classe)
                            }
                        }
                    }
                    Text(activity.viewAnnotation)
                        .textSelection(.enabled)
                }
                .eraseToAnyView()
            }
    }

    private var indicators: [StepperIndicationType<AnyView>] {
        sequence
            .activitiesSortedByNumber
            .map { activity in
                StepperIndicationType
                    .custom(NumberedCircleView(
                        text: "A\(activity.viewNumber)",
                        color: .teal,
                        triggerAnimation: true
                    )
                    .eraseToAnyView())
            }
    }

    private var pitStops: [AnyView] {
        sequence
            .activitiesSortedByNumber
            .map { activity in
                VStack(alignment: .leading) {
                    DurationSquareView(
                        duration: activity.duration,
                        withMargin: false
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
                            disciplineComps: activity.allDisciplineCompetencies,
                            font: .footnote
                        )
                        .padding([.top, .bottom], 1)
                    }
                }
                .eraseToAnyView()
            }
    }

    private var pitStopLineOptions: [StepperLineOptions] {
        sequence
            .activitiesSortedByNumber
            .map { _ in
                StepperLineOptions.custom(1, Color.blue4)
            }
    }
}

// struct SequenceStepperView_Previews: PreviewProvider {
//    static var previews: some View {
//        SequenceStepperView()
//    }
// }
