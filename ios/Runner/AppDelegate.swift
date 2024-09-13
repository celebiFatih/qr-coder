import UIKit
import Flutter

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
    private let CHANNEL = "app.channel.shared.data"
    private var sharedText: String?

    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        let controller = window?.rootViewController as! FlutterViewController
        let methodChannel = FlutterMethodChannel(name: CHANNEL, binaryMessenger: controller.binaryMessenger)

        methodChannel.setMethodCallHandler { (call, result) in
            if call.method == "getSharedText" {
                result(self.sharedText ?? "")
                self.sharedText = nil
            }
        }

        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }

    override func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        if url.absoluteString.hasPrefix("share") {
            sharedText = url.absoluteString
        }
        return super.application(app, open: url, options: options)
    }
}
