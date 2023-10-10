//
//  LiveCoursProgressLiveActivity.swift
//  LiveCoursProgress
//
//  Created by Lionel MICHAUD on 08/10/2023.
//

import ActivityKit
import WidgetKit
import SwiftUI

struct LiveCoursProgressLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: LiveCoursProgressAttributes.self) { context in
            // Lock screen/banner UI goes here
            VStack {
                Text("Classe de **\(context.attributes.fixedAttributes.classeName)**")
                Text("Temps restant **\(context.state.dynamicAttributes.remaingMinutes) minutes**")
            }
            .activityBackgroundTint(Color.cyan)
            .activitySystemActionForegroundColor(Color.black)

        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded UI goes here.  Compose the expanded UI through
                // various regions, like leading/trailing/center/bottom
                DynamicIslandExpandedRegion(.leading) {
                    Text("Leading")
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text("Trailing")
                }
                DynamicIslandExpandedRegion(.bottom) {
                    Text("Bottom \(context.state.dynamicAttributes.remaingMinutes)")
                    // more content
                }

            } compactLeading: {
                Text("\(context.attributes.fixedAttributes.classeName)")
                    .bold()
            } compactTrailing: {
                Text("**\(context.state.dynamicAttributes.remaingMinutes)** min")

            } minimal: {
                Text("\(context.state.dynamicAttributes.remaingMinutes)")
                    .bold()
            }
            .widgetURL(URL(string: "http://www.apple.com"))
            .keylineTint(Color.red)
        }
    }
}

extension LiveCoursProgressAttributes {
    fileprivate static var preview: LiveCoursProgressAttributes {
        LiveCoursProgressAttributes(
            fixedAttributes: LiveCoursProgressFixedAttributes(classeName: "4E2")
        )
    }
}

extension LiveCoursProgressAttributes.ContentState {
    fileprivate static var state1: LiveCoursProgressAttributes.ContentState {
        LiveCoursProgressAttributes.ContentState(
            dynamicAttributes: LiveCoursProgressState(
                remaingMinutes: 15
            )
        )
     }
     
     fileprivate static var state2: LiveCoursProgressAttributes.ContentState {
         LiveCoursProgressAttributes.ContentState(
            dynamicAttributes: LiveCoursProgressState(
                remaingMinutes: 10
            )
         )
     }
}

#Preview("Notification", as: .content,
         using: LiveCoursProgressAttributes.preview) {
   LiveCoursProgressLiveActivity()
} contentStates: {
    LiveCoursProgressAttributes.ContentState.state1
    LiveCoursProgressAttributes.ContentState.state2
}

#Preview("Island Expanded", as: .dynamicIsland(.expanded),
         using: LiveCoursProgressAttributes.preview) {
    LiveCoursProgressLiveActivity()
} contentStates: {
    LiveCoursProgressAttributes.ContentState.state1
    LiveCoursProgressAttributes.ContentState.state2
}

#Preview("Island Compact", as: .dynamicIsland(.compact),
         using: LiveCoursProgressAttributes.preview) {
    LiveCoursProgressLiveActivity()
} contentStates: {
    LiveCoursProgressAttributes.ContentState.state1
    LiveCoursProgressAttributes.ContentState.state2
}

#Preview("Minimal", as: .dynamicIsland(.minimal),
         using: LiveCoursProgressAttributes.preview) {
    LiveCoursProgressLiveActivity()
} contentStates: {
    LiveCoursProgressAttributes.ContentState.state1
    LiveCoursProgressAttributes.ContentState.state2
}
