//
//  DefViewController.swift
//  uasmms
//
//  Created by Calvin Antonius on 18/02/21.
//

import UIKit

class DefViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    var word: String? = ""
    var Definitions: [Definition] = []
    let urlString = "https://owlbot.info/api/v4/dictionary/"
    
    @IBOutlet weak var defTV: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()

        defTV.register(CustomTableViewCell.nib(), forCellReuseIdentifier: CustomTableViewCell.identifer)
        defTV.dataSource = self
        defTV.delegate = self
        print(word)
        callApi(aa: word!)
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
//            customCell.configure(with: "Type", desc: "Def", imageName: nil)
        }
        else {
            customCell.configure(with: "Type", desc: "Def", imageName: nil)
        }
        return customCell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 140
    }
    
    func callApi(aa: String) {
        guard let url = URL(string: urlString) else {
            return
        }
        self.Definitions.removeAll()
        var urlReq = URLRequest(url: URL(string: "\(url)\(aa)")!)
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
                print("error API")
            }
            DispatchQueue.main.async {
                self.defTV.reloadData()
            }
        }
        task.resume();
    }
     

}
