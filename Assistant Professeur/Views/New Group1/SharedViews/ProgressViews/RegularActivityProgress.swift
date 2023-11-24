//
//  RegularProgressView.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 03/11/2023.
//

import SwiftUI

struct RegularActivityProgress: View {
    @ObservedObject
    var progress: ActivityProgressEntity

    @Binding
    var progressChanged: Bool

    @Environment(\.horizontalSizeClass)
    private var hClass

    var body: some View {
        VStack(alignment: .leading) {
            LabeledContent("Progression") {
                ActivityProgressSlider(
                    progress: progress,
                    progressChanged: $progressChanged
                )
                .frame(minWidth: 250)
            }

            annotation

            if let activity = progress.activity {
                if activity.hasSomeDocumentForEleves {
                    HStack {
                        DocPrintedToggle(
                            isPrinted: $progress.isPrinted,
                            nbExemplaires: progress.classe?.nbOfEleves,
                            save: {
                                try? ActivityProgressEntity.saveIfContextHasChanged()
                            }
                        )
                        Spacer()
                        DocDistributedToggle(
                            isDistributed: $progress.isDistributed,
                            save: {
                                try? ActivityProgressEntity.saveIfContextHasChanged()
                            }
                        )
                    }
                }
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

//#Preview {
//    RegularProgressView()
//}
