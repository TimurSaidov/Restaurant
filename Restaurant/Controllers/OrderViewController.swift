//
//  OrderViewController.swift
//  Restaurant
//
//  Created by Timur Saidov on 21/11/2018.
//  Copyright © 2018 Timur Saidov. All rights reserved.
//

import UIKit
import CoreData

class OrderViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var orderDishes: [OrderDish] = []
    var dictionaryOfDataImages: [String: Data] = [:]

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
            let alertController = UIAlertController(title: "", message: "", preferredStyle: .alert)
            
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
            }
            let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            
            alertController.addAction(delete)
            alertController.addAction(cancel)
            
            present(alertController, animated: true, completion: nil)
        }
    }
}

//func updateBadgeNumber() {
//    // get the number of items in the order
//    let badgeValue = 0 < menuItems.count ? "\(menuItems.count)" : nil
//    
//    // assign the badge value to the order tab
//    navigationController?.tabBarItem.badgeValue = badgeValue
//}
