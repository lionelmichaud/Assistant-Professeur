//
//  ClassProgressView.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 18/02/2023.
//

import SwiftUI

struct ClassProgressView: View {
    @ObservedObject
    var progress: ActivityProgressEntity

    @Environment(\.horizontalSizeClass)
    private var hClass

    @State
    private var progressValue: Double = 0

    var body: some View {
        LabeledContent {
            VStack {
                Slider(
                    value: $progress.progress,
                    in: 0 ... 1,
                    step: 0.25
                ) {
                    Text("Progression")
                } minimumValueLabel: {
                    Text("")
                } maximumValueLabel: {
                    Text("Fini")
                } onEditingChanged: { editing in
                    if !editing {
                        try? ActivityProgressEntity.saveIfContextHasChanged()
                    }
                }
                .padding(8)
                .background(Capsule().stroke(Color.orange, lineWidth: 2))

                TextField(
                    "",
                    text: $progress.annotation.bound,
                    prompt: Text("progression")
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
