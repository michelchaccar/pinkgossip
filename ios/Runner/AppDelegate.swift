import Flutter
import UIKit
import Firebase
import GoogleMaps
import app_links

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    FirebaseApp.configure()
    GMSServices.provideAPIKey("AIzaSyDSiRz_NuSU1XSIAmKaFYYgEK3xf6XKD8k")
//    GMSServices.provideAPIKey("AIzaSyCRNjykxoRKwqenOpoqBdoYz1CTvPYI5So")
    GeneratedPluginRegistrant.register(with: self)
      if let url = AppLinks.shared.getLink(launchOptions: launchOptions)
        {
          AppLinks.shared.handleLink(url: url)
          return true // Returning true will stop propagation to other packages
        }
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
