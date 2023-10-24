//
//  LiveCoursProgressLiveActivity.swift
//  LiveCoursProgress
//
//  Created by Lionel MICHAUD on 08/10/2023.
//

import AppFoundation

// import ActivityKit
import SwiftUI
import WidgetKit

struct LiveCoursProgressLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: LiveCoursProgressAttributes.self) { context in
            // Lock screen/banner UI goes here
            LockScreenContent(
                fixedAttributes: context.attributes.fixedAttributes,
                dynamicAttributes: context.state.dynamicAttributes,
                isStale: context.isStale
            )
            .activityBackgroundTint(Color.liveActivityBackground.opacity(0.25))

            // MARK: - Deep Link vers l'appli

            .widgetURL(URL(string: "assistprof://update-progress?classe=\(context.attributes.fixedAttributes.classeName)"))

        } dynamicIsland: { context in

            // MARK: - Expanded

            DynamicIsland {
                // Expanded UI goes here. Compose the expanded UI through
                // various regions, like leading/trailing/center/bottom
                expandedContent(
                    fixedAttributes: context.attributes.fixedAttributes,
                    dynamicAttributes: context.state.dynamicAttributes,
                    isStale: context.isStale
                )

                // MARK: - Compact
            } compactLeading: {
                CompactLeadingContent(
                    fixedAttributes: context.attributes.fixedAttributes,
                    dynamicAttributes: context.state.dynamicAttributes
                )
            } compactTrailing: {
                CompactTrailingContent(
                    fixedAttributes: context.attributes.fixedAttributes,
                    dynamicAttributes: context.state.dynamicAttributes, 
                    isStale: context.isStale
                )

                // MARK: - Minimal
            } minimal: {
                MinimalContent(
                    fixedAttributes: context.attributes.fixedAttributes,
                    dynamicAttributes: context.state.dynamicAttributes,
                    isStale: context.isStale
                )
            }
            .keylineTint(Color.red)

            // MARK: - Deep Link vers l'appli

            .widgetURL(URL(string: "assistprof://update-progress?classe=\(context.attributes.fixedAttributes.classeName)"))
        }
    }

    // MARK: - Expanded

    @DynamicIslandExpandedContentBuilder
    private func expandedContent(
        fixedAttributes: LiveCoursProgressFixedAttributes,
        dynamicAttributes: LiveCoursProgressState,
        isStale: Bool
    ) -> DynamicIslandExpandedContent<some View> {
        DynamicIslandExpandedRegion(.leading) {
            // heure de début de cours
            Text("\(fixedAttributes.seance.start.formatted(date: .omitted, time: .shortened))")
                .bold()
        }
        DynamicIslandExpandedRegion(.trailing) {
            // heure de fin de cours
            Text("\(fixedAttributes.seance.end.formatted(date: .omitted, time: .shortened))")
                .bold()
        }
        DynamicIslandExpandedRegion(.center) {
            // Classe
            Text(fixedAttributes.classeName)
                .bold()
        }
        DynamicIslandExpandedRegion(.bottom) {
            // Minuterie
            if let remainingMinutes = dynamicAttributes.remainingMinutes,
               let elapsedMinutes = dynamicAttributes.elapsedMinutes {
                if remainingMinutes <= 0 {
                    // Cours terminé
                    Text("Terminé \(Image(systemName: "clock.badge.exclamationmark.fill")) ")
                        .padding(4)
                        .background(ContainerRelativeShape().fill(Color.red))
                        .padding(.vertical)

                } else {
                    // Cours en cours
                    HStack(alignment: .center) {
                        ProgressBar(
                            value: Double(elapsedMinutes) / Double(elapsedMinutes + remainingMinutes),
                            foreGroundColor: isStale ? .gray : dynamicAttributes.timerZone.color
                        )
                        Text("\(remainingMinutes) min")
                            .foregroundStyle(
                                isStale ? .gray : dynamicAttributes.timerZone.color
                            )
                            .bold()
                            .contentTransition(.numericText(value: Double(remainingMinutes)))
                    }
                    .frame(height: 10)
                    .padding(.horizontal)
                }
            } else {
                // Cours terminé
                Text("Terminé \(Image(systemName: "clock.badge.exclamationmark.fill")) ")
                    .padding(4)
                    .background(ContainerRelativeShape().fill(Color.red))
                    .padding(.bottom)
            }
        }
    }
}

// MARK: - Previews

extension LiveCoursProgressAttributes {
    static var preview: LiveCoursProgressAttributes {
        LiveCoursProgressAttributes(
            fixedAttributes: LiveCoursProgressFixedAttributes(
                seance: .init(
                    start: Date.now,
                    end: 55.minutes.fromNow!
                ),
                classeName: "4E2",
                warningRemainingMinutes: 10,
                alertRemainingMinutes: 5
            )
        )
    }
}

extension LiveCoursProgressAttributes.ContentState {
    static var state1: LiveCoursProgressAttributes.ContentState {
        LiveCoursProgressAttributes.ContentState(
            dynamicAttributes: LiveCoursProgressState(
                elapsedMinutes: 30,
                remainingMinutes: 25,
                timerZone: .normal
            )
        )
    }

    static var state2: LiveCoursProgressAttributes.ContentState {
        LiveCoursProgressAttributes.ContentState(
            dynamicAttributes: LiveCoursProgressState(
                elapsedMinutes: 45,
                remainingMinutes: 10,
                timerZone: .warning
            )
        )
    }

    static var state3: LiveCoursProgressAttributes.ContentState {
        LiveCoursProgressAttributes.ContentState(
            dynamicAttributes: LiveCoursProgressState(
                elapsedMinutes: 52,
                remainingMinutes: 3,
                timerZone: .alert
            )
        )
    }

    static var state4: LiveCoursProgressAttributes.ContentState {
        LiveCoursProgressAttributes.ContentState(
            dynamicAttributes: LiveCoursProgressState(
                elapsedMinutes: 56,
                remainingMinutes: -1,
                timerZone: .undefined
            )
        )
    }
}

#Preview(
    "Island Expanded",
    as: .dynamicIsland(.expanded),
    using: LiveCoursProgressAttributes.preview
) {
    LiveCoursProgressLiveActivity()
} contentStates: {
    LiveCoursProgressAttributes.ContentState.state1
    LiveCoursProgressAttributes.ContentState.state2
    LiveCoursProgressAttributes.ContentState.state3
    LiveCoursProgressAttributes.ContentState.state4
}
