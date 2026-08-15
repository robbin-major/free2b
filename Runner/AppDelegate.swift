import UIKit
import Flutter
import GoogleMaps

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    if let apiKey = googleMapsApiKey() {
      GMSServices.provideAPIKey(apiKey)
    } else {
      NSLog("Google Maps API key is not configured. Set GOOGLE_MAPS_API_KEY through Flutter/GoogleMapsKeys.xcconfig or CI build settings.")
    }
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  private func googleMapsApiKey() -> String? {
    let environmentKey = ProcessInfo.processInfo.environment["GOOGLE_MAPS_API_KEY"]
    if let key = sanitizedGoogleMapsApiKey(environmentKey) {
      return key
    }

    let bundleKey = Bundle.main.object(forInfoDictionaryKey: "GoogleMapsApiKey") as? String
    return sanitizedGoogleMapsApiKey(bundleKey)
  }

  private func sanitizedGoogleMapsApiKey(_ value: String?) -> String? {
    guard let key = value?.trimmingCharacters(in: .whitespacesAndNewlines),
          !key.isEmpty,
          !key.contains("$(") else {
      return nil
    }
    return key
  }
}
