# E-Waste Facility Locator

A comprehensive Flutter application to help users find authorized e-waste recycling and collection centers using Google Maps and Firebase.

## Features
- **Interactive Map**: Visualize nearby facilities with markers.
- **GPS Integration**: Detects user location automatically.
- **Facility Details**: View address, contact, and accepted e-waste types.
- **Navigation**: One-tap "Get Directions" opening Google Maps.
- **Search**: Search by city or center name.
- **Admin Panel**: Add and manage e-waste centers.
- **Premium UI**: Modern Material 3 design with smooth animations.

## Setup Instructions

### 1. Google Maps API
- Go to [Google Cloud Console](https://console.cloud.google.com/).
- Create a project and enable **Maps SDK for Android** and **Maps SDK for iOS**.
- Create an API Key and restrict it if possible.
- **Android**: Add the key to `android/app/src/main/AndroidManifest.xml`:
  ```xml
  <meta-data android:name="com.google.android.geo.API_KEY" android:value="YOUR_API_KEY_HERE"/>
  ```
- **iOS**: Add the key to `ios/Runner/AppDelegate.swift`:
  ```swift
  GMSServices.provideAPIKey("YOUR_API_KEY_HERE")
  ```

### 2. Firebase Configuration
- Create a project on [Firebase Console](https://console.firebase.google.com/).
- Enable **Firestore Database**.
- Add Android/iOS apps:
  - **Android**: Download `google-services.json` and place it in `android/app/`.
  - **iOS**: Download `GoogleService-Info.plist` and place it in `ios/Runner/`.

### 3. Run the App
```bash
flutter pub get
flutter run
```

## Project Structure
- `lib/models`: Data structures.
- `lib/services`: Firestore and Location logic.
- `lib/screens`: All app pages (Splash, Home, Details, Admin).
- `lib/utils`: Themes and constants.
- `lib/widgets`: Reusable UI components.
