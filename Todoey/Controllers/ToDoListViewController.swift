//
//  ViewController.swift
//  Todoey
//
//  Created by Rodolphe DUPUY on 11/05/2020.
//  Copyright © 2019 Rod. All rights reserved.
//

import UIKit
import CoreData

class ToDoListViewController: UITableViewController {
    
    var itemArray = [Item]()
    
    // UserDefaults
    //let defaults = UserDefaults.standard
    
    // NSCoder
    //let dataFilePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("Items.plist")
    // print(dataFilePath)
    
    // CoreData
    // let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    let context = CoreDataCloudDeclaration.persistentContainer.viewContext
    
    var selectedCategory : Category? {
        didSet{
            loadItems()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        //loadItems()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        guard let navBar = navigationController?.navigationBar else {fatalError()}
        if let name = selectedCategory?.name {
            title = name
            navBar.isTranslucent = true
        }
    }
    
    //MARK: DataSource Method (A connaitre)
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemArray.count
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //let cell = UITableViewCell(style: .default, reuseIdentifier: "ToDoItemCell")
        let cell = tableView.dequeueReusableCell(withIdentifier: "ItemCell", for: indexPath)
        cell.textLabel?.text = itemArray[indexPath.row].title
        
        //        if itemArray[indexPath.row].done == true {
        //            cell.accessoryType = .checkmark
        //        } else {
        //            cell.accessoryType = .none
        //        }
        
        let item = itemArray[indexPath.row]
        //        if item.done == true {
        //            cell.accessoryType = .checkmark
        //        } else {
        //            cell.accessoryType = .none
        //        }
        //cell.accessoryType = item.done == true ? .checkmark : .none
        cell.accessoryType = item.done ? .checkmark : .none
        //cell.textLabel?.isHighlighted = item.highLighted
        cell.textLabel?.isEnabled = item.highLighted
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //print(itemArray[indexPath.row])
        
        //        if tableView.cellForRow(at: indexPath)?.accessoryType == .checkmark {
        //            tableView.cellForRow(at: indexPath)?.accessoryType = .none
        //        } else {
        //            tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
        //        }
        
        //        if itemArray[indexPath.row].done == true {
        //            itemArray[indexPath.row].done = false
        //        } else {
        //            itemArray[indexPath.row].done = true
        //        }
        
        // CoreData (not used because synchronized with itemArray)
        //context.delete(itemArray[indexPath.row])
        //itemArray.remove(at: indexPath.row)
        
        //itemArray[indexPath.row].done = !itemArray[indexPath.row].done
        
        // Check or Uncheck line
        if itemArray[indexPath.row].done == true && itemArray[indexPath.row].highLighted == true {
            itemArray[indexPath.row].highLighted = false
            itemArray[indexPath.row].done = false
        } else {
            if itemArray[indexPath.row].highLighted == true {
                itemArray[indexPath.row].done = true
            } else {
                itemArray[indexPath.row].highLighted = true
                itemArray[indexPath.row].done = false
            }
        }
        tableView.deselectRow(at: indexPath, animated: true)
        
        saveItems()
        //tableView.reloadData()
    }
    
    //MARK: - Delete management into TableView
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        context.delete(itemArray[indexPath.row])
        itemArray.remove(at: indexPath.row) // Delete line into array using index
        tableView.deleteRows(at: [indexPath], with: .automatic) // with animation
        self.saveItems()
    }
    
    //MARK: Refresh List when scroll down
    override func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        tableView.reloadData()
    }
    
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        var textField = UITextField()
        let alert = UIAlertController(title: "Add New Item", message: "", preferredStyle: .alert)
        let action = UIAlertAction(title: "Add Item", style: .default) { (action) in
            
            //let newItem = Item()
            let newItem = Item(context: self.context) // CoreData
            
            newItem.title = textField.text!
            newItem.done = false
            newItem.highLighted = false
            newItem.parentCategory = self.selectedCategory
            
            self.itemArray.append(newItem)
            
            self.saveItems()
        }
        
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Create new item"
            textField = alertTextField
            textField.keyboardType = .default
            textField.keyboardAppearance = .default
            textField.autocapitalizationType = .sentences
            textField.autocorrectionType = .default
        }
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
                
    }
    @IBAction func editButtonPressed(_ sender: UIBarButtonItem) {
        if tableView.isEditing == true {
            tableView.setEditing(false, animated: true)
        } else {
            tableView.setEditing(true, animated: true)
        }
    }
    
    func saveItems() {
        
        // UserDefaults
        //self.defaults.set(self.itemArray, forKey: "ToDoListArray") // Save with UserDefaults
        
        // NSCoder
        //        let encoder = PropertyListEncoder()
        //        do {
        //            let data = try encoder.encode(self.itemArray)
        //            try data.write(to: self.dataFilePath!)
        //        } catch {
        //            print(error)
        //        }
        
        // CoreData
        do {
            try context.save()
        } catch {
            print(error)
        }
        
        self.tableView.reloadData()
    }
    
    func loadItems(with request: NSFetchRequest<Item> = Item.fetchRequest(), predicate: NSPredicate? = nil) {
        
        // UserDefaults
        //        if let items = defaults.array(forKey: "ToDoListArray") as? [Item] {
        //            itemArray = items
        //        }
        
        // NSCoder
        //        if let data = try? Data(contentsOf: dataFilePath!) {
        //            let decoder = PropertyListDecoder()
        //            do {
        //                itemArray = try decoder.decode([Item].self, from: data)
        //            } catch {
        //                print(error)
        //            }
        //        }
        
        // CoreData
        //let request: NSFetchRequest<Item> = Item.fetchRequest() //f unc loadItems(with request: NSFetchRequest<Item> = Item.fetchRequest()
        
        // with Category
        let categoryPredicate = NSPredicate(format: "parentCategory.name MATCHES %@", selectedCategory!.name!)
        if let addtionalPredicate = predicate { // predicate: NSPredicate? = nil)
            request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [categoryPredicate, addtionalPredicate])
        } else {
            request.predicate = categoryPredicate
        }
        request.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]

        do {
            itemArray = try context.fetch(request)
        } catch {
            print(error)
        }
        tableView.reloadData()
    }
    
}

//MARK: - Search Bar methods
extension ToDoListViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        let request: NSFetchRequest<Item> = Item.fetchRequest() // CoreData
        //request.predicate = NSPredicate(format: "title CONTAINS[cd] %@", searchBar.text!)
        let predicate = NSPredicate(format: "title CONTAINS[cd] %@", searchBar.text!)
        
        request.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
        
        loadItems(with: request, predicate: predicate)
        //        do {
        //            itemArray = try context.fetch(request)
        //        } catch {
        //            print(error)
        //        }
        //tableView.reloadData()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0 {
            loadItems()
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
        }
    }
}

// NSCoder
//class Item: Codable { //Encodable, Decodable {
//    var title: String = ""
//    var done: Bool = false
//}

