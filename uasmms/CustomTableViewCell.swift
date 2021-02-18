//
//  CustomTableViewCell.swift
//  uasmms
//
//  Created by Calvin Antonius on 18/02/21.
//

import UIKit
class CustomTableViewCell: UITableViewCell {

    static let identifer = "CustomTableViewCell"
    static func nib() -> UINib{
        return UINib(nibName: "CustomTableViewCell", bundle: nil)
    }
    
    public func configure(with type: String, desc: String, imageName: String?) {
        typeLabel.text = type
        descLabel.text = desc
        if (imageName == nil) {
            myImageView.image = UIImage(systemName: "gear")
        }
        else {
            let url = URL(string: imageName!)!
            
            if let data = try? Data(contentsOf: url) {
                myImageView!.image = UIImage(data: data)
            }
        }
        descLabel.lineBreakMode = NSLineBreakMode.byWordWrapping
        descLabel.numberOfLines = 0
    }
    
    @IBOutlet var myImageView: UIImageView!
    @IBOutlet var typeLabel: UILabel!
    @IBOutlet var descLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        
    }
    
}
