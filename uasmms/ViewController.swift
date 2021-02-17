//
//  ViewController.swift
//  uasmms
//
//  Created by Calvin Antonius on 16/02/21.
//

import UIKit

struct APIResponse: Codable {
    let pronunciation: String?
    let word: String?
    let definitions: [Definition]
}

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {

    @IBOutlet var table: UITableView!
    @IBOutlet var searchBar: UISearchBar!
    let words = ["Cat", "Dog", "Fox", "Shark", "Pheonix", "Dragon", "Duck", "Tiger", "Psychopath", "Demon", "Angel"]
    let urlString = "https://owlbot.info/api/v4/dictionary/"
    var Definitions: [Definition] = []
    
    @IBAction func randomBtn(_ sender: Any) {
        var word = words[Int.random(in: 0..<words.count)]
        print(word)
        callApi(word: word)
        searchBar.text = word
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        table.register(CustomTableViewCell.nib(), forCellReuseIdentifier: CustomTableViewCell.identifer)
        table.delegate = self
        table.dataSource = self
        searchBar.delegate = self
//        print(Int.random(in: 0..<words.count))
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
//                self.table.reloadData()
                
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
        let word = searchBar.text! as String
        if (word.count < 3) {
            makeAlert(title: "Error", message: "You have to input at least 3 characters", button: "OK :(")
            Definitions.removeAll()
            table.reloadData()
            return
        }
        callApi(word: word)
    }
    
    func makeAlert(title: String, message: String, button: String){
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            let close = UIAlertAction(title: button, style: .cancel, handler: nil)
            alert.addAction(close)
            
            present(alert, animated: true, completion: nil)
        }

}

