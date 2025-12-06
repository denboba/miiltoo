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

1. **Maps SDK for Android**
   - Navigate to APIs & Services → Library
   - Search for "Maps SDK for Android"
   - Click Enable

2. **Maps SDK for iOS**
   - Search for "Maps SDK for iOS"
   - Click Enable

3. **Geocoding API** (Optional, for address search)
   - Search for "Geocoding API"
   - Click Enable

4. **Places API** (Optional, for place autocomplete)
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
4. API restrictions: Select "Maps SDK for Android"
5. Copy the API key

### For iOS

1. Create another API key (or use the same one)
2. Restrict the key:
   - Application restrictions: iOS apps
   - Add your bundle identifier
3. API restrictions: Select "Maps SDK for iOS"
4. Copy the API key

## Step 4: Configure the App

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
2. Add the following import at the top:

```swift
import GoogleMaps
```

3. Add this line in the `application` method before `GeneratedPluginRegistrant.register`:

```swift
GMSServices.provideAPIKey("YOUR_IOS_API_KEY_HERE")
```

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

To show actual routes instead of straight lines:

1. Enable Directions API in Google Cloud Console
2. Update `RideMapWidget` to fetch route polylines
3. Use `flutter_polyline_points` package to decode routes

## Cost Considerations

Google Maps Platform has a pay-as-you-go pricing model:

- First $200 of monthly usage is free
- Maps SDK: $7 per 1,000 map loads
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
