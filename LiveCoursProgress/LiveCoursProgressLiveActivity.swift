//
//  LiveCoursProgressLiveActivity.swift
//  LiveCoursProgress
//
//  Created by Lionel MICHAUD on 08/10/2023.
//

import ActivityKit
import WidgetKit
import SwiftUI

struct LiveCoursProgressAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        // Dynamic stateful properties about your activity go here!
        var emoji: String
    }

    // Fixed non-changing properties about your activity go here!
    var name: String
}

struct LiveCoursProgressLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: LiveCoursProgressAttributes.self) { context in
            // Lock screen/banner UI goes here
            VStack {
                Text("Hello \(context.state.emoji)")
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
                    Text("Bottom \(context.state.emoji)")
                    // more content
                }
            } compactLeading: {
                Text("L")
            } compactTrailing: {
                Text("T \(context.state.emoji)")
            } minimal: {
                Text(context.state.emoji)
            }
            .widgetURL(URL(string: "http://www.apple.com"))
            .keylineTint(Color.red)
        }
    }
}

extension LiveCoursProgressAttributes {
    fileprivate static var preview: LiveCoursProgressAttributes {
        LiveCoursProgressAttributes(name: "World")
    }
}

extension LiveCoursProgressAttributes.ContentState {
    fileprivate static var smiley: LiveCoursProgressAttributes.ContentState {
        LiveCoursProgressAttributes.ContentState(emoji: "😀")
     }
     
     fileprivate static var starEyes: LiveCoursProgressAttributes.ContentState {
         LiveCoursProgressAttributes.ContentState(emoji: "🤩")
     }
}

#Preview("Notification", as: .content, using: LiveCoursProgressAttributes.preview) {
   LiveCoursProgressLiveActivity()
} contentStates: {
    LiveCoursProgressAttributes.ContentState.smiley
    LiveCoursProgressAttributes.ContentState.starEyes
}
