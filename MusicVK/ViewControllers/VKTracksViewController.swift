//
//  VKTracksViewController.swift
//  VKMusicPlayer
//
//  Created by Alexandr on 16.06.16.
//  Copyright © 2016 Alex. All rights reserved.
//

import UIKit
import SwiftyVK

class Track {
    var artist: String?
    var title: String?
    var displayTitle: String?
    var duration: Int?
    var trackURL: String?
}

class VKTracksViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var authorizeButton: UIBarButtonItem!
    var refreshControl: UIRefreshControl!
    var resultSearchController = UISearchController(searchResultsController: nil)
    var filteredTableData = [Track]()
    var songs = [Track]()
    var activeDownloads: [String: DownloadManager] = [:]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.registerNib(UINib(nibName: "VkMusicCell", bundle: nil), forCellReuseIdentifier: "VkMusicCell")
        self.tableView.delegate = self
        self.tableView.dataSource = self
        setupSearchBar()
        setupPullToRefresh()
        settupView()
        dispatch_async(dispatch_get_main_queue()) {
            self.checkLogeed()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func autorizeTapped(sender: AnyObject) {
        if (NSUserDefaults.standardUserDefaults().boolForKey("isUserLoggedIn")) {
            dispatch_async(dispatch_get_global_queue(Int(QOS_CLASS_USER_INITIATED.rawValue), 0)) {
                APIWorker.logout()
                dispatch_async(dispatch_get_main_queue()) {
                    self.navigationController?.popViewControllerAnimated(true)
                }
            }
        } else {
            dispatch_async(dispatch_get_global_queue(Int(QOS_CLASS_USER_INITIATED.rawValue), 0)) {
                APIWorker.autorize()
                dispatch_async(dispatch_get_main_queue()) {
                    self.checkLogeed()
                }
            }
        }
    }
    func checkLogeed() {
        if (NSUserDefaults.standardUserDefaults().boolForKey("isUserLoggedIn")) {
            authorizeButton.title = "Выход"
            
            dispatch_async(dispatch_get_main_queue(), {
                self.refreshControl?.beginRefreshing()
            })
        } else {
            authorizeButton.enabled = true
        }
    }
    
    //*****************************************************************
    // MARK: - Setup UI Elements
    //*****************************************************************
    
    func settupView() {
        self.tableView.backgroundColor = Settings.viewColor
        
    }
    
    func setupPullToRefresh() {
        refreshControl = UIRefreshControl()
        
        refreshControl.attributedTitle = NSAttributedString(string: "Идет обновление...")
        refreshControl.tintColor = UIColor.blackColor()
        refreshControl?.backgroundColor = Settings.viewColor
        refreshControl!.addTarget(self, action: #selector(VKTracksViewController.refresh(_:)), forControlEvents: UIControlEvents.ValueChanged)
        tableView.addSubview(refreshControl)
        refreshControl.beginRefreshing()
        refresh(refreshControl)
    }
    
    func setupSearchBar() {
        resultSearchController.searchResultsUpdater = self
        resultSearchController.dimsBackgroundDuringPresentation = false
        resultSearchController.searchBar.sizeToFit()
        resultSearchController.hidesNavigationBarDuringPresentation = false
        resultSearchController.searchBar.placeholder = "Поиск по артисту"
        resultSearchController.searchBar.searchBarStyle = .Minimal
        resultSearchController.searchBar.showsCancelButton = false
        dispatch_async(dispatch_get_main_queue(), {
            self.navigationItem.titleView = self.resultSearchController.searchBar
        })
    }
    
    //*****************************************************************
    // MARK: - Actions
    //*****************************************************************
    
    func refresh(sender:AnyObject) {
        print("refresh")
        getAudios()
    }
    
    func getAudios() {
        print("get audio")
        VK.API.Audio.get().send(
            success: {response in
                self.parseMusicItems(response)
            },
            error: {error in print(error)})
    }
    
    func parseMusicItems(response: JSON) {
        songs = []
        let items = (response["items"])
        for (_,item):(String, JSON) in items {
            let track = Track()
            track.artist = item["artist"].stringValue
            track.title = item["title"].stringValue
            track.displayTitle = item["artist"].stringValue + " - " + item["title"].stringValue + ".mp3"
            track.trackURL = item["url"].stringValue
            track.duration = item["duration"].intValue
            songs.append(track)
        }
        
        
        dispatch_async(dispatch_get_main_queue(), {
            self.refreshControl.endRefreshing()
            self.tableView.reloadData()
        })
    }
    
    
    func startDownload(track: Track, index: Int) {
        if let urlString = track.trackURL { //, url =  NSURL(string: urlString) {
            print(index)
            let download = DownloadManager(url: urlString)
            let trackCell = self.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: index, inSection: 0)) as? VkMusicCell
            activeDownloads[urlString] = download
            trackCell?.downloadBtnImage.hidden = true
            
            download.download(track.displayTitle!, progress: { (bytesWritten, totalBytesWritten, totalBytesExpectedToWrite) in
                let progr = download._progress
                print("->    \(progr)%")
                trackCell?.progressView.progress = progr
                },  success: { response in
                    if response.statusCode == 200 {
                        Playlist.sharedInstance.update()
                        self.activeDownloads[urlString] = nil
                        self.tableView.reloadRowsAtIndexPaths([NSIndexPath(forRow: index, inSection: 0)], withRowAnimation: .None)
                    }
                }, fail: { (error) in
                    print(error)
            })
        }
    }
    
    
    func localFilePathForUrl(previewUrl: String) -> NSURL? {
        let documentsPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as NSString
        let url = previewUrl
        let fullPath = documentsPath.stringByAppendingPathComponent(url)
        return NSURL(fileURLWithPath:fullPath)
    }
    
    func localFileExistsForTrack(track: Track) -> Bool {
        if let urlString = track.displayTitle, localUrl = localFilePathForUrl(urlString) {
            var isDir : ObjCBool = false
            if let path = localUrl.path {
                return NSFileManager.defaultManager().fileExistsAtPath(path, isDirectory: &isDir)
            }
        }
        return false
    }
    
}


