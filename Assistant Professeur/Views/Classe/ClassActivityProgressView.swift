//
//  ClassActivityProgressView.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 19/02/2023.
//

import SwiftUI

struct ClassActivityProgressView: View {
    @ObservedObject
    var progress: ActivityProgressEntity

    @Environment(\.horizontalSizeClass)
    private var hClass

    @State
    private var progressValue: Double = 0

    var body: some View {
        VStack(alignment: .leading) {
            if let activity = progress.activity {
                HStack {
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
            }

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
}

// struct ClassActivityProgressView_Previews: PreviewProvider {
//    static var previews: some View {
//        ClassActivityProgressView()
//    }
// }
