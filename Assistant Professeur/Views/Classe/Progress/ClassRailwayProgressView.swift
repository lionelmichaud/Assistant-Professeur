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

    @Environment(\.horizontalSizeClass)
    private var hClass

    // MARK: - Properties

    private var classeSequences: [SequenceEntity] {
        classe.allFollowedSequencesSortedBySequenceNumber
    }

    // MARK: - Methods

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
                            // .autoSpacing(true)
                            .spacing(hClass == .compact ? 35 : 75)
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

// MARK: - Subviews

extension ClassRailwayProgressView {
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
                    VStack(alignment: .leading) {
                        Text(progress.activity!.viewDurationString)
                        if progress.progress > 0 && progress.progress < 1 {
                            Text(progress.progress, format: .percent)
                                .font(.footnote)
                        }
                    }
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

    private func sequenceTitleView(sequence: SequenceEntity) -> some View {
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
