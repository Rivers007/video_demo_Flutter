//
//  FlutterNativePlugin.swift
//  Runner
//
//  Created by corpizeUser on 2019/12/19.
//  Copyright © 2019 The ritchie Authors. All rights reserved.
//

import Foundation
import Flutter

fileprivate let encryptKey = "5%h==n_n_~h$k33!"


class FlutterNativePlugin: NSObject, FlutterPlugin {
    
    
    enum flutterMethod: String {
        /// 录制
        case record = "record"
        case landscapeLeft = "landscapeLeft"
        case landscapePortrait = "landscapePortrait"
    }
    
    
    static func register(with registrar: FlutterPluginRegistrar) {
        
        let plugin = FlutterNativePlugin()
        
      
        let recordVideo = FlutterMethodChannel.init(name: "recordVideo", binaryMessenger: registrar.messenger())
        let landscape = FlutterMethodChannel.init(name: "landscape", binaryMessenger: registrar.messenger())

       
        registrar.addMethodCallDelegate(plugin, channel: recordVideo)
        registrar.addMethodCallDelegate(plugin, channel: landscape)


        
    }

    
    
    func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {

        let method = flutterMethod.init(rawValue: call.method)
        
        switch method {
        
        //MARK: --录制
        case .record:
            let recordParam:UIViewController = AlivcShortVideoRoute.shared().alivcViewController(with: .recordParam);
            let nav:UINavigationController = UINavigationController(rootViewController: recordParam);
            nav.setNavigationBarHidden(true, animated: false);
            nav.modalPresentationStyle = .fullScreen; UIApplication.shared.keyWindow?.rootViewController?.present(nav, animated: true, completion: nil);
            
            break
            
        case .landscapeLeft:
            let delegate:AppDelegate=UIApplication.shared.delegate as! AppDelegate;
            delegate.allowRotation = 2;
            break
        case .landscapePortrait:
        let delegate:AppDelegate=UIApplication.shared.delegate as! AppDelegate;
        delegate.allowRotation = -1;
        break
            
        default:
            result("")
            return
        }
        
    }

}

