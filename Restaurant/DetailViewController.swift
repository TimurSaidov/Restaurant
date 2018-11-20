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
    var imagesDictionary: [String: UIImage]?
    
    @IBOutlet weak var dishImageView: UIImageView!
    @IBOutlet weak var dishNameLabel: UILabel!
    @IBOutlet weak var dishPriceLabel: UILabel!
    @IBOutlet weak var dishDescriptionTextView: UITextView!
    @IBOutlet weak var addToOrderButton: UIButton!
    
    @IBAction func addToOrderButtonPressed(_ sender: UIButton) {
        UIView.animate(withDuration: 0.3) {
            self.addToOrderButton.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
            self.addToOrderButton.transform = CGAffineTransform(scaleX: 1, y: 1)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.largeTitleDisplayMode = .never
        
        addToOrderButton.layer.cornerRadius = 5

        if let dish = dish {
            if let imagesDictionary = imagesDictionary {
                dishImageView.image = imagesDictionary["\(dish.name)"]
            }
            dishNameLabel.text = dish.name
            dishPriceLabel.text = "\(Double(dish.price)) $" // String(format: "$%.2f", dish.price)
            dishDescriptionTextView.text = dish.description
        }
    }
}
