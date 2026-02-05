import Flutter
import UIKit
import Firebase
import GoogleMaps
import app_links
import UserNotifications   // 👈 ADD THIS

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {

    FirebaseApp.configure()
    GMSServices.provideAPIKey("AIzaSyDSiRz_NuSU1XSIAmKaFYYgEK3xf6XKD8k")

    GeneratedPluginRegistrant.register(with: self)

    // 🔔 LOCAL NOTIFICATION PERMISSION (iOS)
    UNUserNotificationCenter.current().requestAuthorization(
      options: [.alert, .badge, .sound]
    ) { granted, error in
      if granted {
        print("iOS Notification permission granted")
      } else {
        print("iOS Notification permission denied")
      }
    }

    // Deep link handling
    if let url = AppLinks.shared.getLink(launchOptions: launchOptions) {
      AppLinks.shared.handleLink(url: url)
      return true
    }

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
