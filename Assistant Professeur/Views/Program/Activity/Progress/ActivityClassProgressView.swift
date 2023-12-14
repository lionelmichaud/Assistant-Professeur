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

    @State
    var progressChanged: Bool = false

    @EnvironmentObject
    private var navig: NavigationModel

    var body: some View {
        LabeledContent {
            ViewThatFits(in: .horizontal) {
                // priorité 1
                RegularActivityProgress(
                    progress: progress,
                    progressChanged: $progressChanged
                )
                // .padding(.leading)
                // priorité 2
                CompactActivityProgress(
                    progress: progress,
                    progressChanged: $progressChanged
                )
            }
        } label: {
            Button {
                if let classe = progress.classe {
                    DeepLinkManager.handleLink(
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
