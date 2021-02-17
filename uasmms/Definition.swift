//
//  Definition.swift
//  uasmms
//
//  Created by Calvin Antonius on 18/02/21.
//

import Foundation
class Definition: Codable {
    var type: String?
    var definition: String?
    var image_url: String?
    
    init(type: String, definition: String, image_url: String) {
        self.type = type
        self.definition = definition
        self.image_url = image_url
    }
}
