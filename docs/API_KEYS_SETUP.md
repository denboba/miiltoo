# API Keys Setup Guide

This guide explains how to configure Google Maps API keys for the Miilto application across all platforms (Android, iOS, and Web).

## Overview

The application uses environment variables to manage API keys securely. This approach:
- Keeps sensitive API keys out of version control
- Allows different keys for development and production
- Makes it easy to rotate keys without code changes

## Quick Start

### 1. Get Google Maps API Keys

Visit [Google Cloud Console](https://console.cloud.google.com/) and:

1. Create or select a project
2. Enable the following APIs:
   - **Maps SDK for Android** (for Android app)
   - **Maps SDK for iOS** (for iOS app)
   - **Maps JavaScript API** (for web app)
   - **Directions API** (for route visualization on all platforms)

3. Create API keys (one for each platform or one universal key):
   - Go to APIs & Services → Credentials
   - Click "Create Credentials" → "API Key"
   - Restrict each key appropriately (see Security section below)

### 2. Configure Environment Variables

#### For Mobile (Android/iOS)

1. Copy the example environment file:
   ```bash
   cp .env.example .env
   ```

2. Edit `.env` and add your API keys:
   ```
   GOOGLE_MAPS_WEB_API_KEY=your_web_api_key_here
   GOOGLE_DIRECTIONS_API_KEY=your_directions_api_key_here
   GOOGLE_MAPS_ANDROID_API_KEY=your_android_api_key_here
   GOOGLE_MAPS_IOS_API_KEY=your_ios_api_key_here
   ```

3. The `.env` file is already in `.gitignore` and won't be committed

#### For Web

**Option 1: Using config file (recommended for development)**

1. Copy the example config file:
   ```bash
   cp web/google_maps_config.js.example web/google_maps_config.js
   ```

2. Edit `web/google_maps_config.js` and add your API key:
   ```javascript
   var GOOGLE_MAPS_CONFIG = {
     apiKey: 'your_web_api_key_here'
   };
   ```

3. Load this file in `web/index.html` before the main script (already configured)

**Option 2: Direct edit (quick testing only)**

Edit `web/index.html` and replace `YOUR_WEB_API_KEY` with your actual key:
```javascript
var googleMapsApiKey = 'your_actual_api_key';
```

⚠️ **Warning**: Don't commit this change to version control!

### 3. Configure Platform-Specific Files

#### Android

Edit `android/app/src/main/AndroidManifest.xml`:

```xml
<meta-data
    android:name="com.google.android.geo.API_KEY"
    android:value="YOUR_ANDROID_API_KEY_HERE"/>
```

Replace `YOUR_ANDROID_API_KEY_HERE` with your Android API key or use `${GOOGLE_MAPS_ANDROID_API_KEY}` if you set it up with Gradle.

#### iOS

Edit `ios/Runner/AppDelegate.swift`:

```swift
import GoogleMaps

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GMSServices.provideAPIKey("YOUR_IOS_API_KEY_HERE")
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
```

Replace `YOUR_IOS_API_KEY_HERE` with your iOS API key.

### 4. Install Dependencies

```bash
flutter pub get
```

### 5. Run the App

```bash
# For mobile
flutter run

# For web
flutter run -d chrome
```

## What Each API Key Does

| Key | Purpose | Used For |
|-----|---------|----------|
| `GOOGLE_MAPS_WEB_API_KEY` | Maps JavaScript API | Displaying maps on web platform |
| `GOOGLE_DIRECTIONS_API_KEY` | Directions API | Drawing actual routes between locations (all platforms) |
| `GOOGLE_MAPS_ANDROID_API_KEY` | Maps SDK for Android | Displaying maps on Android |
| `GOOGLE_MAPS_IOS_API_KEY` | Maps SDK for iOS | Displaying maps on iOS |

## Behavior Without API Keys

The app is designed to handle missing API keys gracefully:

### Without Web API Key
- Web app will show a console warning
- Maps will not load on web platform
- Mobile platforms are unaffected

### Without Directions API Key
- Maps will still display
- Route will show as a **dotted straight line** instead of following roads
- Origin and destination markers will still appear

### Without Mobile API Keys
- Android/iOS maps won't load
- Web platform is unaffected

## Validate Your Setup

We provide a handy validation script to check your API key configuration:

```bash
./scripts/validate_api_keys.sh
```

This script will:
- Check if `.env` file exists
- Verify all required API keys are present
- Detect placeholder values that need to be replaced
- Check platform-specific configuration files
- Provide a summary and next steps

**Example output:**
```
✓ .env file found
✓ GOOGLE_MAPS_WEB_API_KEY is configured
✓ GOOGLE_DIRECTIONS_API_KEY is configured
⚠ GOOGLE_MAPS_ANDROID_API_KEY is set but uses placeholder value
```

## Security Best Practices

### 1. API Key Restrictions

For each API key, set up restrictions in Google Cloud Console:

**Android Key:**
- Application restrictions: Android apps
- Add package name: `com.example.miiltoo` (or your actual package name)
- Add SHA-1 certificate fingerprint(s)
- API restrictions: Maps SDK for Android, Directions API

**iOS Key:**
- Application restrictions: iOS apps  
- Add bundle identifier: Your iOS bundle ID
- API restrictions: Maps SDK for iOS, Directions API

**Web Key:**
- Application restrictions: HTTP referrers
- Add referrers: `your-domain.com/*`, `localhost/*`
- API restrictions: Maps JavaScript API, Directions API

### 2. Get SHA-1 Fingerprint (Android)

**Debug certificate:**
```bash
keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android
```

**Release certificate:**
```bash
keytool -list -v -keystore /path/to/your-release-key.jks -alias your-key-alias
```

### 3. Never Commit API Keys

The following files are in `.gitignore`:
- `.env` - Contains all API keys
- `web/google_maps_config.js` - Contains web API key

Always use `.example` files as templates.

### 4. Rotate Keys Regularly

- Change API keys periodically
- Immediately rotate if a key is exposed
- Update restrictions when app is published

## Troubleshooting

### "InvalidKeyMapError" on Web

**Problem:** Map shows blank with console error about invalid key

**Solutions:**
1. Check that `web/google_maps_config.js` exists with valid key
2. Verify the key in Google Cloud Console
3. Ensure Maps JavaScript API is enabled
4. Check HTTP referrer restrictions allow your domain

### "Authorization failure" on Android

**Problem:** Map shows "Authorization failure" message

**Solutions:**
1. Verify API key in `AndroidManifest.xml`
2. Check package name matches Google Cloud Console
3. Add SHA-1 fingerprint to API key restrictions
4. Ensure Maps SDK for Android is enabled

### "Failed to load route from Directions API"

**Problem:** Route shows as dotted line with console error

**Solutions:**
1. Check `GOOGLE_DIRECTIONS_API_KEY` in `.env` file
2. Verify Directions API is enabled in Google Cloud Console
3. Check API key restrictions allow Directions API
4. Verify billing is enabled (Directions API requires billing)

### Maps work but routes are dotted lines

**Problem:** Maps display correctly but routes don't follow roads

**Cause:** Directions API key is not configured or invalid

**Solution:** Add valid `GOOGLE_DIRECTIONS_API_KEY` to `.env` file

## Cost Considerations

Google Maps Platform uses pay-as-you-go pricing:

- **Free tier:** $200 credit per month
- **Maps SDK:** $7 per 1,000 map loads
- **Directions API:** $5 per 1,000 requests
- **Maps JavaScript API:** $7 per 1,000 map loads

### Cost Optimization Tips

1. Enable API key restrictions to prevent unauthorized use
2. Set up budget alerts in Google Cloud Console
3. Use caching where possible
4. Consider the dotted-line fallback for non-critical routes

## Testing Your Setup

### Quick Test Checklist

- [ ] Create `.env` file with API keys
- [ ] Run `flutter pub get`
- [ ] Launch app on your target platform
- [ ] Navigate to "Create Ride" screen
- [ ] Tap location picker - map should load
- [ ] View a ride detail - route should show (solid line if Directions API is configured)
- [ ] Check console for no API-related errors

### Verify Each Platform

**Android:**
```bash
flutter run -d <android-device>
```

**iOS:**
```bash
flutter run -d <ios-device>
```

**Web:**
```bash
flutter run -d chrome
```

## Production Deployment

Before deploying to production:

1. [ ] Create separate production API keys
2. [ ] Set up strict API restrictions
3. [ ] Enable billing alerts
4. [ ] Add production domains/apps to restrictions
5. [ ] Test with production keys
6. [ ] Document key rotation process
7. [ ] Set up monitoring for API usage

## Additional Resources

- [Google Maps Platform Documentation](https://developers.google.com/maps/documentation)
- [Flutter Google Maps Plugin](https://pub.dev/packages/google_maps_flutter)
- [Google Cloud Console](https://console.cloud.google.com/)
- [API Key Best Practices](https://developers.google.com/maps/api-security-best-practices)

## Support

If you encounter issues:

1. Check the troubleshooting section above
2. Verify all APIs are enabled in Google Cloud Console
3. Review the main [GOOGLE_MAPS_SETUP.md](./GOOGLE_MAPS_SETUP.md) guide
4. Check Google Maps Platform [error messages](https://developers.google.com/maps/documentation/javascript/error-messages)

---

**Last Updated:** December 2024  
**Version:** 1.0.0
