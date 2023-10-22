//
//  LiveCoursProgressLiveActivity.swift
//  LiveCoursProgress
//
//  Created by Lionel MICHAUD on 08/10/2023.
//

import ActivityKit
import SwiftUI
import WidgetKit

struct LiveCoursProgressLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: LiveCoursProgressAttributes.self) { context in
            // Lock screen/banner UI goes here
            lockScreenContent(
                fixedAttributes: context.attributes.fixedAttributes,
                dynamicAttributes: context.state.dynamicAttributes
            )

        } dynamicIsland: { context in

            // MARK: - Expanded

            DynamicIsland {
                // Expanded UI goes here. Compose the expanded UI through
                // various regions, like leading/trailing/center/bottom
                expandedContent(
                    fixedAttributes: context.attributes.fixedAttributes,
                    dynamicAttributes: context.state.dynamicAttributes
                )

                // MARK: - Compact
            } compactLeading: {
                compactLeadingContent(
                    fixedAttributes: context.attributes.fixedAttributes,
                    dynamicAttributes: context.state.dynamicAttributes
                )
            } compactTrailing: {
                compactTrailingContent(
                    fixedAttributes: context.attributes.fixedAttributes,
                    dynamicAttributes: context.state.dynamicAttributes
                )

                // MARK: - Minimal
            } minimal: {
                minimalContent(
                    fixedAttributes: context.attributes.fixedAttributes,
                    dynamicAttributes: context.state.dynamicAttributes
                )
            }
            .widgetURL(URL(string: "http://www.apple.com"))
            .keylineTint(Color.red)
        }
    }

    //  MARK: - Lock screen/banner

    @ViewBuilder
    private func lockScreenContent(
        fixedAttributes: LiveCoursProgressFixedAttributes,
        dynamicAttributes: LiveCoursProgressState
    ) -> some View {
        VStack {
            Text("Classe de **\(fixedAttributes.classeName)**")
                .padding(.top)
                .padding(.bottom, 4)
            if let remainingMinutes = dynamicAttributes.remainingTime?.minute,
               let elapsedMinutes = dynamicAttributes.elapsedTime?.minute {
                VStack {
                    Text("Temps restant: \(remainingMinutes) minutes")
                        .foregroundStyle(dynamicAttributes.timerZone.color)
                        .bold()
                    ProgressBar(
                        level: Double(elapsedMinutes) / Double(elapsedMinutes + remainingMinutes),
                        foreGroundColor: dynamicAttributes.timerZone.color
                    )
                    .frame(height: 10)
                }
                .padding([.bottom, .leading, .trailing])
            }
        }
        .activityBackgroundTint(Color.cyan)
        .activitySystemActionForegroundColor(Color.black)
    }

    // MARK: - Expanded

    @DynamicIslandExpandedContentBuilder
    private func expandedContent(
        fixedAttributes: LiveCoursProgressFixedAttributes,
        dynamicAttributes: LiveCoursProgressState
    ) -> DynamicIslandExpandedContent<some View> {
        DynamicIslandExpandedRegion(.leading) {
            Text(fixedAttributes.classeName)
                .bold()
        }
        DynamicIslandExpandedRegion(.trailing) {
            Text("Trailing")
        }
        DynamicIslandExpandedRegion(.center) {
            Text("Center")
        }
        DynamicIslandExpandedRegion(.bottom) {
            if let remainingMinutes = dynamicAttributes.remainingTime?.minute,
               let elapsedMinutes = dynamicAttributes.elapsedTime?.minute {
                ProgressView(value: Double(elapsedMinutes), total: Double(elapsedMinutes + remainingMinutes)) {
                    Text("Temps restant: \(remainingMinutes) minutes")
                        .foregroundStyle(dynamicAttributes.timerZone.color)
                        .bold()
                }
                .tint(dynamicAttributes.timerZone.color)
                .padding(8)
                .background(RoundedRectangle(cornerRadius: 8, style: .circular)
                    .fill(.tertiary))
                .contentTransition(.numericText(value: Double(remainingMinutes)))
            }
            // more content
        }
    }

    // MARK: - Compact

    @ViewBuilder
    private func compactLeadingContent(
        fixedAttributes: LiveCoursProgressFixedAttributes,
        dynamicAttributes _: LiveCoursProgressState
    ) -> some View {
        Text("\(fixedAttributes.classeName)")
            .bold()
    }

    @ViewBuilder
    private func compactTrailingContent(
        fixedAttributes _: LiveCoursProgressFixedAttributes,
        dynamicAttributes: LiveCoursProgressState
    ) -> some View {
        if let remainingMinutes = dynamicAttributes.remainingTime?.minute,
           let elapsedMinutes = dynamicAttributes.elapsedTime?.minute {
            ProgressView(value: Double(elapsedMinutes), total: Double(elapsedMinutes + remainingMinutes)) {
                Text("\(remainingMinutes)")
                    .bold()
            }
            .progressViewStyle(.circular)
            .frame(height: 28)
            .tint(dynamicAttributes.timerZone.color)
        }
    }

    // MARK: - Minimal

    @ViewBuilder
    private func minimalContent(
        fixedAttributes _: LiveCoursProgressFixedAttributes,
        dynamicAttributes: LiveCoursProgressState
    ) -> some View {
        if let remainingMinutes = dynamicAttributes.remainingTime?.minute,
           let elapsedMinutes = dynamicAttributes.elapsedTime?.minute {
            ProgressView(value: Double(elapsedMinutes), total: Double(elapsedMinutes + remainingMinutes)) {
                Text("\(remainingMinutes)")
                    .bold()
            }
            .progressViewStyle(.circular)
            .frame(height: 28)
            .tint(dynamicAttributes.timerZone.color)
        } else {
            EmptyView()
        }
    }
}

