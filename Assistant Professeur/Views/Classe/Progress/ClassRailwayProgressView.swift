//
//  RailwayView.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 27/02/2023.
//

import StepperView
import SwiftUI

struct ClassRailwayProgressView: View {
    @ObservedObject
    var classe: ClasseEntity

    // MARK: - Properties

    private var classeSequences: [SequenceEntity] {
        classe.allFollowedSequencesSortedBySequenceNumber
    }

    // MARK: - Methods

    private func steps(sequence: SequenceEntity) -> [AnyView] {
        classe
            .sortedProgressesInSequence(sequence)
            .map { progress in
                HStack {
                    NumberedCircleView(
                        text: "A\(progress.activity!.viewNumber)",
                        color: .teal,
                        triggerAnimation: false
                    )
                    Text(progress.activity!.viewDurationString)
                }
                .eraseToAnyView()
            }
    }

    private func indicators(sequence: SequenceEntity) -> [StepperIndicationType<AnyView>] {
        classe
            .sortedProgressesInSequence(sequence)
            .map { progress in
                StepperIndicationType
                    .custom(IndicatorImageView(
                        name: progress.status.imageName,
                        size: 30
                    )
                    .eraseToAnyView())
            }
    }

    private func stepLifeCycles(sequence: SequenceEntity) -> [StepLifeCycle] {
        classe
            .sortedProgressesInSequence(sequence)
            .map { progress in
                switch progress.status {
                    case .notStarted: return .pending
                    case .inProgress: return .pending
                    case .completed: return .completed
                    case .invalid: return .pending
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

    func sequenceTitleView(sequence: SequenceEntity) -> some View {
        HStack(alignment: .center) {
            IndicatorImageView(
                name: sequence.statusFor(classe: classe).imageName,
                size: 32
            )
            NumberedCircleView(
                text: "S\(sequence.viewNumber)",
                color: .green,
                triggerAnimation: false
            )
            Text(sequence.viewName)
        }
    }

    var body: some View {
        ForEach(classeSequences) { sequence in
            if sequence.nbOfActivities > 0 {
                GroupBox {
                    sequenceTitleView(sequence: sequence)
                        .padding(.bottom)
                        .frame(maxWidth: .infinity)
                    if sequence.statusFor(classe: classe) == .inProgress {
                        StepperView()
                            .addSteps(steps(sequence: sequence))
                            .indicators(indicators(sequence: sequence))
                            .stepIndicatorMode(.horizontal)
                            // .alignments(alignments(sequence: sequence))
                            .lineOptions(StepperLineOptions.custom(4, Color.teal))
                            // .stepLifeCycles(stepLifeCycles(sequence: sequence))
                            .autoSpacing(true)
                            // .loadingAnimationTime(0.01)
                            .padding([.top, .leading])
                    }
                }
                .padding(.horizontal)
                .horizontallyAligned(.leading)
            }
        }
    }
}

// struct RailwayView_Previews: PreviewProvider {
//    static var previews: some View {
//        RailwayView()
//    }
// }
