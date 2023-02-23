//
//  SequenceStepperView.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 22/02/2023.
//

import StepperView
import SwiftUI

struct SequenceStepperView: View {
    @ObservedObject
    var sequence: SequenceEntity

    private var steps: [AnyView] {
        sequence
            .activitiesSortedByNumber
            .map { activity in
                Text(activity.viewName)
                    .bold()
                    .foregroundColor(.teal)
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
                    Text("\(activity.viewDuration.formatted(.number.precision(.fractionLength(1)))) séances")
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

    var headerView: some View {
        VStack(alignment: .leading) {
            Text(sequence.viewName)
                .foregroundColor(.teal)
                .padding(.bottom, 6)
            Text("Problématique:")
                .bold()
            Text(sequence.viewAnnotation)
                .padding(.leading)
        }
        .padding(8)
        .background(RoundedRectangle(cornerRadius: 8).stroke(.teal, lineWidth: 1))
    }

    var body: some View {
        ScrollView(Axis.Set.vertical, showsIndicators: false) {
            headerView

            StepperView()
                .addSteps(steps)
                .indicators(indicators)
                .addPitStops(pitStops)
                .pitStopLineOptions(pitStopLineOptions)
                .spacing(100)
                .loadingAnimationTime(0.01)
                // .autoSpacing(true)
                // .lineOptions(StepperLineOptions.custom(1, Color.teal))
                // .spacing(80) // auto calculates spacing between steps based on the content.
                .padding()
        }
    }
}

// struct SequenceStepperView_Previews: PreviewProvider {
//    static var previews: some View {
//        SequenceStepperView()
//    }
// }
