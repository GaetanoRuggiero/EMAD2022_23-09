import UIKit
import Flutter
import GoogleMaps

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
    if let value = ProcessInfo.processInfo.environment["MAPS_API_KEY"] { GMSServices.provideAPIKey(value) }
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
