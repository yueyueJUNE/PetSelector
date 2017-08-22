
//
//  PetHeaderCell.swift
//  LocationSelector
//
//  Created by 刘月 on 7/9/17.
//  Copyright © 2017 Tianmaying. All rights reserved.
//

import UIKit
var guestID = [String]()

class PetHeaderCell: UITableViewCell {
    
    @IBOutlet weak var backgroundscrollview: UIScrollView!
   
    @IBOutlet weak var photoGallery: UIScrollView!
    @IBOutlet weak var pageControl: UIPageControl!
    //ui objects
    @IBOutlet weak var petnameLbl: UILabel!
    @IBOutlet weak var breedBtn: UIButton!
    @IBOutlet weak var locationLbl: UILabel!
    @IBOutlet weak var genderLbl: UILabel!
    @IBOutlet weak var ageLbl: UILabel!
    @IBOutlet weak var sizeLbl: UILabel!
    @IBOutlet weak var neuterBtn: UIButton!
    @IBOutlet weak var shotBtn: UIButton!
    @IBOutlet weak var dewormBtn: UIButton!
    @IBOutlet weak var collectLbl: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
  
        breedBtn.layer.cornerRadius = 4
        //breedBtn.clipsToBounds = true
        breedBtn.layer.borderColor = UIColor.darkGray.cgColor
        breedBtn.layer.borderWidth = 1
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
