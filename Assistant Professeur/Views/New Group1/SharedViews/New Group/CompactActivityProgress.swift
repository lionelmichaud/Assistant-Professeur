//
//  CompactProgressView.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 03/11/2023.
//

import SwiftUI
import HelpersView

struct CompactActivityProgress: View {
    @ObservedObject
    var progress: ActivityProgressEntity

    @Binding
    var progressChanged: Bool

    @Environment(\.horizontalSizeClass)
    private var hClass

    var body: some View {
        VStack(alignment: .leading) {
            // Curseur de l'avancement
            ActivityProgressSlider(
                progress: progress,
                progressChanged: $progressChanged
            )

            annotation

            if let activity = progress.activity {
                // documents à imprimer
                if activity.hasSomeDocumentForEleves {
                    DocPrintedToggle(
                        isPrinted: $progress.isPrinted,
                        nbExemplaires: progress.classe?.nbOfEleves,
                        save: { try? ActivityProgressEntity.saveIfContextHasChanged() }
                    )
                    DocDistributedToggle(
                        isDistributed: $progress.isDistributed,
                        save: { try? ActivityProgressEntity.saveIfContextHasChanged() }
                    )
                    .padding(.top, 2)
                }
                // documnts à partager
                if activity.hasSomeDocumentForENT {
                    DocLoadedToggle(
                        isLoaded: $progress.isLoaded,
                        save: { newValue in
                            activity.allProgresses.forEach { prog in
                                prog.isLoaded = newValue
                            }
                            try? ActivityProgressEntity.saveIfContextHasChanged()
                        }
                    )
                    .padding(.top, 2)
                }
                // avancement de la correction de l'éval
                if activity.isEval {
                    Picker("Correction", selection: $progress.evalStatusEnum ) {
                        ForEach(EvalStateEnum.allCases, id: \.self) { enu in
                            Text(enu.pickerString)
                        }
                    }
                    .pickerStyle(.segmented)
                }
            }
        }
    }

    private var annotation: some View {
        TextField(
            "",
            text: $progress.annotation.bound,
            prompt: Text("description"),
            axis: .vertical
        )
        .font(hClass == .compact ? .callout : .body)
        .multilineTextAlignment(.leading)
        .lineLimit(5)
        .textFieldStyle(.roundedBorder)
        .onSubmit {
            try? ActivityProgressEntity.saveIfContextHasChanged()
        }
    }
}

// #Preview {
//    CompactProgressView()
// }
