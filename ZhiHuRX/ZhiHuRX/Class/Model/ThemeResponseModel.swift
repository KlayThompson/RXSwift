//
//  ThemeResponseModel.swift
//  ZhiHuRX
//
//  Created by Kim on 2017/8/2.
//  Copyright © 2017年 Brain. All rights reserved.
//

import Foundation
import HandyJSON

struct ThemeResponseModel: HandyJSON {
    var others: [ThemeModel]?
}

struct ThemeModel: HandyJSON {
    var color: String?
    var thumbnail: String?
    var id: Int?
    var description: String?
    var name: String?
}
