# Testing Guide - Google Maps API Configuration

This guide provides comprehensive testing procedures to verify the Google Maps API configuration fixes.

## Overview

The changes fix three issues:
1. "Failed to load route from Directions API" error
2. "InvalidKeyMapError" on web
3. Documentation for deprecated Marker warning

## Prerequisites

Before testing, ensure you have:
- [ ] Flutter SDK installed and configured
- [ ] Google Cloud Console account
- [ ] API keys from Google Cloud Console
- [ ] Enabled required APIs (Maps SDK for Android/iOS, Maps JavaScript API, Directions API)

## Test Environment Setup

### 1. Create Environment File

```bash
cp .env.example .env
```

Edit `.env` and add test API keys:
```
GOOGLE_MAPS_WEB_API_KEY=your_test_web_key
GOOGLE_DIRECTIONS_API_KEY=your_test_directions_key
GOOGLE_MAPS_ANDROID_API_KEY=your_test_android_key
GOOGLE_MAPS_IOS_API_KEY=your_test_ios_key
```

### 2. Configure Web (Optional)

```bash
cp web/google_maps_config.js.example web/google_maps_config.js
```

Edit and add your web API key.

### 3. Update Platform Files

**Android**: Update `android/app/src/main/AndroidManifest.xml`:
```xml
<meta-data
    android:name="com.google.android.geo.API_KEY"
    android:value="your_android_api_key"/>
```

**iOS**: Update `ios/Runner/AppDelegate.swift`:
```swift
import GoogleMaps
// ...
GMSServices.provideAPIKey("your_ios_api_key")
```

### 4. Install Dependencies

```bash
flutter pub get
```

## Test Cases

### TC1: Validation Script

**Purpose**: Verify the validation script correctly checks configuration

**Steps**:
1. Run validation script:
   ```bash
   ./scripts/validate_api_keys.sh
   ```

**Expected Results**:
- ✅ Script runs without errors
- ✅ Reports .env file status
- ✅ Shows configured/missing/placeholder keys
- ✅ Checks platform-specific files
- ✅ Provides clear summary

**Pass Criteria**:
- All configured keys show green checkmarks
- Missing keys show red X
- Placeholder keys show yellow warnings
- Script exits with appropriate code

---

### TC2: Directions API with Valid Key

**Purpose**: Verify routes display correctly with Directions API

**Prerequisites**:
- Valid `GOOGLE_DIRECTIONS_API_KEY` in `.env`
- Directions API enabled in Google Cloud Console

**Steps**:
1. Run the app: `flutter run`
2. Log in to the app
3. Navigate to "Create Ride" or "Search Rides"
4. Select or view a ride with origin and destination
5. Observe the route on the map

**Expected Results**:
- ✅ Map loads correctly
- ✅ Origin marker (green) appears
- ✅ Destination marker (red) appears
- ✅ Route displays as **solid line** following roads
- ✅ No error in console about "API key not configured"

**Pass Criteria**:
- Route follows actual roads (not straight line)
- Solid line connects origin to destination
- No console errors about API key

---

### TC3: Directions API without Key (Graceful Degradation)

**Purpose**: Verify app handles missing Directions API key gracefully

**Prerequisites**:
- Remove or comment out `GOOGLE_DIRECTIONS_API_KEY` in `.env`
- OR set it to empty string

**Steps**:
1. Run the app: `flutter run`
2. Navigate to a ride detail screen
3. Observe the route on the map
4. Check console for messages

**Expected Results**:
- ✅ Map still loads
- ✅ Origin and destination markers appear
- ✅ Route displays as **dotted line** (straight)
- ✅ Console shows: "Failed to load route from Directions API: Exception: Google Maps API key not configured"
- ✅ App doesn't crash

**Pass Criteria**:
- App continues to function
- Route shown as dotted straight line
- User can still see origin/destination
- No app crash or freeze

---

### TC4: Web Platform with Valid Key

**Purpose**: Verify maps load correctly on web

**Prerequisites**:
- Valid web API key in `web/google_maps_config.js`
- OR valid key in `web/index.html`
- Maps JavaScript API enabled

**Steps**:
1. Run web app: `flutter run -d chrome`
2. Navigate to map features
3. Check browser console

