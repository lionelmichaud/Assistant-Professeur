//
//  ProgramStepperView.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 23/02/2023.
//

import HelpersView
import StepperView
import SwiftUI

/// Vue en chemin de fer d'un programme complet
struct ProgramStepperView: View {
    @ObservedObject
    var program: ProgramEntity

    var body: some View {
        ScrollView(Axis.Set.vertical, showsIndicators: false) {
            headerView

            if program.nbOfSequences > 0 {
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
}

// MARK: - Subviews

extension ProgramStepperView {
    var headerView: some View {
        VStack(alignment: .center) {
            HStack {
                Text("Programme de")
                ProgramDisciplineLevel(program: program)
            }
            .foregroundColor(.teal)
            .padding(.bottom, 6)
            Text(program.viewAnnotation)
                .padding(.bottom, 6)
            HStack {
                DurationView(duration: program.durationWithoutMargin, withMargin: false)
                    .padding(.trailing)
                DurationView(duration: program.durationWithMargin, withMargin: true)
                    .padding(.trailing)
                WebsiteView(url: program.url)
            }
        }
        .padding(8)
        .background(RoundedRectangle(cornerRadius: 8).stroke(.teal, lineWidth: 1))
    }

    private var steps: [AnyView] {
        program
            .sequencesSortedByNumber
            .map { sequence in
                VStack(alignment: .leading) {
                    Text(sequence.viewName)
                        .bold()
                        .foregroundColor(.teal)
                        .textSelection(.enabled)
                    Text(sequence.viewAnnotation)
                        .textSelection(.enabled)
                }
                .eraseToAnyView()
            }
    }

    private var indicators: [StepperIndicationType<AnyView>] {
        program
            .sequencesSortedByNumber
            .map { sequence in
                StepperIndicationType
                    .custom(NumberedCircleView(
                        text: "S\(sequence.viewNumber)",
                        color: .teal,
                        triggerAnimation: true
                    )
                    .eraseToAnyView())
            }
    }

    private var pitStops: [AnyView] {
        program
            .sequencesSortedByNumber
            .map { sequence in
                VStack(alignment: .leading) {
                    HStack {
                        DurationView(duration: sequence.durationWithoutMargin, withMargin: false)
                        Spacer()
                        DurationView(duration: sequence.durationWithMargin, withMargin: true)
                        Spacer()
                        WebsiteView(url: sequence.url)
                    }
                    .font(.callout)
                    .bold()
                }
                .eraseToAnyView()
            }
    }

    private var pitStopLineOptions: [StepperLineOptions] {
        program
            .sequencesSortedByNumber
            .map { _ in
                StepperLineOptions.custom(1, Color.teal)
            }
    }
}

// struct ProgramStepperView_Previews: PreviewProvider {
//    static var previews: some View {
//        ProgramStepperView()
//    }
// }
