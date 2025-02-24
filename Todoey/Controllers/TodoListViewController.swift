//
//  ViewController.swift
//  Todoey
//
//  Created by Philipp Muellauer on 02/12/2019.
//  Copyright © 2019 App Brewery. All rights reserved.
//

import UIKit
import CoreData

@available(iOS 16.0, *)
class TodoListViewController: UITableViewController {
    
    var itemArray = [Item]()
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // To find file path for app files ->
        // print(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask))
        
        
        loadItems()

    }
    
    //MARK: - TableView DataSource Methods
    
    // Return the number of rows for the table.
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemArray.count
    }
    
    
    // Provide a cell object for each row.
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Fetch a cell of the appropriate type.
        let cell = tableView.dequeueReusableCell(withIdentifier: "ToDoItemCell", for: indexPath)
        
        let item = itemArray[indexPath.row]
        
        // Configure the cell’s contents.
        cell.textLabel!.text = item.title
        
        //ternary opertator ==>
        // value = condition ? valueIfTrue : valueIfFalse
        
        cell.accessoryType = item.done ? .checkmark : .none
        
//        if item.done == true {
//            cell.accessoryType = .checkmark
//        } else {
//            cell.accessoryType = .none
//        }
        
        return cell
    }
    
    //MARK: - TableView Delegate Methods
    
    override func tableView(_ tableView: UITableView,didSelectRowAt indexPath: IndexPath) {
        // Lesson on how to delete items from database.
        //Important to note the order in which it is deleted.
        
//        context.delete(itemArray[indexPath.row])
//        itemArray.remove(at: indexPath.row)
        
        itemArray[indexPath.row].done = !itemArray[indexPath.row].done
        
        saveItems()
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    //MARK: - Add New Items
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        let alert = UIAlertController(title: "Add New Todoey Item", message: "", preferredStyle: .alert)
        
        alert.addTextField { alertTextField in
            alertTextField.placeholder = "Add your item here..."
        }
        
        let action = UIAlertAction(title: "Add Item", style: .default) { (action) in
            //What will happen when the user clicks the Add Item button on our UIAlert
            
            let newItem = Item(context: self.context)
            newItem.title = alert.textFields?.first?.text ?? "No Value"
            
            self.itemArray.append(newItem)
            self.saveItems()

            }
        
        alert.addAction(action)
        
        present(alert, animated: true, completion: nil)
    }
    
    //MARK: - Model Manipulation Methods
    
    func saveItems() {
        
        do {
            try context.save()
        } catch {
            print("Error saving data to database, \(error)")
        }
        
        tableView.reloadData()
    }
    
    // Pass in default if no input given
    func loadItems(with request : NSFetchRequest<Item> = Item.fetchRequest()) {
        
        do {
            itemArray = try context.fetch(request)
        } catch {
            print("Error fetching data from context, \(error)")
        }
        tableView.reloadData()
    }
}

//MARK: - Search Bar Delegate Methods

@available(iOS 16.0, *)
//Run viewcontroller when searchbar's state is changed.
extension TodoListViewController : UISearchBarDelegate {
    
//    When search button is clicked, ->
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        //  Define request to grab what is in the persistentContainer
        let request : NSFetchRequest<Item> = Item.fetchRequest()
        
        //  Use predicate to create a query, finding any title that contains text in searchbar
        request.predicate = NSPredicate(format: "title CONTAINS[cd] %@", searchBar.text!)
        
        //  Create a rule to organise data
        request.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
        
        //  Try to add fetched data to itemArray and display in table
        loadItems(with: request)

    }
    // Function to trigger when the text changes within the search bar
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        // If there are no characters in the search bar
        if searchBar.text?.count == 0 {
            // Diplay all items
            loadItems()
            // Use the dispatchque to grab the main thread and execute ->
            DispatchQueue.main.async {
                // Tell the search bar to stop being selected
                searchBar.resignFirstResponder()
            }
        } else {
            // This uses the same code for when the search button is pressed.
            let request : NSFetchRequest<Item> = Item.fetchRequest()
            
            request.predicate = NSPredicate(format: "title CONTAINS[cd] %@", searchBar.text!)

            request.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
            
            loadItems(with: request)
        }
    }
}
