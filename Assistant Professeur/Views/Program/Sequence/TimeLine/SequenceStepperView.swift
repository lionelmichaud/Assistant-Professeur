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
                    .background(Circle().stroke(.teal, lineWidth: 1))
            }
            .foregroundColor(.teal)
            .padding(.bottom, 6)
            if sequence.viewAnnotation.isNotEmpty {
                Text("Problématique:")
                    .bold()
                Text(sequence.viewAnnotation)
                    .padding(.leading)
                    .padding(.bottom, 6)
            }
            DurationView(duration: sequence.durationWithoutMargin, withMargin: false)
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
                            .foregroundColor(.teal)
                            .textSelection(.enabled)
                        ForEach(classes) { classe in
                            if classe.currentActivity == activity {
                                ClassCapsule(classe: classe)
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
                    ActivitySymbolProject(
                        activity: activity,
                        showTitle: true
                    )
                    .font(.footnote)
                    ActivitySymbolTP(
                        activity: activity,
                        showTitle: true
                    )
                    ActivitySymbolEvalFormmative(
                        activity: activity,
                        showTitle: true
                    )
                    ActivitySymbolEvalSommative(
                        activity: activity,
                        showTitle: true
                    )
                }
                .eraseToAnyView()
            }
    }

    private var pitStopLineOptions: [StepperLineOptions] {
        sequence
            .activitiesSortedByNumber
            .map { _ in
                StepperLineOptions.custom(1, Color.teal)
            }
    }
}

// struct SequenceStepperView_Previews: PreviewProvider {
//    static var previews: some View {
//        SequenceStepperView()
//    }
// }
