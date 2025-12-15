# Miilto — Community Ride-Sharing App

Miilto is a modern, production-ready mobile ride-sharing application built with Flutter and Firebase. It connects drivers who are already heading somewhere with passengers traveling in the same direction, promoting community-based transportation where rides are shared out of convenience and social connection.

## ✨ Features

### For Drivers
- **Create Rides**: Publish intended routes with interactive map-based location selection
- **Manage Requests**: View, accept, or reject passenger requests
- **Update Status**: Change ride status (open, ongoing, completed, cancelled)
- **Chat**: Communicate with passengers before and during the ride
- **Map Integration**: Visual route display with origin and destination markers

### For Passengers
- **Search Rides**: Find available rides with filters for date and location
- **Request Seats**: Send requests to join rides
- **Track Requests**: View status of all ride requests (pending, accepted, rejected)
- **Chat**: Communicate with drivers
- **Map View**: See ride routes on interactive maps

### Common Features
- **Modern UI/UX**: Clean, intuitive interface with Material Design 3
- **Authentication**: Email/password registration and login via Firebase Auth
- **Profile Management**: Edit name, phone, and role preferences (passenger/driver/both)
- **Real-time Updates**: Live updates for rides, requests, and messages
- **Push Notifications**: FCM integration for ride-related notifications
- **Google Maps Integration**: Interactive maps for location selection and route visualization
- **Role-Based Navigation**: Customized experience based on user role

## 🎨 UI/UX Highlights

- **Modern Theme**: Custom color palette with indigo and purple accents
- **Smooth Animations**: Polished transitions and interactions
- **Logo Integration**: Brand identity throughout the app
- **Responsive Design**: Works on various screen sizes
- **Accessible**: High contrast and clear typography
- **Production-Ready**: Error handling, loading states, and user feedback

## 🛠 Tech Stack

- **Frontend**: Flutter (Dart)
- **Backend**: Firebase
  - Firebase Authentication
  - Cloud Firestore
  - Firebase Cloud Messaging
- **Maps**: Google Maps SDK with custom markers and polylines
- **Geolocation**: Geolocator for current location
- **State Management**: Built-in Flutter state management

## 📁 Project Structure

```
lib/
├── main.dart                 # App entry point
├── firebase_options.dart     # Firebase configuration
└── src/
    ├── config/
    │   └── app_theme.dart        # Modern theme configuration
    ├── models/
    │   ├── user_model.dart       # User data model
    │   ├── ride_model.dart       # Ride and LatLngPoint models
    │   ├── request_model.dart    # Ride request model
    │   └── message_model.dart    # Chat message model
    ├── screens/
    │   ├── login_screen.dart            # Login page with logo
    │   ├── signup_screen.dart           # Registration page
    │   ├── home_screen.dart             # Main dashboard with quick actions
    │   ├── profile_screen.dart          # User profile management
    │   ├── create_ride_screen.dart      # Create ride with map picker
    │   ├── search_rides_screen.dart     # Search and browse rides
    │   ├── ride_detail_screen.dart      # Ride details with map
    │   ├── my_rides_screen.dart         # Driver's rides list
    │   ├── my_requests_screen.dart      # Passenger's requests
    │   ├── manage_requests_screen.dart  # Manage ride requests
    │   └── chat_screen.dart             # In-ride chat
    ├── widgets/
    │   ├── location_picker_widget.dart  # Interactive map location picker
    │   └── ride_map_widget.dart         # Ride route visualization
    ├── services/
    │   ├── auth_service.dart            # Authentication service
    │   ├── firestore_repo.dart          # Firestore operations
    │   └── notification_service.dart    # Push notifications
    └── utils/
        └── logger.dart                  # Logging utility
```

## 🗺 Google Maps Integration

The app includes comprehensive Google Maps integration:

- **Location Picker**: Interactive map for selecting ride origin and destination with user-friendly place names
- **Current Location**: Automatic detection with permission handling
- **Route Visualization**: Actual road routing using Google Directions API (with fallback to straight lines)
- **Custom Markers**: Green for origin, red for destination
- **Polylines**: Route paths showing actual roads for car travel
- **Safe Area Support**: All screens properly handle device notches and safe areas

### Google Maps API Key Setup

The app uses environment variables to manage Google Maps API keys securely:

#### Quick Setup

