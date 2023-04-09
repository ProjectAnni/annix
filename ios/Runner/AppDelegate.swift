import UIKit
import Flutter

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    let dummy = dummy_method_to_enforce_bundling_ApiNetwork()
    print(dummy)

    GeneratedPluginRegistrant.register(with: self)

    // Exclude the documents folder from iCloud backup.
    try! setExcludeFromiCloudBackup(isExcluded: true)

    application.beginReceivingRemoteControlEvents()

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}

private func setExcludeFromiCloudBackup(isExcluded: Bool) throws {
    var fileOrDirectoryURL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
    var values = URLResourceValues()
    values.isExcludedFromBackup = isExcluded
    try fileOrDirectoryURL.setResourceValues(values)
}
