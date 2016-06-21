//
//  PlayerViewController.swift
//  MusicVK
//
//  Created by Alexandr on 20.06.16.
//  Copyright © 2016 Alex. All rights reserved.
//

import UIKit
import Jukebox

struct Player {
    static var jukebox: Jukebox!
}

class PlayerViewController: UIViewController {
    
    let playlistController = Playlist.sharedInstance
    var playlist: [String] = []
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var progressTimerLabel: UILabel!
    @IBOutlet weak var totalLengthOfAudioLabel: UILabel!
    @IBOutlet weak var playerProgressSlider: UISlider!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var prevButton: UIButton!
    @IBOutlet weak var nextButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        Player.jukebox = Jukebox(delegate: self, items: [])
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView()
        configureUI()
        settupView()
    }
    
    override func viewWillAppear(animated: Bool) {
        getPlaylist()
    }
    
    func updateJukebox() {
        var index = 0
        for track in playlist {
            var exist = false
            let documentsPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as NSString
            let path = track
            let fullPath = documentsPath.stringByAppendingPathComponent(path)
            let url = NSURL(fileURLWithPath: fullPath)
            for sound in Player.jukebox.queuedItems {
                if sound.URL == url {
                    exist = true
                }
            }
            if !exist {
                Player.jukebox.appendItem((JukeboxItem(URL: url, localTitle: playlistController.getTrackName(index))), loadingAssets : true)
            }

            index = index + 1
        }
        print(Player.jukebox.queuedItems.count)
    }
    
    func getPlaylist() {
        print("get playlist from VC")
        playlist = playlistController.playlist
        updateJukebox()
        
        dispatch_async(dispatch_get_main_queue(), {
            self.tableView.reloadData()
        })
    }
    
    //*****************************************************************
    // MARK: - Setup UI Elements
    //*****************************************************************
    
    func settupView() {
        self.navigationController?.navigationBar.barTintColor = Settings.navigationViewColor
        self.navigationController?.navigationBar.tintColor = Settings.textColor
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName : Settings.textColor]
        self.view.backgroundColor = Settings.viewColor
        self.tableView.backgroundColor = Settings.viewColor
        self.progressTimerLabel.textColor = Settings.textColor
        self.totalLengthOfAudioLabel.textColor = Settings.textColor
        self.titleLabel.textColor = Settings.textColor
        self.playButton.tintColor = Settings.controlButtonsColor
        self.prevButton.tintColor = Settings.controlButtonsColor
        self.nextButton.tintColor = Settings.controlButtonsColor
        self.playerProgressSlider.tintColor = Settings.navigationViewColor
    }
    
    func configureUI() {
        titleLabel.text = "Ничего не играет"
        totalLengthOfAudioLabel.text = "00:00:00"
        progressTimerLabel.text = "00:00:00"
        playerProgressSlider.value = 0.0
        playButton.setImage(UIImage(named: "ic_play_circle_outline"), forState: UIControlState.Normal)
    }
    
    //*****************************************************************
    // MARK: Button Actions
    //*****************************************************************
    
    @IBAction func prevButtonTapped(sender: AnyObject) {
        prevTrack()
    }
    
    @IBAction func nextButtonTapped(sender: AnyObject) {
        nextTrack()
    }
    
    @IBAction func playButtonTapped(sender: AnyObject) {
        if !playlist.isEmpty {
            if Player.jukebox.state == .Playing {
                pauseTrack()
            } else {
                playTrack()
            }
        }
    }
    
    @IBAction func progressSliderValueChanged(sender: AnyObject) {
//        if (!playlist.isEmpty && jukebox.currentItem?.URL != nil) {
            if let duration = Player.jukebox.currentItem?.duration {
                progressValueChanged(Int(Double(self.playerProgressSlider.value) * duration))
            }
//        }
    }
    
    //*****************************************************************
    // MARK: Music Actions
    //*****************************************************************
    
    func nextTrack() {
        if !playlist.isEmpty {
            Player.jukebox.playNext()
        }
    }
    
    func prevTrack() {
        if !playlist.isEmpty {
            if Player.jukebox.currentItem?.currentTime > 5 || Player.jukebox.playIndex == 0 {
                Player.jukebox.replayCurrentItem()
            } else {
                Player.jukebox.playPrevious()
            }
        }
    }
    
    func playTrack() {
        Player.jukebox.play()
    }
    
    func pauseTrack() {
        Player.jukebox.pause()
    }
    
    func stopTrack() {
        if !playlist.isEmpty {
            Player.jukebox.stop()
        }
    }
    
    func progressValueChanged(toSecond: Int) {
        Player.jukebox.seekToSecond(toSecond)
    }
}

//*****************************************************************
// MARK: - Table view data source
//*****************************************************************
extension PlayerViewController: UITableViewDataSource {
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 88
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return playlist.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("PlaylistCell", forIndexPath: indexPath)
        cell.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.1)
        cell.textLabel!.text = playlistController.getTrackName(indexPath.row)
        cell.textLabel?.textColor = Settings.textColor
        return cell
    }
}


//*****************************************************************
// MARK: - TableViewDelegate
//*****************************************************************

extension PlayerViewController: UITableViewDelegate {
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        Player.jukebox.playAtIndex(indexPath.row)
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        playlistController.removeFileAtIndex(indexPath.row)
        getPlaylist()
        configureUI()
    }
}

//*****************************************************************
// MARK: - TableViewDelegate
//*****************************************************************

extension PlayerViewController: JukeboxDelegate {
    func jukeboxStateDidChange(jukebox : Jukebox) {
        switch jukebox.state {
        case .Ready:
            print("Ready")
        case .Playing:
            let pause = UIImage(named: "ic_pause_circle_filled")
            playButton.setImage(pause, forState: UIControlState.Normal)
        case .Paused:
            let play = UIImage(named: "ic_play_circle_outline")
            playButton.setImage(play, forState: UIControlState.Normal)
        default:
            print("Another state: \(jukebox.state.description)")
        }
    }
    func jukeboxPlaybackProgressDidChange(jukebox : Jukebox) {
        if let currentTime = jukebox.currentItem?.currentTime, let duration = jukebox.currentItem?.duration  {
            let value = Float(currentTime / duration)
            playerProgressSlider.value = value
            progressTimerLabel.text = Utils.calculateTotalLength(currentTime)
            //            print("currentTimeLabel = \(currentTime)")
            //            print("durationLabel = \(duration)")
        }
    }
    func jukeboxDidLoadItem(jukebox : Jukebox, item : JukeboxItem) {
        totalLengthOfAudioLabel.text = Utils.calculateTotalLength((jukebox.currentItem?.duration!)!)
        titleLabel.text = playlistController.getTrackName(Player.jukebox.playIndex)
        titleLabel.textColor = Settings.textColor
        if let image = jukebox.currentItem?.artwork {
            if !UIAccessibilityIsReduceTransparencyEnabled() {
                let imageView = UIImageView()
                imageView.image = image
                let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.Dark)
                let blurEffectView = UIVisualEffectView(effect: blurEffect)
                //always fill the view
                blurEffectView.frame = self.tableView.bounds
                blurEffectView.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
                imageView.addSubview(blurEffectView)
                
                self.tableView.backgroundView = imageView
            }
        } else {
            self.tableView.backgroundView = UIView()
        }
    }
}
