//
//  DishesTableViewController.swift
//  Restaurant
//
//  Created by Timur Saidov on 20/11/2018.
//  Copyright © 2018 Timur Saidov. All rights reserved.
//

import UIKit

class DishesTableViewController: UITableViewController {
    
    var menu: [Dish]?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.tableFooterView = UIView(frame: CGRect.zero)
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let menu = menu {
            return menu.count
        }
        return 0
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 85
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DishCell", for: indexPath) as! DishesTableViewCell

        guard let menu = menu  else { return cell }
        
        let dish = menu[indexPath.row]
        
        cell.dishesImageView.image = images["\(dish.name)"]
        cell.dishesNameLabel.text = dish.name
        cell.dishesPriceLabel.text = "\(Double(dish.price)) $"
        
        cell.dishesViewCell.layer.cornerRadius = cell.frame.height / 2
        cell.dishesImageView.layer.cornerRadius = cell.dishesImageView.frame.height / 2
        cell.dishesImageView.clipsToBounds = true
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "DetailSegue" {
            if let indexPath = tableView.indexPathForSelectedRow {
                guard let dvc = segue.destination as? DetailViewController else { return }
                
                let dish = menu![indexPath.row]
                
                dvc.dish = dish
                dvc.navigationItem.title = dish.name
            }
        }
    }

}
