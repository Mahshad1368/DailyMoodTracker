//
//  MoodFlexWidgetLiveActivity.swift
//  MoodFlexWidget
//
//  Created by Mahshad Jafari on 18.11.25.
//

import ActivityKit
import WidgetKit
import SwiftUI

struct MoodFlexWidgetAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        // Dynamic stateful properties about your activity go here!
        var emoji: String
    }

    // Fixed non-changing properties about your activity go here!
    var name: String
}

struct MoodFlexWidgetLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: MoodFlexWidgetAttributes.self) { context in
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

extension MoodFlexWidgetAttributes {
    fileprivate static var preview: MoodFlexWidgetAttributes {
        MoodFlexWidgetAttributes(name: "World")
    }
}

extension MoodFlexWidgetAttributes.ContentState {
    fileprivate static var smiley: MoodFlexWidgetAttributes.ContentState {
        MoodFlexWidgetAttributes.ContentState(emoji: "😀")
     }
     
     fileprivate static var starEyes: MoodFlexWidgetAttributes.ContentState {
         MoodFlexWidgetAttributes.ContentState(emoji: "🤩")
     }
}

#Preview("Notification", as: .content, using: MoodFlexWidgetAttributes.preview) {
   MoodFlexWidgetLiveActivity()
} contentStates: {
    MoodFlexWidgetAttributes.ContentState.smiley
    MoodFlexWidgetAttributes.ContentState.starEyes
}
