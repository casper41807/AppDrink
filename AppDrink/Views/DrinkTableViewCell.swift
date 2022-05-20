//
//  DrinkTableViewCell.swift
//  DrinkApp
//
//  Created by 陳秉軒 on 2022/5/5.
//

import UIKit

class DrinkTableViewCell: UITableViewCell {

    
    @IBOutlet weak var nameLabel: UILabel!
    
    
    @IBOutlet weak var priceLabel: UILabel!
    
    
    @IBOutlet weak var mikeCapLabel: UILabel!
    
    
    @IBOutlet weak var drinkImage: UIImageView!
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
