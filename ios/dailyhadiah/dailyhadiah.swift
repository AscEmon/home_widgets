//
//  dailyhadiah.swift
//  dailyhadiah
//
//  Created by Sayed on 2/9/25.
//

import WidgetKit
import SwiftUI
import Intents

// Helper function to format date in a way compatible with older iOS versions
func formatDate(_ date: Date) -> String {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    formatter.timeStyle = .short
    return formatter.string(from: date)
}

struct Provider: TimelineProvider {
    typealias Entry = SimpleEntry
    
    // Method to retrieve the data from flutter
    private func getDataFromFlutter() -> SimpleEntry {
        // Try to get data from both app group and standard UserDefaults
        let appGroupDefaults = UserDefaults(suiteName: "group.com.sslwireless.homewidget")
        let standardDefaults = UserDefaults.standard
        
        // Print all keys in UserDefaults for debugging
        if let appGroupDefaults = appGroupDefaults {
            let keys = appGroupDefaults.dictionaryRepresentation().keys
            print("Available keys in App Group UserDefaults: \(keys)")
            
            // Check for the refresh timestamp (used to force widget updates)
            if let timestamp = appGroupDefaults.string(forKey: "widget_refresh_timestamp") {
                print("Found widget refresh timestamp: \(timestamp)")
            }
        }
        
        // First try to get the complete JSON data
        if let jsonString = appGroupDefaults?.string(forKey: "daily_hadith") ?? standardDefaults.string(forKey: "daily_hadith") {
            print("Found complete JSON data, length: \(jsonString.count) characters")
            
            // Try to parse the JSON
            do {
                if let jsonData = jsonString.data(using: .utf8),
                   let jsonDict = try JSONSerialization.jsonObject(with: jsonData) as? [String: Any] {
                    
                    let narrator = jsonDict["narrator"] as? String ?? "Unknown"
                    let text = jsonDict["text"] as? String ?? "No hadith available"
                    let reference = jsonDict["reference"] as? String ?? ""
                    
                    print("Successfully parsed JSON data - Narrator: \(narrator), Text: \(String(describing: text.prefix(20)))...")
                    
                    return SimpleEntry(
                        date: Date(),
                        narrator: narrator,
                        text: text,
                        reference: reference
                    )
                }
            } catch {
                print("Error parsing JSON: \(error.localizedDescription)")
            }
        }
        
        // Fallback to individual fields if JSON parsing fails
        print("Falling back to individual fields")
        
        // Try multiple key variations - Flutter might be saving with different key formats
        let possibleNarratorKeys = ["narrator", "hadith_narrator", "daily_hadith_narrator"]
        let possibleTextKeys = ["text", "hadith_text", "daily_hadith_text"]
        let possibleReferenceKeys = ["reference", "hadith_reference", "daily_hadith_reference"]
        let possibleDateKeys = ["last_updated", "date", "updated_at", "timestamp"]
        
        // Function to try multiple keys in both UserDefaults
        func getStringFromKeys(_ keys: [String]) -> String? {
            for key in keys {
                if let value = appGroupDefaults?.string(forKey: key) {
                    print("Found value for key '\(key)' in app group defaults")
                    return value
                }
                if let value = standardDefaults.string(forKey: key) {
                    print("Found value for key '\(key)' in standard defaults")
                    return value
                }
            }
            return nil
        }
        
        let narrator = getStringFromKeys(possibleNarratorKeys)
        let text = getStringFromKeys(possibleTextKeys)
        let reference = getStringFromKeys(possibleReferenceKeys)
        let lastUpdated = getStringFromKeys(possibleDateKeys)
        
        print("Debug - Raw values from UserDefaults:")
        print("narrator: \(narrator ?? "nil")")
        print("text: \(text ?? "nil")")
        print("reference: \(reference ?? "nil")")
        print("last_updated: \(lastUpdated ?? "nil")")
        
        // Use fallback values if nothing found
        let finalNarrator = narrator ?? "Unknown"
        let finalText = text ?? "No hadith available..."
        let finalReference = reference ?? ""
        
        var date = Date()
        if let lastUpdatedString = lastUpdated {
            // Try multiple date formats
            let iso8601Formatter = ISO8601DateFormatter()
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
            
            // Try ISO8601 format first
            if let parsedDate = iso8601Formatter.date(from: lastUpdatedString) {
                date = parsedDate
            } 
            // Then try custom format
            else if let parsedDate = dateFormatter.date(from: lastUpdatedString) {
                date = parsedDate
            }
        }
        
        print("Widget data loaded - Narrator: \(finalNarrator), Text: \(finalText)")
        return SimpleEntry(date: date, narrator: finalNarrator, text: finalText, reference: finalReference)
    }
    
