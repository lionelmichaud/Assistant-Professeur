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

    let forPdfExport: Bool

    var body: some View {
        if forPdfExport {
            VStack(alignment: .center) {
                headerView

                if program.nbOfSequences > 0 {
                    stepperView
                }
            }
            .padding()

        } else {
            ScrollView(Axis.Set.vertical, showsIndicators: false) {
                headerView

                if program.nbOfSequences > 0 {
                    stepperView
                }
            }
        }
    }
}

// MARK: - Subviews

extension ProgramStepperView {
    var headerView: some View {
        VStack(alignment: .leading) {
            ProgramDisciplineLevel(program: program)
                .foregroundColor(.teal)
                .padding(.bottom, 6)
            if program.viewAnnotation.isNotEmpty {
                Text(program.viewAnnotation)
                    .padding(.bottom, 6)
            }
            // Compétences socle associées
            if program.workedCompSortedByAcronym.isNotEmpty {
                Text("Compétences socle associées:")
                    .bold()
                WCompTagList(
                    workedComps: program.workedCompSortedByAcronym,
                    font: .footnote
                )
            }
            // Compétences disciplinaires associées
            if program.disciplineCompSortedByAcronym.isNotEmpty {
                Text("Compétences disciplinaires associées:")
                    .bold()
                DCompTagList(
                    disciplineComps: program.disciplineCompSortedByAcronym,
                    font: .footnote
                )
            }
            // Durée du programme annuel
            HStack {
                DurationView(duration: program.durationWithoutMargin, withMargin: false)
                    .padding(.trailing)
                DurationView(duration: program.durationWithMargin, withMargin: true)
                    .padding(.trailing)
                WebsiteView(url: program.url, showURL: false)
            }
        }
        .padding(8)
        .background {
            RoundedRectangle(cornerRadius: 8).stroke(.teal, lineWidth: 1)
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
            // .lineOptions(StepperLineOptions.custom(1, Color.teal))
            // .spacing(80) // auto calculates spacing between steps based on the content.
            .padding([.horizontal, .top])
            .padding(.bottom, 50)
    }

    private var steps: [AnyView] {
        program
            .sequencesSortedByNumber
            .map { sequence in
                let classesInProgress =
                    ProgramManager
                        .classesAssociatedTo(thisSequence: sequence)
                        .filter { sequence.statusFor(classe: $0) == .inProgress }

                return VStack(alignment: .leading, spacing: 0) {
                    Text(sequence.viewName)
                        .bold()
                        .foregroundColor(Color.blue4)
                        .textSelection(.enabled)
                    ClasseTagList(
                        classes: classesInProgress,
                        font: .body
                    )
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
                        color: Color.blue4,
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
                        DurationSquareView(
                            duration: sequence.durationWithoutMargin,
                            withMargin: true,
                            margin: Int(sequence.margePostSequence)
                        )
                        Spacer()
                        WebsiteView(url: sequence.url, showURL: false)
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
