# Google Maps Setup Guide

This guide will help you configure Google Maps API for the Miilto ride-sharing app.

## Prerequisites

- A Google Cloud Platform account
- The project should be set up with billing enabled

## Step 1: Create a Google Cloud Project

1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Create a new project or select an existing one
3. Note your project ID

## Step 2: Enable Required APIs

Enable the following APIs in your Google Cloud project:

1. **Maps SDK for Android** (Required)
   - Navigate to APIs & Services → Library
   - Search for "Maps SDK for Android"
   - Click Enable

2. **Maps SDK for iOS** (Required)
   - Search for "Maps SDK for iOS"
   - Click Enable

3. **Directions API** (Required for road-based routing)
   - Search for "Directions API"
   - Click Enable
   - This enables the app to show actual road routes instead of straight lines

4. **Geocoding API** (Optional, for address search)
   - Search for "Geocoding API"
   - Click Enable

5. **Places API** (Optional, for place autocomplete)
   - Search for "Places API"
   - Click Enable

## Step 3: Create API Keys

### For Android

1. Go to APIs & Services → Credentials
2. Click "Create Credentials" → "API Key"
3. Restrict the key:
   - Application restrictions: Android apps
   - Add your package name: `com.example.miiltoo`
   - Add your SHA-1 certificate fingerprint
4. API restrictions: Select "Maps SDK for Android" and "Directions API"
5. Copy the API key

### For iOS

1. Create another API key (or use the same one)
2. Restrict the key:
   - Application restrictions: iOS apps
   - Add your bundle identifier
3. API restrictions: Select "Maps SDK for iOS" and "Directions API"
4. Copy the API key

## Step 4: Configure the App

> **New**: This app now uses environment variables for secure API key management. See [API_KEYS_SETUP.md](./API_KEYS_SETUP.md) for the recommended approach.

### Quick Setup (Using Environment Variables - Recommended)

1. **Create environment file**:
   ```bash
   cp .env.example .env
   ```

2. **Add your API keys** to `.env`:
   ```
   GOOGLE_MAPS_WEB_API_KEY=your_web_api_key
   GOOGLE_DIRECTIONS_API_KEY=your_directions_api_key
   GOOGLE_MAPS_ANDROID_API_KEY=your_android_api_key
   GOOGLE_MAPS_IOS_API_KEY=your_ios_api_key
   ```

3. **Configure platform-specific files** (see below)

### Android Configuration

1. Open `android/app/src/main/AndroidManifest.xml`
2. Replace `YOUR_GOOGLE_MAPS_API_KEY` with your Android API key:

```xml
<meta-data
    android:name="com.google.android.geo.API_KEY"
    android:value="YOUR_ACTUAL_API_KEY_HERE"/>
```

### iOS Configuration

1. Open `ios/Runner/AppDelegate.swift`
2. Uncomment the GoogleMaps import:

```swift
import GoogleMaps
```

3. Uncomment and update the API key line in the `application` method:

```swift
GMSServices.provideAPIKey("YOUR_IOS_API_KEY_HERE")
```

### Web Configuration

1. **Option 1 (Recommended)**: Create `web/google_maps_config.js`:
   ```bash
   cp web/google_maps_config.js.example web/google_maps_config.js
   ```
   
   Edit the file and add your web API key:
   ```javascript
   var GOOGLE_MAPS_CONFIG = {
     apiKey: 'your_web_api_key_here'
   };
   ```

2. **Option 2**: Edit `web/index.html` directly and replace `YOUR_WEB_API_KEY` (not recommended for version control)

### Directions API Configuration (For Road-Based Routing)

The app now automatically reads the Directions API key from the `.env` file using the `GOOGLE_DIRECTIONS_API_KEY` variable. No code changes needed!

**How it works**:
- The app loads `.env` on startup via `flutter_dotenv`
- `ride_map_widget.dart` reads `GOOGLE_DIRECTIONS_API_KEY` from environment
- If the key is missing, the app gracefully falls back to showing dotted straight lines

**Without Directions API**: If no API key is configured, the app will display a dotted straight line between origin and destination instead of actual road routes.

## Understanding Common Errors (Now Fixed)

### "Failed to load route from Directions API: Exception: Google Maps API key not configured"

