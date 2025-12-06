# Miilto — Community Ride-Sharing App

Miilto is a mobile ride-sharing application built with Flutter and Firebase. It connects drivers who are already heading somewhere with passengers traveling in the same direction, promoting community-based transportation where rides are shared out of convenience and social connection.

## Features

### For Drivers
- **Create Rides**: Publish intended routes with origin, destination, date/time, and available seats
- **Manage Requests**: View, accept, or reject passenger requests
- **Update Status**: Change ride status (open, ongoing, completed, cancelled)
- **Chat**: Communicate with passengers before and during the ride

### For Passengers
- **Search Rides**: Find available rides with filters for date and location
- **Request Seats**: Send requests to join rides
- **Track Requests**: View status of all ride requests (pending, accepted, rejected)
- **Chat**: Communicate with drivers

### Common Features
- **Authentication**: Email/password registration and login via Firebase Auth
- **Profile Management**: Edit name, phone, and role preferences
- **Real-time Updates**: Live updates for rides, requests, and messages
- **Push Notifications**: FCM integration for ride-related notifications

## Tech Stack

- **Frontend**: Flutter (Dart)
- **Backend**: Firebase
  - Firebase Authentication
  - Cloud Firestore
  - Firebase Cloud Messaging
- **Maps**: Google Maps SDK integration ready
- **State Management**: Built-in Flutter state management

## Project Structure

```
lib/
├── main.dart                 # App entry point
├── firebase_options.dart     # Firebase configuration
└── src/
    ├── models/
    │   ├── user_model.dart      # User data model
    │   ├── ride_model.dart      # Ride and LatLngPoint models
    │   ├── request_model.dart   # Ride request model
    │   └── message_model.dart   # Chat message model
    ├── screens/
    │   ├── login_screen.dart           # Login page
    │   ├── signup_screen.dart          # Registration page
    │   ├── home_screen.dart            # Main dashboard
    │   ├── profile_screen.dart         # User profile
    │   ├── create_ride_screen.dart     # Create new ride
    │   ├── search_rides_screen.dart    # Search available rides
    │   ├── ride_detail_screen.dart     # View ride details
    │   ├── my_rides_screen.dart        # Driver's rides list
    │   ├── my_requests_screen.dart     # Passenger's requests
    │   ├── manage_requests_screen.dart # Manage ride requests
    │   └── chat_screen.dart            # In-ride chat
    └── services/
        ├── auth_service.dart           # Authentication service
        ├── firestore_repo.dart         # Firestore operations
        └── notification_service.dart   # Push notifications
```

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

## Future Enhancements

- [ ] Google Maps place picker integration
- [ ] Directions API for route visualization
- [ ] Profile picture upload
- [ ] User ratings and reviews
- [ ] Payment integration for cost-sharing
- [ ] Advanced search with radius filter
- [ ] Recurring rides
- [ ] Cloud Functions for notifications

## License

This project is for educational purposes (ISI 2025 course).

## Author

Abdulkadir Gobena Denboba

