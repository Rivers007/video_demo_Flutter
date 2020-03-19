import UIKit
import Flutter

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
    FlutterNativePlugin.register(with: self.registrar(forPlugin: "FlutterNativePlugin"))
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}

/**
 UIViewController *recordParam = [[AlivcShortVideoRoute shared] alivcViewControllerWithType:AlivcViewControlRecordParam];
 [self.navigationController setNavigationBarHidden:YES];
 [self.navigationController pushViewController:recordParam animated:YES];

 */
