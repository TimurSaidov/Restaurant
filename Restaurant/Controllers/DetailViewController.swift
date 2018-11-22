//
//  DetailViewController.swift
//  Restaurant
//
//  Created by Timur Saidov on 20/11/2018.
//  Copyright © 2018 Timur Saidov. All rights reserved.
//

import UIKit
import CoreData

class DetailViewController: UIViewController {
    
    var dish: Dish?
    var imagesDictionary: [String: Data]?
    var countStepperValue: Int = 0
    var dishCount: Int = 1
    var price: Int = 0
    var orderDishes: [OrderDish] = []
    
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
        
        var equalDish: Bool = false
        var orderDish: OrderDish?
        
        for orderDishInOrderDishes in orderDishes {
            if dish.id == Int(orderDishInOrderDishes.id) {
                equalDish = true
                orderDish = orderDishInOrderDishes
                break
            }
        }
        
        if equalDish {
            let countOrderDish = orderDish!.count
            let priceOrderDish = orderDish!.price
            CoreDataManager.shared.managedObjectContext.delete(orderDish!)
            
            let newOrderDish = OrderDish(context: CoreDataManager.shared.managedObjectContext)
            
            newOrderDish.name = dish.name
            newOrderDish.aboutText = dish.description
            newOrderDish.id = Double(dish.id)
            newOrderDish.price = Double(price) + priceOrderDish
            newOrderDish.category = dish.category
            newOrderDish.count = Double(dishCount) + countOrderDish
            let imageData = imagesDictionary!["\(dish.name)"]
            newOrderDish.image = imageData
        } else {
            let newOrderDish = OrderDish(context: CoreDataManager.shared.managedObjectContext)
            
            newOrderDish.name = dish.name
            newOrderDish.aboutText = dish.description
            newOrderDish.id = Double(dish.id)
            newOrderDish.price = Double(price)
            newOrderDish.category = dish.category
            newOrderDish.count = Double(dishCount)
            let imageData = imagesDictionary!["\(dish.name)"]
            newOrderDish.image = imageData
        }
        
        CoreDataManager.shared.saveContext()
        
        dishCount = 1
        price = dish.price
        countStepper.value = 0
        countStepperValue = 0
        countLabel.text = "\(dishCount) p."
        dishPriceLabel.text = "\(Double(price)) $"
        
        // сообщение о том, что блюдо добавлено в корзину
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.largeTitleDisplayMode = .never
        
        addToOrderButton.layer.cornerRadius = 5

        if let dish = dish {
            if let imagesDictionary = imagesDictionary {
                let imageData = imagesDictionary["\(dish.name)"]
                dishImageView.image = UIImage(data: imageData!)
            }
            dishNameLabel.text = dish.name
            price = dish.price
            dishPriceLabel.text = "\(Double(price)) $" // String(format: "$%.2f", price)
            dishDescriptionTextView.text = dish.description
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        let request = NSFetchRequest<OrderDish>(entityName: "OrderDish")
        
        let sortDescriptor = NSSortDescriptor(key: "name", ascending: true)
        request.sortDescriptors = [sortDescriptor]
        
        do {
            orderDishes = try CoreDataManager.shared.managedObjectContext.fetch(request)
        } catch {
            print(error.localizedDescription)
        }
    }
}