1. **Get API keys** from [Google Cloud Console](https://console.cloud.google.com)
   - Enable: Maps SDK for Android, Maps SDK for iOS, Maps JavaScript API, Directions API

2. **Configure environment variables**:
   ```bash
   cp .env.example .env
   ```
   Edit `.env` and add your API keys.

3. **For Web**: Create `web/google_maps_config.js` from the example file:
   ```bash
   cp web/google_maps_config.js.example web/google_maps_config.js
   ```

4. **Platform-specific**:
   - Android: Update API key in `android/app/src/main/AndroidManifest.xml`
   - iOS: Update API key in `ios/Runner/AppDelegate.swift`

**Graceful Degradation**: 
- Without web API key: Maps won't load on web (mobile unaffected)
- Without Directions API key: Routes display as dotted lines instead of following roads
- Without mobile keys: Maps won't load on Android/iOS (web unaffected)

For detailed setup instructions, see:
- [API Keys Setup Guide](docs/API_KEYS_SETUP.md) - Environment variables and configuration
- [Google Maps Setup Guide](docs/GOOGLE_MAPS_SETUP.md) - Platform-specific details

## Data Model

### Users Collection (`users/{uid}`)
```json
{
  "uid": "string",
  "name": "string",
  "email": "string",
  "phone": "string?",
  "photoUrl": "string?",
  "role": "passenger|driver|both"
}
```

### Rides Collection (`rides/{rideId}`)
```json
{
  "driverId": "string",
  "driverName": "string?",
  "origin": { "lat": "number", "lng": "number", "address": "string?" },
  "destination": { "lat": "number", "lng": "number", "address": "string?" },
  "dateTime": "timestamp",
  "seatsTotal": "number",
  "seatsAvailable": "number",
  "status": "open|ongoing|completed|cancelled",
  "notes": "string?"
}
```

### Requests Subcollection (`rides/{rideId}/requests/{requestId}`)
```json
{
  "rideId": "string",
  "passengerId": "string",
  "passengerName": "string?",
  "status": "pending|accepted|rejected|cancelled",
  "seatsRequested": "number",
  "createdAt": "timestamp"
}
```

### Messages Subcollection (`rides/{rideId}/messages/{msgId}`)
```json
{
  "senderId": "string",
  "senderName": "string?",
  "text": "string",
  "createdAt": "timestamp"
}
```

## Getting Started

### Prerequisites
- Flutter SDK (stable channel)
- Android Studio / VS Code with Flutter plugins
- Firebase project set up

### Setup

1. **Clone the repository**
   ```bash
   git clone https://github.com/denboba/miiltoo.git
   cd miiltoo
   ```

2. **Configure Firebase**
   - Create a Firebase project at [Firebase Console](https://console.firebase.google.com)
   - Enable Email/Password authentication
   - Create a Firestore database
   - Run FlutterFire CLI to configure:
     ```bash
     dart pub global activate flutterfire_cli
     flutterfire configure
     ```
   - Or manually add config files:
     - Android: `android/app/google-services.json`
     - iOS: `ios/Runner/GoogleService-Info.plist`

3. **Deploy Firestore Rules**
   ```bash
   firebase deploy --only firestore:rules
   ```
   See `firebase_rules/firestore.rules` for security rules.

4. **Install dependencies**
   ```bash
   flutter pub get
   ```

5. **Run the app**
   ```bash
   flutter run
   ```

## Testing

Run unit tests:
```bash
flutter test
```

## Firestore Security Rules

The app includes security rules that:
- Allow authenticated users to read all rides
- Only allow drivers to modify their own rides
- Only allow passengers to create/cancel their own requests
- Allow drivers to accept/reject requests on their rides
- Enable per-ride chat with proper authorization

## Recent Improvements

- ✅ **Safe Area Support**: All screens now properly handle device notches and safe areas for iOS/Android
- ✅ **Modern UI/UX**: Enhanced card designs with better shadows, borders, and visual hierarchy
- ✅ **Route Visualization**: Integrated Google Directions API for actual road routing (with graceful fallback)
- ✅ **User-Friendly Locations**: Display place names instead of raw coordinates
- ✅ **Improved MyRequests**: Better error handling, modern design, and enhanced user feedback
- ✅ **Enhanced Typography**: Better font sizes, weights, and color usage throughout the app

## Future Enhancements

- [ ] Reverse geocoding for automatic address resolution
- [ ] Google Maps place search/autocomplete integration
- [ ] Profile picture upload
- [ ] User ratings and reviews
- [ ] Payment integration for cost-sharing
- [ ] Advanced search with radius filter
- [ ] Recurring rides
- [ ] Cloud Functions for automated notifications

## License

This project is for educational purposes (ISI 2025 course).

## Author

Abdulkadir Gobena Denboba

