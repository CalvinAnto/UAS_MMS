//
//  FavViewController.swift
//  uasmms
//
//  Created by Calvin Antonius on 18/02/21.
//

import UIKit
import CoreData

class FavViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    var indexedWords: [String] = []
    
    @IBOutlet weak var favTV: UITableView!
    
    @IBOutlet weak var noLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getAllItems()
        if indexedWords.isEmpty {
            favTV.isHidden = true
        } else {
            noLabel.isHidden = true
        }
        
        favTV.delegate = self
        favTV.dataSource = self
    }
    
    func getAllItems() {
        indexedWords.removeAll()
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Words")
        var result = [NSManagedObject]()
        do {
            result = try context.fetch(request) as! [NSManagedObject]
        } catch {
            print("Failed Getting Items")
        }
        for data in result {
            self.indexedWords.append(data.value(forKeyPath: "word") as! String)
        }
        
        if indexedWords.isEmpty {
            favTV.isHidden = true
            noLabel.isHidden = false
        } else {
            noLabel.isHidden = true
            favTV.isHidden = false
        }
    }
    
    func deleteItem(row: Int) {
        let word = indexedWords[row]
        
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Words")
        var result = [NSManagedObject]()
        do {
            result = try context.fetch(request) as! [NSManagedObject]
        } catch {
            print("Failed Getting Items")
        }
        for data in result {
            if data.value(forKeyPath: "word") as! String == word.lowercased() {
                context.delete(data)
            }
        }
        
        do {
            try context.save()
            print("Deleted")
        }
        catch {
            print("Failed Deleting")
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = indexedWords[indexPath.row]
        
        let mSwitch = UISwitch()
        mSwitch.addTarget(self, action: #selector(didChangeSwitch(_:)), for: .valueChanged)
        mSwitch.isOn = true
        mSwitch.tag = indexPath.row
        cell.accessoryView = mSwitch
        
        return cell
    }
    
    @objc func didChangeSwitch(_ sender: UISwitch) {
        if sender.isOn {
            print("it's on")
        } else {
            deleteItem(row: sender.tag)
            getAllItems()
            favTV.reloadData()
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return indexedWords.count
    }

}
