//
//  MyHomeWidget.swift
//  MyHomeWidget
//
//  Created by Sayed on 2/9/25.
//

import WidgetKit
import SwiftUI

struct Provider: AppIntentTimelineProvider {
    // Method to retrieve the data from flutter
    private func getDataFromFlutter() async -> SimpleEntry {
        let userDefault = UserDefaults(suiteName: "group.homeScreenApp")
        let textfromflutterapp = userDefault?.string(forKey: "text_from_flutter")
        return SimpleEntry(date: Date(), title: textfromflutterapp ?? "No data")
    }        
    
    // preview in widget gallery
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), title: "Placeholder")
    }
    
    // widget gallery / selection preview
    func snapshot(for configuration: ConfigurationAppIntent, in context: Context) async -> SimpleEntry {
        return await getDataFromFlutter()
    }

    // actual widget on home screen
    func timeline(for configuration: ConfigurationAppIntent, in context: Context) async -> Timeline<SimpleEntry> {
        let entry = await getDataFromFlutter()
        // Refresh every 15 minutes
        let refreshDate = Calendar.current.date(byAdding: .minute, value: 15, to: Date())!
        return Timeline(entries: [entry], policy: .after(refreshDate))
    }
}

// This represents the data that is passed to the widget
struct SimpleEntry: TimelineEntry {
    let date: Date
    let title: String
}

// This represents the view that is displayed in the widget
struct MyHomeWidgetEntryView : View {
    var entry: Provider.Entry

    var body: some View {
        VStack(spacing: 8) {
            Text("Counter Value")
                .font(.headline)
                .foregroundColor(.primary)
            
            Text(entry.title)
                .font(.system(size: 36, weight: .bold))
                .foregroundColor(.blue)
            
            Text("Last Updated:")
                .font(.caption)
                .foregroundColor(.secondary)
            
            Text(entry.date, style: .time)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
    }
}

// The main widget configuration
struct MyHomeWidget: Widget {
    let kind: String = "MyHomeWidget"

    var body: some WidgetConfiguration {
        AppIntentConfiguration(kind: kind, intent: ConfigurationAppIntent.self, provider: Provider()) { entry in
            MyHomeWidgetEntryView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .supportedFamilies([.systemSmall, .systemMedium])
        .configurationDisplayName("Flutter Counter")
        .description("Displays counter value from Flutter app")
    }
}

//extension ConfigurationAppIntent {
//    fileprivate static var smiley: ConfigurationAppIntent {
//        let intent = ConfigurationAppIntent()
//        intent.title = "0"
//        return intent
//    }
//    
//    fileprivate static var starEyes: ConfigurationAppIntent {
//        let intent = ConfigurationAppIntent()
//        intent.title = "0"
//        return intent
//    }
//}

#Preview(as: .systemSmall) {
    MyHomeWidget()
} timeline: {
    SimpleEntry(date: .now, title: "0")
    SimpleEntry(date: .now, title: "0")
}
