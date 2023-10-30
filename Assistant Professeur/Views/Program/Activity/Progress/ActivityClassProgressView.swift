//
//  ClassProgressView.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 18/02/2023.
//

import SwiftUI

/// Progression d'une classe d'un établissement dans une activité donnée
struct ActivityClassProgressView: View {
    @ObservedObject
    var progress: ActivityProgressEntity

    @EnvironmentObject
    private var navig: NavigationModel

    @Environment(\.horizontalSizeClass)
    private var hClass

    var body: some View {
        LabeledContent {
            VStack(alignment: .leading) {
                ActivityProgressSlider(
                    progress: progress,
                    progressChanged: .constant(false)
                )

                TextField(
                    "",
                    text: $progress.annotation.bound,
                    prompt: Text("description"),
                    axis: .vertical
                )
                .onSubmit {
                    try? ActivityProgressEntity.saveIfContextHasChanged()
                }
                .multilineTextAlignment(.leading)
                .lineLimit(5)
                .font(hClass == .compact ? .callout : .body)
                .textFieldStyle(.roundedBorder)

                if let activity = progress.activity,
                   activity.hasSomeDocumentForEleves {
                    DocPrintedToggle(
                        isPrinted: $progress.isPrinted,
                        nbExemplaires: progress.classe?.nbOfEleves,
                        save: { try? ActivityProgressEntity.saveIfContextHasChanged() }
                    )
                    DocDistributedToggle(
                        isDistributed: $progress.isDistributed,
                        save: { try? ActivityProgressEntity.saveIfContextHasChanged() }
                    )
                }
            }
        } label: {
            Button {
                if let classe = progress.classe {
                    DeepLinkManager.handle(
                        navigateTo: .classeProgressUpdate(classe: classe),
                        using: navig
                    )
                }
            } label: {
                Text(progress.classe?.displayString ?? "nil")
                    .bold()
                    .padding(4)
//                    .background {
//                        RoundedRectangle(cornerRadius: 8)
//                            .stroke(Color.primary)
//                            .foregroundColor(.gray)
//                    }
            }
            .buttonStyle(.borderedProminent)
        }
    }
}

// struct ClassProgressView_Previews: PreviewProvider {
//    static var previews: some View {
//        ClassProgressView()
//    }
// }
