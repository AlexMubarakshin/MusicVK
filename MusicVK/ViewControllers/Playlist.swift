//
//  Playlist.swift
//  MusicVK
//
//  Created by Alexandr on 20.06.16.
//  Copyright © 2016 Alex. All rights reserved.
//

import Foundation
import UIKit

class Playlist {
    static let sharedInstance = Playlist()
    var playlist: [String] = []
    init () {
        update()
    }
    
    func update() {
        playlist = []
        do {
            let contentOfDir: [String] = try NSFileManager.defaultManager().contentsOfDirectoryAtPath(Utils.baseFilePath as String)
            print(contentOfDir)
            playlist.appendContentsOf(contentOfDir)
            let index = playlist.indexOf(".DS_Store")
            if let index = index {
                playlist.removeAtIndex(index)
            }
        } catch {
            // failed to read directory – bad permissions, perhaps?
        }
        print("playlist updated")
    }
    
    func removeFileAtIndex(index: Int) {
        let fileName : NSString = playlist[index] as NSString
        let fileURL  : NSURL = NSURL(fileURLWithPath: (Utils.baseFilePath as NSString).stringByAppendingPathComponent(fileName as String))
        let fileManger: NSFileManager = NSFileManager.defaultManager()
        do {
            if let _ = Player.jukebox {
                if Player.jukebox.state.description == "Playing"{
                    if let playingURL = Player.jukebox.currentItem?.URL {
                        if playingURL == fileURL {
                            Player.jukebox.stop()
                        }
                    }
                }
            }
            try fileManger.removeItemAtURL(fileURL)
            playlist.removeAtIndex(index)
            if let _ = Player.jukebox {
                if !playlist.isEmpty {
                    if index != 0 {
                        Player.jukebox.removeItems(withURL: fileURL)
                        Player.jukebox.playPrevious()
                    }
                }
            }
        } catch let error as NSError {
            debugPrint("Error while deleting file: \(error)")
        }
    }
    
    
    func getTrackName(index: Int) -> String {
        var filename = playlist[index]
        filename.removeRange(filename.endIndex.advancedBy(-4)..<filename.endIndex)
        return filename
    }
    
}