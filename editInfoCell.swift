//
//  editInfoCell.swift
//  PetSelector
//
//  Created by 刘月 on 8/18/17.
//  Copyright © 2017 YueLiu. All rights reserved.
//

import UIKit

class editInfoCell: UITableViewCell {

    @IBOutlet weak var titleLbl: UILabel!
    
  
    @IBOutlet weak var detailLbl: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