**What it means**: The Directions API key was hardcoded as empty string in the code.

**How it's fixed**: The app now reads the key from `.env` file using `flutter_dotenv`. When you add `GOOGLE_DIRECTIONS_API_KEY` to your `.env` file, this error will be resolved.

### "InvalidKeyMapError" (Web)

**What it means**: The web app tried to load Google Maps JavaScript API with an invalid or placeholder key (`YOUR_API_KEY`).

**How it's fixed**: The `web/index.html` now includes logic to:
1. Check for a valid API key from config file
2. Only load Maps API if a valid key exists
3. Show a clear warning in console if key is missing
4. Prevent the "InvalidKeyMapError" by not loading the API with invalid key

### "google.maps.Marker is deprecated" Warning

**What it means**: Google is deprecating the old `Marker` API in favor of `AdvancedMarkerElement`.

**Current status**: This is just a deprecation warning, not an error. The old API still works and will continue to work for at least 12 months after discontinuation is announced. The Flutter `google_maps_flutter` package will need to be updated to support the new API - this is handled by the package maintainers, not in application code.

**Action needed**: Monitor the `google_maps_flutter` package for updates that support `AdvancedMarkerElement`.

## Step 5: Get SHA-1 Fingerprint (Android)

### For Debug Build

Run this command in your project directory:

```bash
keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android
```

### For Release Build

```bash
keytool -list -v -keystore /path/to/your/keystore.jks -alias your-alias-name
```

Copy the SHA-1 fingerprint and add it to your API key restrictions.

## Step 6: Test the Integration

1. Run the app on a physical device or emulator
2. Navigate to "Create Ride" screen
3. Tap the map icon next to Origin or Destination fields
4. Verify that the map loads correctly

## Troubleshooting

### Map shows blank or grey tiles

- Check that your API key is correctly configured
- Verify that billing is enabled on your Google Cloud project
- Ensure the Maps SDK for Android/iOS is enabled
- Check that SHA-1 fingerprint is added to API key restrictions

### "Authorization failure" error

- Double-check your API key in AndroidManifest.xml or AppDelegate.swift
- Verify that the package name/bundle ID matches
- Ensure API restrictions allow Maps SDK

### Location permission denied

- The app will request location permissions at runtime
- Grant location permissions when prompted
- If denied, you can still manually select locations on the map

## Production Checklist

- [ ] Create separate API keys for debug and release builds
- [ ] Enable API restrictions for security
- [ ] Set up API usage quotas and alerts
- [ ] Monitor API usage in Google Cloud Console
- [ ] Consider implementing Places API for better address search
- [ ] Add Directions API for route optimization

## Additional Features

### Places Autocomplete

To enable place search autocomplete:

1. Enable Places API in Google Cloud Console
2. Uncomment the place search code in `LocationPickerWidget`
3. Implement place search using `google_places_flutter` package

### Directions API

To show actual road routes (already implemented):

1. Enable Directions API in Google Cloud Console (see Step 2)
2. Configure API key in `lib/src/widgets/ride_map_widget.dart` (see Step 4)
3. The app will automatically show car-based routes with solid polylines
4. Falls back to dotted straight lines if API key is not configured

## Cost Considerations

Google Maps Platform has a pay-as-you-go pricing model:

- First $200 of monthly usage is free
- Maps SDK: $7 per 1,000 map loads
- Directions API: $5 per 1,000 requests
- Geocoding API: $5 per 1,000 requests
- Places API: $17 per 1,000 requests

Set up billing alerts to monitor costs.

## Security Best Practices

1. **Never commit API keys to version control**
   - Use environment variables or build configs
   - Add API keys to `.gitignore`

2. **Use API restrictions**
   - Restrict by Android/iOS app
   - Add SHA-1/bundle ID restrictions
   - Limit to specific APIs only

3. **Monitor usage**
   - Set up usage quotas
   - Enable billing alerts
   - Review API usage regularly

## Support

For more information, visit:
- [Google Maps Platform Documentation](https://developers.google.com/maps/documentation)
- [Flutter Google Maps Plugin](https://pub.dev/packages/google_maps_flutter)
- [Google Cloud Console](https://console.cloud.google.com/)