**Expected Results**:
- ✅ Google Maps loads in browser
- ✅ No InvalidKeyMapError in console
- ✅ Maps are interactive
- ✅ Location picker works

**Pass Criteria**:
- Maps visible and functional
- No API key errors in console
- Can interact with map (zoom, pan)

---

### TC5: Web Platform without Key (Graceful Degradation)

**Purpose**: Verify web handles missing API key gracefully

**Prerequisites**:
- No `web/google_maps_config.js` file
- OR placeholder key in config

**Steps**:
1. Run web app: `flutter run -d chrome`
2. Navigate to map features
3. Check browser console

**Expected Results**:
- ✅ App loads without crashing
- ✅ Console shows warning: "Google Maps API key not configured..."
- ✅ No InvalidKeyMapError
- ✅ Rest of app functions normally

**Pass Criteria**:
- No error dialogs or crashes
- Clear warning message in console
- Non-map features work fine

---

### TC6: Android Platform

**Purpose**: Verify maps work on Android

**Prerequisites**:
- Android API key in AndroidManifest.xml
- SHA-1 fingerprint added to key restrictions
- Maps SDK for Android enabled

**Steps**:
1. Connect Android device or start emulator
2. Run: `flutter run -d <device>`
3. Navigate to map features
4. Test location picker and ride maps

**Expected Results**:
- ✅ Maps load correctly
- ✅ Can select locations
- ✅ Routes display properly
- ✅ No authorization errors

**Pass Criteria**:
- Maps visible and interactive
- Location services work
- No "Authorization failure" message

---

### TC7: iOS Platform

**Purpose**: Verify maps work on iOS

**Prerequisites**:
- iOS API key in AppDelegate.swift
- GoogleMaps imported
- Maps SDK for iOS enabled

**Steps**:
1. Connect iOS device or start simulator
2. Run: `flutter run -d <device>`
3. Navigate to map features
4. Test location picker and ride maps

**Expected Results**:
- ✅ Maps load correctly
- ✅ Can select locations
- ✅ Routes display properly
- ✅ No authorization errors

**Pass Criteria**:
- Maps visible and interactive
- Location services work
- No API key errors

---

### TC8: Environment Variable Loading

**Purpose**: Verify .env file is loaded correctly

**Prerequisites**:
- `.env` file with test keys

**Steps**:
1. Add debug print to `lib/main.dart`:
   ```dart
   print('Directions API Key: ${dotenv.env['GOOGLE_DIRECTIONS_API_KEY']}');
   ```
2. Run app and check console output

**Expected Results**:
- ✅ Console shows "Environment variables loaded successfully"
- ✅ API key is printed (or partial for security)
- ✅ No error about loading .env

**Pass Criteria**:
- Environment variables are accessible
- Keys loaded from .env file
- No parsing errors

---

### TC9: Multiple Platform Test

**Purpose**: Verify consistent behavior across platforms

**Prerequisites**:
- All platforms configured with keys

**Steps**:
1. Run on Android: `flutter run -d android`
2. Test map features
3. Run on iOS: `flutter run -d ios`
4. Test map features
5. Run on Web: `flutter run -d chrome`
6. Test map features

**Expected Results**:
- ✅ All platforms load maps correctly
- ✅ Directions API works consistently (if key configured)
- ✅ Graceful degradation is consistent
- ✅ No platform-specific issues

**Pass Criteria**:
- Same functionality on all platforms
- Consistent error handling
- Same user experience

---

### TC10: Documentation Verification

**Purpose**: Verify documentation is accurate and helpful

**Steps**:
1. Follow setup instructions in `docs/API_KEYS_SETUP.md`
2. Configure API keys as documented
3. Run validation script as documented
4. Check troubleshooting section

**Expected Results**:
- ✅ Instructions are clear and accurate
- ✅ All steps work as described
- ✅ Examples are correct
- ✅ Troubleshooting helps resolve issues

**Pass Criteria**:
- Can successfully set up using docs alone
- No missing or incorrect information
- Troubleshooting covers common issues

---

## Regression Testing

### RT1: Existing Functionality

**Purpose**: Ensure changes don't break existing features

**Steps**:
1. Test user authentication
2. Test ride creation (without maps)
3. Test ride search
4. Test chat functionality
5. Test profile updates

