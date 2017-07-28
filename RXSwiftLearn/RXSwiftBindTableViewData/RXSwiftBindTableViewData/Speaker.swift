//
//  Speaker.swift
//  RXSwiftBindTableViewData
//
//  Created by Kim on 2017/7/26.
//  Copyright © 2017年 Brain. All rights reserved.
//

import Foundation
import UIKit

struct Speaker {
  
    
    let name: String
    let twitterHandle: String
    let image: UIImage?
    
    init(name: String, twitterHandle: String) {
        self.name = name
        self.twitterHandle = twitterHandle
        image = UIImage(named: name.replacingOccurrences(of: "", with: ""))
    }
}

extension Speaker: CustomStringConvertible {

    var description: String {
        return "\(name) \(twitterHandle)"
    }
}
