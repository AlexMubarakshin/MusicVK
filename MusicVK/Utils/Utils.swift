//
//  Utils.swift
//  MusicVK
//
//  Created by Alexandr on 20.06.16.
//  Copyright © 2016 Alex. All rights reserved.
//

import Foundation

class Utils {
    class func getCurrentDurationAsString(duration: NSNumber) -> String {
        let seconds = Int(duration) % 60
        let minutes = (Int(duration) / 60) % 60
        
        return String(format: "%0.2d:%0.2d",minutes,seconds)
    }
    
    static let baseFilePath: String = {
        return (NSHomeDirectory() as NSString).stringByAppendingPathComponent("Documents") as String
    }()
    
    class func calculateTotalLength(audioLength: Double) -> String {
        let hour_ = abs(Int(audioLength/3600))
        let minute_ = abs(Int((audioLength/60) % 60))
        let second_ = abs(Int(audioLength % 60))
        
        let hour = hour_ > 9 ? "\(hour_)" : "0\(hour_)"
        let minute = minute_ > 9 ? "\(minute_)" : "0\(minute_)"
        let second = second_ > 9 ? "\(second_)" : "0\(second_)"
        return "\(hour):\(minute):\(second)"
    }
}