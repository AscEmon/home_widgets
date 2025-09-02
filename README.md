# Home Widgets App

A Flutter application showcasing home screen widget integration with a focus on displaying daily Hadith content.

## Features

### Hadith Module
- Browse Bukhari Hadith collection with pagination
- View detailed Hadith with narrator, text, and reference
- Daily Hadith display on dashboard
- Home screen widget showing daily Hadith
- Widget tap to open app and view full Hadith details

## Technical Implementation

### Architecture
- BLoC pattern for state management
- Repository pattern for data access
- Clean separation of concerns with models, repositories, and UI layers

### Widget Integration
- iOS widget using SwiftUI
- Shared data between app and widget using app groups
- URL scheme for widget-to-app navigation

## Setup

1. Clone the repository
2. Run `flutter pub get` to install dependencies
3. Configure app group entitlements for iOS widget sharing
4. Run the app with `flutter run`

## Documentation

For detailed information about the Hadith Widget feature, see [README_HADITH_WIDGET.md](README_HADITH_WIDGET.md).

## Dependencies

- flutter_bloc: ^8.1.3
- flutter_screenutil: ^5.9.3
- dio: ^5.3.3
- shared_preferences: ^2.2.2
- home_widget: ^0.8.0
- equatable: ^2.0.5