struct ProgressBar: View {
    let level: Double
    let foreGroundColor: Color

    var body: some View {
        GeometryReader { geometry in
            let frame = geometry.frame(in: .local)
            let boxWidth = frame.width * level

            RoundedRectangle(cornerRadius: 5)
                .foregroundStyle(Color.gray)

            RoundedRectangle(cornerRadius: 5)
                .frame(width: boxWidth)
                .foregroundStyle(foreGroundColor)
        }
    }
}

// MARK: - Previews

private extension LiveCoursProgressAttributes {
    static var preview: LiveCoursProgressAttributes {
        LiveCoursProgressAttributes(
            fixedAttributes: LiveCoursProgressFixedAttributes(
                classeName: "4E2",
                warningRemainingMinutes: 10,
                alertRemainingMinutes: 5
            )
        )
    }
}

private extension LiveCoursProgressAttributes.ContentState {
    static var state1: LiveCoursProgressAttributes.ContentState {
        LiveCoursProgressAttributes.ContentState(
            dynamicAttributes: LiveCoursProgressState(
                elapsedTime: DateComponents(minute: 30),
                remainingTime: DateComponents(minute: 25),
                timerZone: .normal
            )
        )
    }

    static var state2: LiveCoursProgressAttributes.ContentState {
        LiveCoursProgressAttributes.ContentState(
            dynamicAttributes: LiveCoursProgressState(
                elapsedTime: DateComponents(minute: 45),
                remainingTime: DateComponents(minute: 10),
                timerZone: .warning
            )
        )
    }

    static var state3: LiveCoursProgressAttributes.ContentState {
        LiveCoursProgressAttributes.ContentState(
            dynamicAttributes: LiveCoursProgressState(
                elapsedTime: DateComponents(minute: 52),
                remainingTime: DateComponents(minute: 3),
                timerZone: .alert
            )
        )
    }
}

#Preview(
    "Notification",
    as: .content,
    using: LiveCoursProgressAttributes.preview
) {
    LiveCoursProgressLiveActivity()
} contentStates: {
    LiveCoursProgressAttributes.ContentState.state1
    LiveCoursProgressAttributes.ContentState.state2
    LiveCoursProgressAttributes.ContentState.state3
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
}

#Preview(
    "Minimal",
    as: .dynamicIsland(.minimal),
    using: LiveCoursProgressAttributes.preview
) {
    LiveCoursProgressLiveActivity()
} contentStates: {
    LiveCoursProgressAttributes.ContentState.state1
    LiveCoursProgressAttributes.ContentState.state2
    LiveCoursProgressAttributes.ContentState.state3
}
