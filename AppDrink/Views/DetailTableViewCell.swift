//
//  DetailTableViewCell.swift
//  DrinkApp
//
//  Created by 陳秉軒 on 2022/5/5.
//

import UIKit

class DetailTableViewCell: UITableViewCell {

   
    @IBOutlet weak var chooseLabel: UILabel!
    
    
    @IBOutlet weak var moneyLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