extension VKTracksViewController: UITableViewDataSource {
    func numberOfSectionsInTableView(tableview: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (self.resultSearchController.active) {
            return self.filteredTableData.count
        }
        else {
            return songs.count
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("VkMusicCell") as! VkMusicCell
        cell.delegate = self
        
        if (self.resultSearchController.active) {
            let track = filteredTableData[indexPath.row]
            cell.titleLabel?.text = track.title
            cell.artistLabel?.text = track.artist
            cell.durationLabel?.text = Utils.getCurrentDurationAsString(track.duration!)
            
            var showDownloadControls = false
            if activeDownloads[track.trackURL!] != nil {
                showDownloadControls = true
                cell.downloadBtnImage.hidden = true
            }
            cell.progressView.hidden = !showDownloadControls
            
            let downloaded = localFileExistsForTrack(track)
            cell.selectionStyle = downloaded ? UITableViewCellSelectionStyle.Gray : UITableViewCellSelectionStyle.None
            cell.downloadBtnImage.hidden = downloaded || showDownloadControls
            
            return cell
        } else {
            let track = songs[indexPath.row]
            cell.titleLabel?.text = track.title
            cell.artistLabel?.text = track.artist
            cell.durationLabel?.text = Utils.getCurrentDurationAsString(track.duration!)
            
            
            var showDownloadControls = false
            if activeDownloads[track.trackURL!] != nil {
                showDownloadControls = true
                
                cell.downloadBtnImage.hidden = true
            }
            cell.progressView.hidden = !showDownloadControls
            
            let downloaded = localFileExistsForTrack(track)
            cell.selectionStyle = downloaded ? UITableViewCellSelectionStyle.Gray : UITableViewCellSelectionStyle.None
            cell.downloadBtnImage.hidden = downloaded || showDownloadControls
            
            return cell
        }
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if (self.resultSearchController.active) {
            return "Найдено \(filteredTableData.count) аудиозаписей"
        } else {
            return "Всего \(songs.count) аудиозаписей"
        }
    }
}

//*****************************************************************
// MARK: - TableViewDelegate
//*****************************************************************

extension VKTracksViewController: UITableViewDelegate {
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 72
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        print(indexPath.row)
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
}


//*****************************************************************
// MARK: - VkMusicCellDelegate
//*****************************************************************

extension VKTracksViewController: VkMusicCellDelegate {
    func downloadTapped(cell: VkMusicCell) {
        guard let indexPath = tableView.indexPathForCell(cell) else {
            return
        }
        let track = songs[indexPath.row]
        startDownload(track, index: indexPath.row)
        
        dispatch_async(dispatch_get_main_queue(), {
            self.tableView.reloadRowsAtIndexPaths([NSIndexPath(forRow: indexPath.row, inSection: 0)], withRowAnimation: .None)
        })
    }
}

//*****************************************************************
// MARK: - SearchBar
//*****************************************************************

extension VKTracksViewController: UISearchResultsUpdating {
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        filteredTableData.removeAll(keepCapacity: false)
        
        filteredTableData = songs.filter({ (Track) -> Bool in
            return Track.artist?.rangeOfString(searchController.searchBar.text!) != nil
        })
        
        self.tableView.reloadData()
    }
}

