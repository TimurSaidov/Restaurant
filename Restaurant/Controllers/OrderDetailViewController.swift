//
//  OrderDetailViewController.swift
//  Restaurant
//
//  Created by Timur Saidov on 22/11/2018.
//  Copyright © 2018 Timur Saidov. All rights reserved.
//

import UIKit

class OrderDetailViewController: UIViewController {
    
    var price: Double?
    var number: Int?

    @IBOutlet weak var numberOfOrderLabel: UILabel!
    @IBOutlet weak var orderLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        numberOfOrderLabel.text = "Your Order № \(number!)"
        orderLabel.text = "Thank you for your order! Your order for \(price!) $ is prepared. Wait time is approximatly 30 minutes"
    }
}
