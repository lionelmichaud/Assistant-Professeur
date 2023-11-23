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

            // Deep Link vers l'appli
            .widgetURL(
                URL(
                    string: urlScheme + "://" + urlAction + "?" + urlQueries(context.attributes.fixedAttributes)
                )
            )

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

            // Deep Link vers l'appli
            .widgetURL(
                URL(
                    string: urlScheme + "://" + urlAction + "?" + urlQueries(context.attributes.fixedAttributes)
                )
            )
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
            LiveActivityProgressBar(
                remainingMinutes: dynamicAttributes.remainingMinutes,
                elapsedMinutes: dynamicAttributes.elapsedMinutes,
                isStale: isStale,
                progressColor: dynamicAttributes.timerZone.color
            )
        }
    }

    // MARK: - Deep Link URL

    private let urlScheme: String = "assistprof"
    private let urlAction: String = "update-progress"

    private func urlQueries(_ fixedAttributes: LiveCoursProgressFixedAttributes) -> String {
        schoolQuery(fixedAttributes) + "&" + classeQuery(fixedAttributes)
    }

    private func schoolQuery(_ fixedAttributes: LiveCoursProgressFixedAttributes) -> String {
        "school=\(fixedAttributes.schoolName)"
    }

    private func classeQuery(_ fixedAttributes: LiveCoursProgressFixedAttributes) -> String {
        "classe=\(fixedAttributes.classeName)"
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
                schoolName: "Niel",
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
