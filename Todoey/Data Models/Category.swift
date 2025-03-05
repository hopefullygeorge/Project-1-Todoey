//
//  Category.swift
//  Todoey
//
//  Created by George Hope on 05/03/2025.
//  Copyright © 2025 App Brewery. All rights reserved.
//

import Foundation
import RealmSwift

class Category: Object {
    @objc dynamic var name: String = ""
    let items = List<Item>()
    
}