**Expected Results**:
- ✅ All existing features work
- ✅ No new errors introduced
- ✅ Performance is similar

**Pass Criteria**:
- No regressions in non-map features
- App remains stable

---

### RT2: Build Process

**Purpose**: Verify app builds successfully

**Steps**:
1. Clean build: `flutter clean`
2. Get dependencies: `flutter pub get`
3. Build for release: `flutter build apk` (Android)
4. Check for build errors

**Expected Results**:
- ✅ Build completes successfully
- ✅ No compilation errors
- ✅ APK/IPA created correctly

**Pass Criteria**:
- Clean build succeeds
- Release build works
- No new warnings

---

## Security Testing

### ST1: API Key Protection

**Purpose**: Verify API keys are not exposed

**Steps**:
1. Check git status: `git status`
2. Check .gitignore: `cat .gitignore`
3. Search for keys in committed files:
   ```bash
   git log -p | grep -i "AIza" || echo "No keys found"
   ```

**Expected Results**:
- ✅ `.env` is in .gitignore
- ✅ `web/google_maps_config.js` is in .gitignore
- ✅ No actual API keys in git history
- ✅ Only placeholder keys in committed files

**Pass Criteria**:
- No real API keys in version control
- Sensitive files properly gitignored

---

### ST2: API Key Restrictions

**Purpose**: Verify API keys have proper restrictions

**Steps**:
1. Go to Google Cloud Console
2. Check each API key's restrictions
3. Verify application restrictions are set
4. Verify API restrictions are set

**Expected Results**:
- ✅ Android key restricted to package name and SHA-1
- ✅ iOS key restricted to bundle ID
- ✅ Web key restricted to domain/localhost
- ✅ All keys have API restrictions

**Pass Criteria**:
- Keys cannot be used from unauthorized sources
- Only required APIs are accessible

---

## Performance Testing

### PT1: Map Load Time

**Purpose**: Ensure maps load in reasonable time

**Steps**:
1. Clear app cache
2. Launch app
3. Navigate to map screen
4. Measure time to display map

**Expected Results**:
- ✅ Map loads within 2-3 seconds
- ✅ No significant delay from environment loading
- ✅ Performance similar to before changes

**Pass Criteria**:
- Map loads quickly
- No performance degradation

---

## Test Results Template

```markdown
## Test Execution Report

**Date**: YYYY-MM-DD
**Tester**: Your Name
**Environment**: Development/Staging/Production
**Platform**: Android/iOS/Web

### Test Results Summary

| Test Case | Status | Notes |
|-----------|--------|-------|
| TC1: Validation Script | ✅ Pass | |
| TC2: Directions with Key | ✅ Pass | |
| TC3: Directions without Key | ✅ Pass | |
| TC4: Web with Key | ✅ Pass | |
| TC5: Web without Key | ✅ Pass | |
| TC6: Android Platform | ✅ Pass | |
| TC7: iOS Platform | ⏭️ Skipped | No iOS device available |
| TC8: Environment Loading | ✅ Pass | |
| TC9: Multi-Platform | ✅ Pass | |
| TC10: Documentation | ✅ Pass | |
| RT1: Existing Features | ✅ Pass | |
| RT2: Build Process | ✅ Pass | |
| ST1: Key Protection | ✅ Pass | |
| ST2: Key Restrictions | ✅ Pass | |
| PT1: Map Load Time | ✅ Pass | Avg 2.1s |

### Issues Found

1. [Issue description]
   - Severity: High/Medium/Low
   - Status: Open/Fixed
   - Fix: [Description of fix]

### Recommendations

1. [Recommendation]
2. [Recommendation]

### Sign-off

- [ ] All critical tests passed
- [ ] Documentation verified
- [ ] Security checks completed
- [ ] Ready for production

**Approved by**: _____________
**Date**: _____________
```

## Automated Testing (Future)

Consider implementing:
1. Unit tests for environment loading
2. Widget tests for map components
3. Integration tests for map functionality
4. CI/CD pipeline tests

## Support

For testing issues:
1. Review `docs/API_KEYS_SETUP.md`
2. Run validation script
3. Check Google Cloud Console
4. Review troubleshooting section

---

**Last Updated**: December 2024
**Version**: 1.0.0
