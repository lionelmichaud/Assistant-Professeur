//
//  ClassActivityProgressView.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 19/02/2023.
//

import SwiftUI

/// Situation de la progression d'une classe par Activité d'une Séquence donnée
struct ClassActivityProgressEditView: View {
    // MARK: - Initializer

    init(progress: ActivityProgressEntity) {
        self.progress = progress
        self._isExpanded =
            State(initialValue: progress.status == .inProgress)
    }

    // MARK: - Properties

    @ObservedObject
    private var progress: ActivityProgressEntity

    @EnvironmentObject
    private var navig: NavigationModel

    @Environment(\.horizontalSizeClass)
    private var hClass

    @State
    private var isExpanded: Bool = false

    @State
    private var progressValue: Double = 0

    var body: some View {
        DisclosureGroup(isExpanded: $isExpanded) {
            ViewThatFits(in: .horizontal) {
                // priorité 1
                regulartView
                // priorité 2
                compactView
            }

        } label: {
            labelView
        }
    }
}

// MARK: - Subviews

extension ClassActivityProgressEditView {
    private var labelView: some View {
        Group {
            if let activity = progress.activity {
                HStack(alignment: .top) {
                    CompletionSymbol(status: progress.status)
                    LabeledActivityView(activity: activity)
                        .font(hClass == .compact ? .callout : .headline)
                        .bold()
                    Spacer()
                    ActivityAllSymbols(
                        activity: activity,
                        showTitle: false
                    )
                }
            } else {
                Text("nil")
            }
        }
    }

    private var voirButton: some View {
        Button("Voir") {
            if let activity = progress.activity,
               let sequence = activity.sequence,
               let program = sequence.program {
                navig.selectedTab = .program
                navig.selectedProgramMngObjId = program.objectID
                navig.selectedSequenceMngObjId = sequence.objectID
                navig.selectedActivityMngObjId = activity.objectID
                //                        navig.programPath = NavigationPath()
                //                        navig.programPath.append(program)
                //                        navig.programPath.append(sequence)
            }
        }
        .buttonStyle(.borderedProminent)
    }

    private var regulartView: some View {
        HStack {
            voirButton
            VStack(alignment: .leading) {
                LabeledContent("Progression") {
                    ActivityProgressSlider(progress: progress)
                        .frame(minWidth: 150)
                }

                TextField(
                    "",
                    text: $progress.annotation.bound,
                    prompt: Text("description")
                )
                .onSubmit {
                    try? ActivityProgressEntity.saveIfContextHasChanged()
                }
                .lineLimit(5)
                .textFieldStyle(.roundedBorder)
            }
            .font(hClass == .compact ? .callout : .body)
        }
        .padding(.leading)
    }

    private var compactView: some View {
        VStack(alignment: .leading) {
            LabeledContent("Progrès") {
                ActivityProgressSlider(progress: progress)
            }
            HStack {
                voirButton
                TextField(
                    "",
                    text: $progress.annotation.bound,
                    prompt: Text("description")
                )
                .onSubmit {
                    try? ActivityProgressEntity.saveIfContextHasChanged()
                }
                .lineLimit(5)
                .textFieldStyle(.roundedBorder)
            }
            .font(hClass == .compact ? .callout : .body)
        }
    }
}

struct ClassActivityProgressView_Previews: PreviewProvider {
    static func initialize() {
        DataBaseManager.populateWithMockData(storeType: .inMemory)
    }

    static var previews: some View {
        initialize()
        let classe = ClasseEntity.all().first!
        let progress = classe.allProgresses.first!
        //            let currentActivity = classe.currentActivity!
        //            let currentSequence = currentActivity.sequence!
        //            let progress = ClasseEntity.all().first!.currentActivity
        return Group {
            List {
                ClassActivityProgressEditView(progress: progress)
            }
            .padding()
            .previewDevice("iPad mini (6th generation)")
            List {
                ClassActivityProgressEditView(progress: progress)
            }
            .padding()
            .previewDevice("iPhone 13")
        }
        .environmentObject(NavigationModel(selectedClasseMngObjId: ClasseEntity.all().first!.objectID))
        .environment(\.managedObjectContext, CoreDataManager.shared.context)
    }
}
