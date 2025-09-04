//
//  dailyhadiahLiveActivity.swift
//  dailyhadiah
//
//  Created by Sayed on 2/9/25.
//

import ActivityKit
import WidgetKit
import SwiftUI

struct dailyhadiahAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        // Dynamic stateful properties about your activity go here!
        var emoji: String
    }

    // Fixed non-changing properties about your activity go here!
    var name: String
}

struct dailyhadiahLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: dailyhadiahAttributes.self) { context in
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

extension dailyhadiahAttributes {
    fileprivate static var preview: dailyhadiahAttributes {
        dailyhadiahAttributes(name: "World")
    }
}

extension dailyhadiahAttributes.ContentState {
    fileprivate static var smiley: dailyhadiahAttributes.ContentState {
        dailyhadiahAttributes.ContentState(emoji: "😀")
     }
     
     fileprivate static var starEyes: dailyhadiahAttributes.ContentState {
         dailyhadiahAttributes.ContentState(emoji: "🤩")
     }
}

#Preview("Notification", as: .content, using: dailyhadiahAttributes.preview) {
   dailyhadiahLiveActivity()
} contentStates: {
    dailyhadiahAttributes.ContentState.smiley
    dailyhadiahAttributes.ContentState.starEyes
}
