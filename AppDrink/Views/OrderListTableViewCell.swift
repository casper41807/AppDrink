//
//  OrderListTableViewCell.swift
//  DrinkApp
//
//  Created by 陳秉軒 on 2022/5/9.
//

import UIKit

class OrderListTableViewCell: UITableViewCell {

    @IBOutlet weak var nameImage: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subTitleLabel: UILabel!
    @IBOutlet weak var totalMoneyLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
