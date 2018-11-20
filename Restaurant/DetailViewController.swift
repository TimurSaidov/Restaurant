//
//  DetailViewController.swift
//  Restaurant
//
//  Created by Timur Saidov on 20/11/2018.
//  Copyright © 2018 Timur Saidov. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {
    
    var dish: Dish?
    
    @IBOutlet weak var dishImageView: UIImageView!
    @IBOutlet weak var dishNameLabel: UILabel!
    @IBOutlet weak var dishPriceLabel: UILabel!
    @IBOutlet weak var dishDescriptionTextView: UITextView!
    @IBOutlet weak var addToOrderButton: UIButton!
    
    @IBAction func addToOrderButtonPressed(_ sender: UIButton) {
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.largeTitleDisplayMode = .never

        print("DISH - \(dish!)")
    }
}
