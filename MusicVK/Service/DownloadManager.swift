//
//  DownloadManager.swift
//  MusicVK
//
//  Created by Alexandr on 20.06.16.
//  Copyright © 2016 Alex. All rights reserved.
//

import Alamofire

typealias SuccessHandler = ((AnyObject) -> Void)
typealias Progress = (bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) -> ()
typealias FailureHandler = (error:NSError) -> ()


class DownloadManager {
    var url: String?
    var _progress: Float = 0
    init (url: String) {
        self.url = url
    }
    
    func download(fileName: String, progress: Progress, success: SuccessHandler, fail: FailureHandler) {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        Alamofire.download(.GET, url!) { temporaryURL, response in
            let fileManager = NSFileManager.defaultManager()
            let directoryURL = fileManager.URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)[0]
            
            return directoryURL.URLByAppendingPathComponent(fileName)
            }
            
            .progress { (bytesWritten, totalBytesWritten, totalBytesExpectedToWrite) in
                self._progress = Float(totalBytesWritten)/Float(totalBytesExpectedToWrite)
                progress(bytesWritten: bytesWritten, totalBytesWritten: totalBytesWritten, totalBytesExpectedToWrite: totalBytesExpectedToWrite)
            }
            
            .response { _, response, data, error in
                
                UIApplication.sharedApplication().networkActivityIndicatorVisible = false
                if let error = error {
                    fail(error: error)
                }
                success(response!)
        }
    }
}