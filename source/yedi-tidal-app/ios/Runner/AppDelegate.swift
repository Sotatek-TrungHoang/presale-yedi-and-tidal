import Flutter
import UIKit
import GoogleMaps

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // Come back to this later:
    // let google_maps_api_key: String = Bundle.main.infoDictionary?["GOOGLE_MAPS_API_KEY"] as? String ?? ""
    // print("Google Maps API key has been set: \(google_maps_api_key)")
    // GMSServices.provideAPIKey(google_maps_api_key)
    GMSServices.provideAPIKey("AIzaSyDY14T-OwhYK7Y8v7_ABQXj8lOLXdVXaA8")
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
