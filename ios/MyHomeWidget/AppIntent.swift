//
//  AppIntent.swift
//  MyHomeWidget
//
//  Created by Sayed on 2/9/25.
//

import WidgetKit
import AppIntents

struct ConfigurationAppIntent: WidgetConfigurationIntent {
    static var title: LocalizedStringResource { "Daily Hadith Widget" }
    static var description: IntentDescription { "Widget that displays daily Hadith from Bukhari collection" }
    
    // We don't need any parameters for this simple widget
    // but we keep the structure for future extensibility
}

struct OpenHadithIntent: AppIntent {
    static var title: LocalizedStringResource = "Open Hadith Detail"
    static var description = IntentDescription("Opens the Hadith detail screen in the app")
    
    @MainActor
    func perform() async throws -> some IntentResult {
        // This will trigger the URL scheme to open the app
        // The URL will be handled in the app to navigate to the Hadith detail
        return .result()
    }
}
