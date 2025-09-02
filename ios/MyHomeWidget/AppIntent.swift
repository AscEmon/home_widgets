//
//  AppIntent.swift
//  MyHomeWidget
//
//  Created by Sayed on 2/9/25.
//

import WidgetKit
import AppIntents

struct ConfigurationAppIntent: WidgetConfigurationIntent {
    static var title: LocalizedStringResource { "Counter Widget" }
    static var description: IntentDescription { "Widget that displays counter value from Flutter app" }
    
    // We don't need any parameters for this simple widget
    // but we keep the structure for future extensibility
}