    // Required: preview placeholder
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), narrator: "Loading...", text: "Loading daily hadith...", reference: "")
    }

    // Required: widget gallery preview
    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = getDataFromFlutter()
        print("Widget snapshot requested - providing data")
        completion(entry)
    }

    // Required: timeline for widget updates
    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        let entry = getDataFromFlutter()
        
        // Determine refresh interval based on context
        var refreshInterval: TimeInterval
        
        switch context.family {
        case .systemSmall, .systemMedium, .systemLarge:
            // More frequent updates for visible widgets
            refreshInterval = 15 * 60 // 15 minutes
        default:
            // Less frequent updates for other contexts
            refreshInterval = 60 * 60 // 1 hour
        }
        
        // If we have no data, try to refresh more frequently
        if entry.text == "No hadith available" {
            refreshInterval = 5 * 60 // 5 minutes
            print("No hadith data available, setting shorter refresh interval: \(refreshInterval) seconds")
        } else {
            print("Hadith data available, setting normal refresh interval: \(refreshInterval) seconds")
        }
        
        // Create a timeline with one entry that refreshes according to our policy
        let timeline = Timeline(entries: [entry], policy: .after(Date().addingTimeInterval(refreshInterval)))
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
struct dailyhadiahEntryView : View {
    var entry: Provider.Entry
    @Environment(\.colorScheme) var colorScheme
    
    var accentColor: Color {
        colorScheme == .dark ? Color(red: 0.4, green: 0.6, blue: 1.0) : Color(red: 0.0, green: 0.4, blue: 0.9)
    }
    
    var backgroundColor: Color {
        colorScheme == .dark ? Color(white: 0.15) : Color(white: 0.97)
    }
    
    var body: some View {
        ZStack {
            // Background with subtle gradient
            LinearGradient(
                gradient: Gradient(colors: [
                    backgroundColor,
                    backgroundColor.opacity(0.8)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            
            VStack(alignment: .leading, spacing: 10) {
                // Header with icon
                HStack(spacing: 6) {
                    Image(systemName: "quote.bubble")
                        .foregroundColor(accentColor)
                        .font(.system(size: 14))
                    
                    Text(entry.narrator)
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(accentColor)
                        .lineLimit(1)
                    
                    Spacer()
                }
                
                // Main hadith text
                Text(entry.text)
                    .font(.system(size: 13))
                    .foregroundColor(colorScheme == .dark ? .white : .black)
                    .lineLimit(6)
                    .multilineTextAlignment(.leading)
                    .fixedSize(horizontal: false, vertical: true)
                
                Spacer(minLength: 4)
                
                // Reference and last updated
                VStack(alignment: .leading, spacing: 4) {
                    if !entry.reference.isEmpty {
                        Text(entry.reference)
                            .font(.system(size: 11, weight: .medium))
                            .foregroundColor(.gray)
                            .italic()
                            .lineLimit(1)
                    }
                    
                    HStack {
                        Spacer()
                        Text("Updated: \(formatDate(entry.date))")
                            .font(.system(size: 9))
                            .foregroundColor(.gray)
                    }
                }
                .padding(12)
            }
            .widgetURL(URL(string: "hadithwidget://hadith_widget_clicked"))
        }
    }
}

// The main widget configuration
struct dailyhadiah: Widget {
    let kind: String = "dailyhadiah"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            if #available(iOS 17.0, *) {
                dailyhadiahEntryView(entry: entry)
                    .containerBackground(.fill.tertiary, for: .widget)
            } else {
                dailyhadiahEntryView(entry: entry)
                    .padding()
                    .background(Color(UIColor.systemBackground))
            }
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
    dailyhadiah()
} timeline: {
    SimpleEntry(date: .now, narrator: "Abu Hurairah", text: "The best of you are those who are best to their families.", reference: "Bukhari: 123")
    SimpleEntry(date: .now, narrator: "Aisha", text: "The most beloved of deeds to Allah is that which is done regularly, even if it is small.", reference: "Bukhari: 456")
}
