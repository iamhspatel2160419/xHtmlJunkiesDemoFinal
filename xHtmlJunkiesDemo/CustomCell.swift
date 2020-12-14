//
//  CustomCell.swift
//  xHtmlJunkiesDemo
//
//  Created by Apple on 08/12/20.
//

import UIKit
class CustomCell: UITableViewCell {

    @IBOutlet weak var lblTimeStartEnd: UILabel!
    
    @IBOutlet weak var lblTag: UILabel!
    @IBOutlet weak var lblHeader: UILabel!
    @IBOutlet weak var lblDescription: UILabel!
    @IBOutlet weak var lblAddress: UILabel!
    

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
