//
//  OrderViewController.swift
//  Restaurant
//
//  Created by Timur Saidov on 21/11/2018.
//  Copyright © 2018 Timur Saidov. All rights reserved.
//

import UIKit
import CoreData

protocol AddToOrderDelegate {
    func updateBadgeNumber()
}

class OrderViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var orderDishes: [OrderDish] = []
    var dictionaryOfDataImages: [String: Data] = [:]
    var price: Double = 0
    var count: Double = 0

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var varningLabel: UILabel!
    
    @IBAction func submitButtonPressed(_ sender: UIButton) {
        UIView.animate(withDuration: 0.3) {
            self.submitButton.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
            self.submitButton.transform = CGAffineTransform(scaleX: 1, y: 1)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        submitButton.layer.cornerRadius = 5
        
        tableView.tableFooterView = UIView(frame: CGRect.zero)
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
        
        tableView.reloadData()
        
        if orderDishes.count != 0 {
            varningLabel.isHidden = true
            submitButton.isHidden = false
        } else {
            varningLabel.isHidden = false
            submitButton.isHidden = true
        }
        
        for orderDish in orderDishes {
            price += orderDish.price
        }
        submitButton.setTitle("Submit the order for \(price) $", for: .normal)
        price = 0
    }
    
    // MARK: - Table view data source
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return orderDishes.count
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 85
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "OrderCell") as! OrderTableViewCell
        
        let orderDish = orderDishes[indexPath.row]
        
        cell.orderImageView.image = UIImage(data: orderDish.image!)
        cell.orderNameLabel.text = orderDish.name
        cell.orderCountLabel.text = "\(Int(orderDish.count)) p."
        cell.orderPriceLabel.text = "\(orderDish.price) $"
        
        cell.orderViewCell.layer.cornerRadius = cell.frame.height / 2
        cell.orderImageView.layer.cornerRadius = cell.orderImageView.frame.height / 2
        cell.orderImageView.clipsToBounds = true
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let alertController = UIAlertController(title: "Do you really want to remove the dish from the order?", message: nil, preferredStyle: .alert)
            
            let delete = UIAlertAction(title: "Delete", style: .destructive) { (action) in
                let orderDish = self.orderDishes[indexPath.row]
                
                CoreDataManager.shared.managedObjectContext.delete(orderDish)
                CoreDataManager.shared.saveContext()
                
                self.orderDishes.remove(at: indexPath.row)
                
                tableView.beginUpdates()
                tableView.deleteRows(at: [indexPath], with: .fade)
                tableView.endUpdates()
                
                if self.orderDishes.count == 0 {
                    self.varningLabel.isHidden = false
                    self.submitButton.isHidden = true
                }
                
                for orderDish in self.orderDishes {
                    self.price += orderDish.price
                    self.count += orderDish.count
                }
                self.submitButton.setTitle("Submit the order for \(self.price) $", for: .normal)
                self.price = 0
                let badgeValue = self.count == 0 ? nil : self.count
                if let badgeValue = badgeValue {
                    self.navigationController?.tabBarItem.badgeValue = "\(Int(badgeValue))"
                } else {
                    self.navigationController?.tabBarItem.badgeValue = nil
                }
                self.count = 0
            }
            let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            
            alertController.addAction(delete)
            alertController.addAction(cancel)
            
            present(alertController, animated: true, completion: nil)
        }
    }
}

extension OrderViewController: AddToOrderDelegate {
    func updateBadgeNumber() {
        var updateOrderDishes: [OrderDish] = []
        
        let request = NSFetchRequest<OrderDish>(entityName: "OrderDish")
        
        let sortDescriptor = NSSortDescriptor(key: "name", ascending: true)
        request.sortDescriptors = [sortDescriptor]
        
        do {
            updateOrderDishes = try CoreDataManager.shared.managedObjectContext.fetch(request)
        } catch {
            print(error.localizedDescription)
        }
        
        for orderDish in updateOrderDishes {
            count += orderDish.count
        }
        
        let badgeValue = count == 0 ? nil : count
        if let badgeValue = badgeValue {
            navigationController?.tabBarItem.badgeValue = "\(Int(badgeValue))"
        } else {
            navigationController?.tabBarItem.badgeValue = nil
        }
        count = 0
    }
}
