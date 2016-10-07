//
//  FriendCellTableViewCell.swift
//  HackathonBase
//
//  Created by Sihao Lu, Vincent Yan on 9/13/15.
//  Copyright © 2015 Sihao Lu, Vincent Yan. All rights reserved.
//

import UIKit

class FriendCellTableViewCell: UITableViewCell {
    
    @IBOutlet var profileImageView: UIImageView!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var statusLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
