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
    var countStepperValue: Int = 0
    var dishCount: Int = 1
    var price: Int = 0
    
    @IBOutlet weak var dishImageView: UIImageView!
    @IBOutlet weak var dishNameLabel: UILabel!
    @IBOutlet weak var dishPriceLabel: UILabel!
    @IBOutlet weak var dishDescriptionTextView: UITextView!
    @IBOutlet weak var countLabel: UILabel!
    @IBOutlet weak var countStepper: UIStepper!
    @IBOutlet weak var addToOrderButton: UIButton!
    
    @IBAction func addCountButton(_ sender: UIStepper) {
        if Int(countStepper.value) > countStepperValue { // Если нажат "+", то countStepper.value += 1; если нажат "-", то countStepper.value -= 1
            dishCount += 1
            countLabel.text = "\(dishCount) p."
            price += dish!.price
            dishPriceLabel.text = "\(Double(price)) $"
            countStepperValue += 1
        } else {
            dishCount -= 1
            countLabel.text = "\(dishCount) p."
            price -= dish!.price
            dishPriceLabel.text = "\(Double(price)) $"
            countStepperValue -= 1
        }
    }
    
    @IBAction func addToOrderButtonPressed(_ sender: UIButton) {
        UIView.animate(withDuration: 0.3) {
            self.addToOrderButton.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
            self.addToOrderButton.transform = CGAffineTransform(scaleX: 1, y: 1)
        }
        
        guard let dish = dish else { return }
        
        let orderDish = OrderDish(context: CoreDataManager.shared.managedObjectContext)
        orderDish.name = dish.name
        orderDish.aboutText = dish.description
        orderDish.id = Double(dish.id)
        orderDish.price = Double(price)
        orderDish.category = dish.category
        orderDish.count = Double(dishCount)
        
        CoreDataManager.shared.saveContext()
        
        // сообщение о том, что блюдо добавлено в корзину
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
            price = dish.price
            dishPriceLabel.text = "\(Double(price)) $" // String(format: "$%.2f", price)
            dishDescriptionTextView.text = dish.description
        }
    }
}
