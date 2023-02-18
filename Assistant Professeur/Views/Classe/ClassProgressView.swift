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

    @State
    private var progressValue: Double = 0

    var body: some View {
        LabeledContent {
            Slider(
                value: $progress.progress,
                in: 0 ... 1,
                step: 0.25
            ) {
                Text("Label")
            } minimumValueLabel: {
                Text("0%")
            } maximumValueLabel: {
                Text("100%")
            } onEditingChanged: { editing in
                if !editing {
                    try? ActivityProgressEntity.saveIfContextHasChanged()
                }
            }
            .padding(8)
            .background(Capsule().stroke(Color.orange, lineWidth: 2))
        } label: {
            Text(progress.classe?.displayString ?? "nil")
                .bold()
                .padding(.trailing)
        }
    }
}

// struct ClassProgressView_Previews: PreviewProvider {
//    static var previews: some View {
//        ClassProgressView()
//    }
// }
