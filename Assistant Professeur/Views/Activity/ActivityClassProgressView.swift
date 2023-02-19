//
//  ClassProgressView.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 18/02/2023.
//

import SwiftUI

struct ActivityClassProgressView: View {
    @ObservedObject
    var progress: ActivityProgressEntity

    @Environment(\.horizontalSizeClass)
    private var hClass

    var body: some View {
        LabeledContent {
            VStack {
                ActivityProgressSlider(progress: progress)

                TextField(
                    "",
                    text: $progress.annotation.bound,
                    prompt: Text("description")
                )
                .onSubmit {
                    try? ActivityProgressEntity.saveIfContextHasChanged()
                }
                .lineLimit(5)
                .font(hClass == .compact ? .callout : .body)
                .textFieldStyle(.roundedBorder)
            }
        } label: {
            Text(progress.classe?.displayString ?? "nil")
                .bold()
                .padding(8)
                .background {
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.primary)
                        .foregroundColor(.gray)
                }
        }
    }
}

// struct ClassProgressView_Previews: PreviewProvider {
//    static var previews: some View {
//        ClassProgressView()
//    }
// }
