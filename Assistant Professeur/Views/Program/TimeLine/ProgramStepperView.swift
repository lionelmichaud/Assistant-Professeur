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

    @EnvironmentObject
    private var userContext: UserContext

    var body: some View {
        if forPdfExport {
            VStack(alignment: .leading) {
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
            HStack(alignment: .center) {
                if forPdfExport {
                    Text("Progression pédagogique")
                        .bold()
                        .foregroundColor(Color.blue4)
                }
                ProgramDisciplineLevel(program: program)
                    .foregroundColor(Color.blue4)
                    .bold()
                    .padding(.bottom, 6)
            }
            if program.viewAnnotation.isNotEmpty {
                Text(program.viewAnnotation)
                    .padding(.bottom, 6)
            }
            // Compétences socle associées
            if program.workedCompSortedByAcronym.isNotEmpty {
                Text("Compétences socle associées:")
                    .bold()
                if !forPdfExport {
                    WCompTagList(
                        workedComps: program.workedCompSortedByAcronym,
                        font: .footnote
                    )
                } else {
                    HStack {
                        ForEach(program.workedCompSortedByAcronym) { comp in
                            Text("(\(comp.viewAcronym))")
                                .foregroundStyle(Color.blue4)
                                .bold()
                        }
                    }
                    .padding(.bottom, 6)
                }
            }
            // Compétences disciplinaires associées
            if program.disciplineCompSortedByAcronym.isNotEmpty {
                Text("Compétences disciplinaires associées:")
                    .bold()
                if !forPdfExport {
                    DCompTagList(
                        disciplineComps: program.disciplineCompSortedByAcronym,
                        font: .footnote
                    )
                } else {
                    HStack {
                        ForEach(program.disciplineCompSortedByAcronym) { comp in
                            Text("(\(comp.viewAcronym))")
                                .foregroundStyle(Color.blue4)
                                .bold()
                        }
                    }
                    .padding(.bottom, 6)
                }
            }
            // Durée du programme annuel
            HStack {
                DurationView(duration: program.durationWithoutMargin, withMargin: false)
                    .padding(.trailing)
                DurationView(duration: program.durationWithMargin, withMargin: true)
                    .padding(.trailing)
                if let margin = program.marginToEndOfYear(schoolYear: userContext.prefs.viewSchoolYearPref)?.nbSeances {
                    let remainder = margin.remainder(dividingBy: 1.0)
                    Label(
                        "\(margin.formatted(.number.precision(.fractionLength(remainder == 0.0 ? 0 : 1)))) séances",
                        systemImage: "arrowshape.left.arrowshape.right.fill"
                    )
                    .foregroundColor(margin > 0 ? .green : .red)
                    Spacer()
                }
                WebsiteView(url: program.url, showURL: false)
            }
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
            // .lineOptions(StepperLineOptions.custom(1, Color.teal))
            // .spacing(80) // auto calculates spacing between steps based on the content.
            .padding([.horizontal, .top])
            .padding(.bottom, 50)
    }

    private var steps: [AnyView] {
        program
            .sequencesSortedByNumber
            .map { sequence in
                VStack(alignment: .leading, spacing: 0) {
                    Text(sequence.viewName)
                        .bold()
                        .foregroundColor(Color.blue4)
                        .textSelection(.enabled)
                    if !forPdfExport {
                        let classesInProgress =
                            ProgramManager
                                .classesAssociatedTo(thisSequence: sequence)
                                .filter { sequence.statusFor(classe: $0) == .inProgress }
                        ClasseTagList(
                            classes: classesInProgress,
                            font: .body
                        )
                    } else if let annotation = sequence.annotation {
                            Text(annotation)
                                .foregroundColor(Color.blue4)
                                .textSelection(.enabled)
                    }
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
                HStack {
                    DurationSquareView(
                        duration: sequence.durationWithoutMargin,
                        withMargin: true,
                        margin: Int(sequence.margePostSequence)
                    )
                    Spacer()
                    if !forPdfExport {
                        WebsiteView(url: sequence.url, showURL: false)
                    }
                }
                .font(.callout)
                .bold()
                .eraseToAnyView()
            }
    }

    private var pitStopLineOptions: [StepperLineOptions] {
        program
            .sequencesSortedByNumber
            .map { _ in
                StepperLineOptions.custom(1, Color.blue4)
            }
    }
}

// struct ProgramStepperView_Previews: PreviewProvider {
//    static var previews: some View {
//        ProgramStepperView()
//    }
// }
