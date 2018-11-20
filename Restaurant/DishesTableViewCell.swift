//
//  DishesTableViewCell.swift
//  Restaurant
//
//  Created by Timur Saidov on 20/11/2018.
//  Copyright © 2018 Timur Saidov. All rights reserved.
//

import UIKit

class DishesTableViewCell: UITableViewCell {

    @IBOutlet weak var dishesViewCell: UIView!
    @IBOutlet weak var dishesImageView: UIImageView!
    @IBOutlet weak var dishesNameLabel: UILabel!
    @IBOutlet weak var dishesPriceLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
