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
            if isStale {
                // Information périmée
                ProgressBar(
                    value: 1.0,
                    foreGroundColor: .gray
                )

            } else if let remainingMinutes = dynamicAttributes.remainingTime?.minute,
                      let elapsedMinutes = dynamicAttributes.elapsedTime?.minute {
                if remainingMinutes <= 0 {
                    // Cours terminé
                    Text("Terminé \(Image(systemName: "clock.badge.exclamationmark.fill")) ")
                        .padding(4)
                        .background(ContainerRelativeShape().fill(Color.red))
                        .padding(.bottom)

                } else {
                    // Cours en cours
                    HStack(alignment: .center) {
                        ProgressBar(
                            value: Double(elapsedMinutes) / Double(elapsedMinutes + remainingMinutes),
                            foreGroundColor: dynamicAttributes.timerZone.color
                        )
                        Text("\(remainingMinutes) min")
                            .foregroundStyle(dynamicAttributes.timerZone.color)
                            .bold()
                            .contentTransition(.numericText(value: Double(remainingMinutes)))
                    }
                    .frame(height: 10)
                    .padding(.bottom)
                }
            } else {
                // Cours terminé
                Text("Terminé \(Image(systemName: "clock.badge.exclamationmark.fill")) ")
                    .padding(4)
                    .background(ContainerRelativeShape().fill(Color.red))
                    .padding(.bottom)
            }
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
}
