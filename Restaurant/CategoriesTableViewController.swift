//
//  CategoriesTableViewController.swift
//  Restaurant
//
//  Created by Timur Saidov on 19/11/2018.
//  Copyright © 2018 Timur Saidov. All rights reserved.
//

import UIKit

class CategoriesTableViewController: UITableViewController {
    
    var isTableViewShown: Bool = false
    let categories: [String] = ["Appetizers", "Entrees"]
    
    let activityIndicator = UIActivityIndicatorView(style: .gray)
    
    @IBAction func refreshControlAction(_ sender: UIRefreshControl) {
        isTableViewShown = false
        tableView.reloadData()
        
        Model.shared.loadData {
            DispatchQueue.main.async {
                self.isTableViewShown = true
                self.refreshControl?.endRefreshing()
                self.tableView.reloadData()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.largeTitleDisplayMode = .always

        activityIndicator.startAnimating()
        self.navigationItem.leftBarButtonItem?.customView = activityIndicator
        
        Model.shared.loadData {
            DispatchQueue.main.async {
                self.activityIndicator.stopAnimating()
                self.activityIndicator.isHidden = true
                self.isTableViewShown = true
                self.tableView.reloadData()
            }
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isTableViewShown {
            return categories.count
        }
        return 0
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 85
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell", for: indexPath) as! CategoriesTableViewCell
        
        var appetizers: Dish?
        var entrees: Dish?

        for item in menu {
            if item.category == "appetizers" {
                appetizers = item
                break
            }
        }
        for item in menu {
            if item.category == "entrees" {
                entrees = item
                break
            }
        }
        
        cell.nameCategoryLabel.text = categories[indexPath.row]

        if let appetizers = appetizers, let entrees = entrees {
            if cell.nameCategoryLabel.text == "Appetizers" {
                cell.imageViewCategory.image = images["\(appetizers.name)"]
            } else if cell.nameCategoryLabel.text == "Entrees" {
                cell.imageViewCategory.image = images["\(entrees.name)"]
            }
        }
        
        cell.viewCategoryCell.layer.cornerRadius = cell.frame.height / 2
        cell.imageViewCategory.layer.cornerRadius = cell.imageViewCategory.frame.height / 2
        cell.imageViewCategory.clipsToBounds = true

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "Segue", sender: nil)
        tableView.deselectRow(at: indexPath, animated: true)
    }

    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "Segue" {
            if let indexPath = tableView.indexPathForSelectedRow {
                guard let dvc = segue.destination as? DishesTableViewController else { return }
                
                var menuForIndexPath: [Dish] = []
                
                switch indexPath {
                case [0, 0]:
                    for dish in menu {
                        if dish.category == "appetizers" {
                            menuForIndexPath.append(dish)
                        }
                    }
                    dvc.menu = menuForIndexPath
                    dvc.navigationItem.title = "Appetizers"
                case [0, 1]:
                    for dish in menu {
                        if dish.category == "entrees" {
                            menuForIndexPath.append(dish)
                        }
                    }
                    dvc.menu = menuForIndexPath
                    dvc.navigationItem.title = "Entrees"
                default:
                    break
                }
            }
        }
    }
}

