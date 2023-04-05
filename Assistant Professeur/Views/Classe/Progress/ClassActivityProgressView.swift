//
//  ClassActivityProgressView.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 19/02/2023.
//

import SwiftUI

/// Situation de la progression d'une classe par Activité d'une Séquence donnée
struct ClassActivityProgressView: View {
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
    private var navig : NavigationModel

    @Environment(\.horizontalSizeClass)
    private var hClass

    @State
    private var isExpanded: Bool = false

    @State
    private var progressValue: Double = 0

    var body: some View {
        DisclosureGroup(isExpanded: $isExpanded) {
            HStack {
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
                
                VStack(alignment: .leading) {
                    LabeledContent("Progression") {
                        ActivityProgressSlider(progress: progress)
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

        } label: {
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
}

// struct ClassActivityProgressView_Previews: PreviewProvider {
//    static var previews: some View {
//        ClassActivityProgressView()
//    }
// }
