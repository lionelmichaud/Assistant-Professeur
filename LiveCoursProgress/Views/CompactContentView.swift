//
//  CompactContentView.swift
//  LiveCoursProgressExtension
//
//  Created by Lionel MICHAUD on 22/10/2023.
//

import SwiftUI
import WidgetKit

struct CompactLeadingContent: View {
    let fixedAttributes: LiveCoursProgressFixedAttributes
    let dynamicAttributes: LiveCoursProgressState

    var body: some View {
        Text("\(fixedAttributes.classeName)")
            .bold()
    }
}

struct CompactTrailingContent: View {
    let fixedAttributes: LiveCoursProgressFixedAttributes
    let dynamicAttributes: LiveCoursProgressState
    let isStale: Bool

    var body: some View {
        if let remainingMinutes = dynamicAttributes.remainingMinutes,
           let elapsedMinutes = dynamicAttributes.elapsedMinutes {
            if remainingMinutes <= 0 {
                // Cours terminé
                TimeOverSymbol()
            } else {
                // Cours en cours
                    ProgressCircle(
                        elapsed: Double(elapsedMinutes),
                        remaining: Double(remainingMinutes),
                        foreGroundColor: isStale ? .gray : dynamicAttributes.timerZone.color
                    )
                    .frame(height: 28)
                    .offset(x:2)
            }
        } else {
            // Cours terminé
            TimeOverSymbol()
        }
    }
}

#Preview(
    "Island Compact",
    as: .dynamicIsland(.compact),
    using: LiveCoursProgressAttributes.preview
) {
    LiveCoursProgressLiveActivity()
} contentStates: {
    LiveCoursProgressAttributes.ContentState.state1
    LiveCoursProgressAttributes.ContentState.state2
    LiveCoursProgressAttributes.ContentState.state3
    LiveCoursProgressAttributes.ContentState.state4
}
