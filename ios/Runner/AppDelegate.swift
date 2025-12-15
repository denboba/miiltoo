import Flutter
import UIKit
// Uncomment the following line and add your iOS API key to enable Google Maps on iOS
// import GoogleMaps

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // Uncomment the following line and replace YOUR_IOS_API_KEY with your actual key
    // Get it from: https://console.cloud.google.com/
    // Enable: Maps SDK for iOS
    // Restrict by: iOS apps (add bundle ID)
    // GMSServices.provideAPIKey("YOUR_IOS_API_KEY")
    
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
