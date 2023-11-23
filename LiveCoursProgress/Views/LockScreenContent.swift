//
//  LockScreenContent.swift
//  LiveCoursProgressExtension
//
//  Created by Lionel MICHAUD on 22/10/2023.
//

import SwiftUI
import WidgetKit

struct LockScreenContent: View {
    let fixedAttributes: LiveCoursProgressFixedAttributes
    let dynamicAttributes: LiveCoursProgressState
    let isStale: Bool

    var body: some View {
        VStack {
            // Horaires du cours
            HStack {
                // heure de début de cours
                Text("\(fixedAttributes.seance.start.formatted(date: .omitted, time: .shortened))")
                    .bold()
                Spacer()
                Text("Classe de **\(fixedAttributes.classeName)**")
                Spacer()
                // heure de fin de cours
                Text("\(fixedAttributes.seance.end.formatted(date: .omitted, time: .shortened))")
                    .bold()
            }
            .padding(.top)
            .padding(.bottom)

            // Minuterie
            LiveActivityProgressBar(
                remainingMinutes: dynamicAttributes.remainingMinutes,
                elapsedMinutes: dynamicAttributes.elapsedMinutes,
                isStale: isStale,
                progressColor: dynamicAttributes.timerZone.color
            )
        }
        .padding(.horizontal)
        .foregroundStyle(Color.liveActivityTextColor)
        .background(
            ContainerRelativeShape()
                .fill(Color.liveActivityBackground)
        )
    }
}

#Preview(
    "LockScreen Notification",
    as: .content,
    using: LiveCoursProgressAttributes.preview
) {
    LiveCoursProgressLiveActivity()
} contentStates: {
    LiveCoursProgressAttributes.ContentState.state1
    LiveCoursProgressAttributes.ContentState.state2
    LiveCoursProgressAttributes.ContentState.state3
    LiveCoursProgressAttributes.ContentState.state4
}
