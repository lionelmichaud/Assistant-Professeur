//
//  ActivityProgressSlider.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 19/02/2023.
//

import SwiftUI

struct ActivityProgressSlider: View {
    @ObservedObject
    var progress: ActivityProgressEntity

    var body: some View {
        Slider(
            value: $progress.progress,
            in: 0 ... 1,
            step: 0.25
        ) {
            Text("Progression")
        } minimumValueLabel: {
            Text("")
        } maximumValueLabel: {
            Text("Fin")
        } onEditingChanged: { editing in
            if !editing {
                try? ActivityProgressEntity.saveIfContextHasChanged()
            }
        }
        .tint(.mint)
        .padding(6)
        .background(Capsule().stroke(Color.mint, lineWidth: 2))
    }
}

//struct ActivityProgressSlider_Previews: PreviewProvider {
//    static var previews: some View {
//        ActivityProgressSlider()
//    }
//}
