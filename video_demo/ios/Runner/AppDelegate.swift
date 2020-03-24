import UIKit
import Flutter

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
    var allowRotation:Int = -1
    {
        didSet{

        }
    }
    
    
    
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
    FlutterNativePlugin.register(with: self.registrar(forPlugin: "FlutterNativePlugin"))
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
    
    override func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        switch self.allowRotation {
        case -1:
            return UIInterfaceOrientationMask.portrait;
        case 1:
            return UIInterfaceOrientationMask.landscapeLeft;
        case 2:
            return UIInterfaceOrientationMask.landscapeRight;
       
        default:
            return UIInterfaceOrientationMask.portrait;
        }
    }
}

