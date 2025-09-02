//
//  MyHomeWidget.swift
//  MyHomeWidget
//
//  Created by Sayed on 2/9/25.
//

import WidgetKit
import SwiftUI

struct Provider: TimelineProvider {
    typealias Entry = SimpleEntry
    
    // Method to retrieve the data from flutter
    private func getDataFromFlutter() -> SimpleEntry {
        let userDefault = UserDefaults(suiteName: "group.com.example.homeWidgets")
        
        // Print all keys in UserDefaults for debugging
        if let userDefault = userDefault, let keys = userDefault.dictionaryRepresentation().keys as? [String] {
            print("Available keys in UserDefaults: \(keys)")
        }
        
        // Match the exact keys used in Flutter's HadithWidgetProvider
        let narrator = userDefault?.string(forKey: "narrator") ?? "Unknown"
        let text = userDefault?.string(forKey: "text") ?? "No hadith available"
        let reference = userDefault?.string(forKey: "reference") ?? ""
        let lastUpdated = userDefault?.string(forKey: "last_updated")
        
        var date = Date()
        if let lastUpdatedString = lastUpdated {
            let formatter = ISO8601DateFormatter()
            if let parsedDate = formatter.date(from: lastUpdatedString) {
                date = parsedDate
            }
        }
        
        return SimpleEntry(date: date, narrator: narrator, text: text, reference: reference)
    }        
    
    // Required: preview placeholder
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), narrator: "Abu Hurairah", text: "The best of you are those who are best to their families.", reference: "Bukhari: 123")
    }
    
    // Required: widget gallery preview
    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> Void) {
        let entry = getDataFromFlutter()
        completion(entry)
    }

    // Required: timeline for widget updates
    func getTimeline(in context: Context, completion: @escaping (Timeline<SimpleEntry>) -> Void) {
        let entry = getDataFromFlutter()
        // Refresh every 15 minutes
        let refreshDate = Calendar.current.date(byAdding: .minute, value: 15, to: Date())!
        let timeline = Timeline(entries: [entry], policy: .after(refreshDate))
        completion(timeline)
    }
}

// This represents the data that is passed to the widget
struct SimpleEntry: TimelineEntry {
    let date: Date
    let narrator: String
    let text: String
    let reference: String
}

// This represents the view that is displayed in the widget
struct MyHomeWidgetEntryView : View {
    var entry: Provider.Entry
    @Environment(\.widgetFamily) var family

    var body: some View {
        // Use widgetURL instead of Button with intent for iOS 16 compatibility
        ZStack {
                Color(red: 0.95, green: 0.95, blue: 1.0)
                    .cornerRadius(16)
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Daily Hadith")
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Text(entry.narrator)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.blue)
                        .lineLimit(1)
                    
                    Text(entry.text)
                        .font(family == .systemSmall ? .caption : .body)
                        .foregroundColor(.primary)
                        .lineLimit(family == .systemSmall ? 3 : 6)
                        .multilineTextAlignment(.leading)
                    
                    Spacer(minLength: 2)
                    
                    HStack {
                        Text(entry.reference)
                            .font(.caption2)
                            .foregroundColor(.secondary)
                        
                        Spacer()
                        
                        Text("Updated: ")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                        
                        Text(entry.date, style: .time)
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
                .padding(12)
            }
            .widgetURL(URL(string: "hadithwidget://hadith_widget_clicked"))
    }
}

// The main widget configuration
struct MyHomeWidget: Widget {
    let kind: String = "hadith_widget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            MyHomeWidgetEntryView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .supportedFamilies([.systemSmall, .systemMedium])
        .configurationDisplayName("Daily Hadith")
        .description("Displays a daily Hadith from Bukhari collection")
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
    SimpleEntry(date: .now, narrator: "Abu Hurairah", text: "The best of you are those who are best to their families.", reference: "Bukhari: 123")
    SimpleEntry(date: .now, narrator: "Aisha", text: "The most beloved of deeds to Allah is that which is done regularly, even if it is small.", reference: "Bukhari: 456")
}
