//
//  ViewController.swift
//  uasmms
//
//  Created by Calvin Antonius on 16/02/21.
//

import UIKit
import CoreData


struct APIResponse: Codable {
    var pronunciation: String?
    var word: String?
    let definitions: [Definition]
}

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {

    @IBOutlet var table: UITableView!
    @IBOutlet var searchBar: UISearchBar!
    @IBOutlet weak var favSwitch: UISwitch!
    let words = ["Cat", "Dog", "Fox", "Shark", "Phoenix", "Dragon", "Duck", "Tiger", "Psychopath", "Demon", "Angel"]
    let urlString = "https://owlbot.info/api/v4/dictionary/"
    var Definitions: [Definition] = []
    var word: String! = ""
    
    var indexedWords: [String] = []
    
    @IBAction func favSwitchAction(_ sender: Any) {
        if favSwitch.isOn {
            createItem()
        } else {
            deleteItem()
        }
        getAllItems()
    }
    @IBAction func randomBtn(_ sender: Any) {
        word = words[Int.random(in: 0..<words.count)]
        print(word)
        callApi(word: word)
        searchBar.text = word
        if indexedWords.contains(word.lowercased()) {
            favSwitch.setOn(true, animated: true)
        } else {
            favSwitch.setOn(false, animated: true)
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        table.register(CustomTableViewCell.nib(), forCellReuseIdentifier: CustomTableViewCell.identifer)
        table.delegate = self
        table.dataSource = self
        searchBar.delegate = self
        getAllItems()
        word = words[Int.random(in: 0..<words.count)]
        callApi(word: word)
        searchBar.text = word
        if indexedWords.contains(word.lowercased()) {
            favSwitch.setOn(true, animated: true)
        } else {
            favSwitch.setOn(false, animated: true)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
//        let alertController = UIAlertController(title: "Alert 1", message: " \(Int.random(in: 0..<words.count))", preferredStyle: .alert)
//        alertController.addAction(UIAlertAction(title: "Dismiss", style: .default))
//        self.present(alertController, animated: true, completion: nil)
    }
    
    func callApi(word: String) {
        guard let url = URL(string: urlString) else {
            return
        }
        self.Definitions.removeAll()
        var urlReq = URLRequest(url: URL(string: "\(url)\(word)")!)
        urlReq.allHTTPHeaderFields = ["Authorization": "Token 93eefdf64a963c2b970768dfc1b897f4bf8e7a9d"]
        let task = URLSession.shared.dataTask(with: urlReq) { (data, _, error) in
            guard let data = data, error == nil else {
                return
            }
            do {
                let result = try JSONDecoder().decode(APIResponse.self, from: data)
                self.Definitions = result.definitions
                
            }
            catch {
                print(error)
            }
            DispatchQueue.main.async {
                self.table.reloadData()
            }
        }
        task.resume();
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Definitions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let customCell = tableView.dequeueReusableCell(withIdentifier: CustomTableViewCell.identifer, for: indexPath) as! CustomTableViewCell
//        customCell.descLabel.numberOfLines = 0
        
        if (Definitions.count > 0){
            let def: Definition = Definitions[indexPath.row]
            customCell.configure(with: def.type!, desc: def.definition!, imageName: def.image_url)
        }
        else {
            customCell.configure(with: "Type", desc: "Def", imageName: "gear")
        }
        
        
        return customCell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 140
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        word = searchBar.text! as String
        if (word.count < 3) {
            makeAlert(title: "Error", message: "You have to input at least 3 characters", button: "OK :(")
            Definitions.removeAll()
            table.reloadData()
            return
        }
        callApi(word: word)
        if indexedWords.contains(word.lowercased()) {
            favSwitch.setOn(true, animated: true)
        } else {
            favSwitch.setOn(false, animated: true)
        }
    }
    
    func makeAlert(title: String, message: String, button: String){
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let close = UIAlertAction(title: button, style: .cancel, handler: nil)
        alert.addAction(close)
        
        present(alert, animated: true, completion: nil)
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
    }
    
    func createItem() {
        
        if indexedWords.contains(word) {
            makeAlert(title: "Error", message: "Already Inside Core Data", button: "Ok")
            return
        }
        
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let entity = NSEntityDescription.entity(forEntityName: "Words", in: context)
        let newItem = NSManagedObject(entity: entity!, insertInto: context)
        
        newItem.setValue(self.word.lowercased() as String, forKey: "word")
        newItem.setValue("yes", forKey: "definition")
        
        do {
            try context.save()
            print("Saved")
        }
        catch {
            print("Failed Saving")
        }
    }
    
    func deleteItem() {
        if !indexedWords.contains(word.lowercased()) {
            return
        }
        
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
    
    @IBAction func unwindToHome(_ sender: UIStoryboardSegue) {
        
    }
}

