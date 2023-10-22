//
//  MinimalContentView.swift
//  LiveCoursProgressExtension
//
//  Created by Lionel MICHAUD on 22/10/2023.
//

import SwiftUI
import WidgetKit

struct MinimalContent: View {
    let fixedAttributes: LiveCoursProgressFixedAttributes
    let dynamicAttributes: LiveCoursProgressState

    var body: some View {
        if let remainingMinutes = dynamicAttributes.remainingTime?.minute,
           let elapsedMinutes = dynamicAttributes.elapsedTime?.minute {
            ProgressCircle(
                value: Double(elapsedMinutes),
                total: Double(elapsedMinutes + remainingMinutes),
                foreGroundColor: dynamicAttributes.timerZone.color
            )
            .frame(height: 28)
        } else {
            EmptyView()
        }
    }
}

#Preview(
    "Island Minimal",
    as: .dynamicIsland(.minimal),
    using: LiveCoursProgressAttributes.preview
) {
    LiveCoursProgressLiveActivity()
} contentStates: {
    LiveCoursProgressAttributes.ContentState.state1
    LiveCoursProgressAttributes.ContentState.state2
    LiveCoursProgressAttributes.ContentState.state3
}
