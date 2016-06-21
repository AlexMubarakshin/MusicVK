//
//  APIWorker.swift
//  VKMusicPlayer
//
//  Created by Alexandr on 16.06.16.
//  Copyright © 2016 Alex. All rights reserved.
//

import Foundation
import SwiftyVK


public class APIWorker {
    public typealias SuccessHandler = (JSON: JSON) -> Void
    public typealias FailureHandler = (error: AnyObject) -> Void
    
    static let appID = ""
    static let scope = [VK.Scope.messages,.offline,.wall,.audio]
    
    class func autorize() {
        VK.autorize()
        print("SwiftyVK: Autorize")
    }
    
    class func logout() {
        VK.logOut()
        NSUserDefaults.standardUserDefaults().setBool(false, forKey: "isUserLoggedIn")
        print("SwiftyVK: LogOut")
    }
    
    class func capthca() {
        let req = VK.API.custom(method: "captcha.force")
        req.successBlock = {response in print("SwiftyVK: Captha success \n \(response)")}
        req.errorBlock = {error in print("SwiftyVK: Captha fail \n \(error)")}
        req.send()
    }
    
    class func validation() {
        let req = VK.API.custom(method: "account.testValidation")
        req.successBlock = {response in print("SwiftyVK: Captha success \n \(response)")}
        req.errorBlock = {error in print("SwiftyVK: Captha fail \n \(error)")}
        req.send()
    }
}