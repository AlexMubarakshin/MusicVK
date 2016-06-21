//
//  MusicTableViewCell.swift
//  VK-app
//
//  Created by Alexandr on 26.05.16.
//  Copyright © 2016 Alex. All rights reserved.
//

import UIKit

protocol VkMusicCellDelegate {
    func downloadTapped(cell: VkMusicCell)
}

class VkMusicCell: UITableViewCell {
    
    var delegate: VkMusicCellDelegate?
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var artistLabel: UILabel!
    @IBOutlet weak var durationLabel: UILabel!
    @IBOutlet weak var downloadBtnImage: UIButton!
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var timerImage: UIView!
    
    let selectedSize: CGFloat = 3
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.titleLabel.textColor = Settings.textColor
        self.artistLabel.textColor = Settings.textColor
        self.durationLabel.textColor = Settings.textColor
        self.downloadBtnImage.tintColor = Settings.textColor
        self.progressView.tintColor = Settings.textColor
        self.progressView.progressTintColor = Settings.viewColor
        self.timerImage.tintColor = Settings.textColor
        self.backgroundColor = UIColor.clearColor()
        // Initialization code
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    @IBAction func downloadTapped(sender: AnyObject) {
        delegate?.downloadTapped(self)
    }

}
