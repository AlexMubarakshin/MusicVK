//
//  AppDelegate.swift
//  MusicVK
//
//  Created by Alexandr on 20.06.16.
//  Copyright © 2016 Alex. All rights reserved.
//

import UIKit
import SwiftyVK

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, VKDelegate {
    
    var window: UIWindow?
    var backgroundSessionCompletionHandler : (() -> Void)?
    
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        UIApplication.sharedApplication().statusBarStyle = Settings.statusBarColor
        VK.start(appID: APIWorker.appID, delegate: self)
        
        // MPNowPlayingInfoCenter
        UIApplication.sharedApplication().beginReceivingRemoteControlEvents()
        
        return true
    }
    
    func application(app: UIApplication, openURL url: NSURL, options: [String : AnyObject]) -> Bool {
        VK.processURL(url, options: options)
        return true
    }
    
    func vkAutorizationFailed(error: VK.Error) {
        print("Autorization failed with error: \n\(error)")
    }
    
    func vkWillAutorize() -> [VK.Scope] {
        return APIWorker.scope
    }
    
    func vkDidAutorize(parameters: Dictionary<String, String>) {
        NSUserDefaults.standardUserDefaults().setBool(true, forKey: "isUserLoggedIn")
    }
    
    func vkDidUnautorize() {}
    
    func vkTokenPath() -> (useUserDefaults: Bool, alternativePath: String) {
        return (true, "")
    }
    
    func vkWillPresentView() -> UIViewController {
        return self.window!.rootViewController!
    }
    
    override func remoteControlReceivedWithEvent(event: UIEvent?) {
        if event!.type == UIEventType.RemoteControl {
            switch event!.subtype {
            case .RemoteControlNextTrack:
                Player.jukebox.playNext()
            case .RemoteControlPreviousTrack:
                Player.jukebox.playPrevious()
            case .RemoteControlPlay:
                Player.jukebox.play()
            case .RemoteControlPause:
                Player.jukebox.pause()
            case .RemoteControlStop:
                Player.jukebox.stop()
            default:
                print("another remote")
            }
        }
        print(event?.subtype)
    }

}

