//
//  NewsDetailModel.swift
//  ZhiHuRX
//
//  Created by Kim on 2017/8/3.
//  Copyright © 2017年 Brain. All rights reserved.
//

import Foundation
import HandyJSON

struct NewsDetailModel: HandyJSON {
    var body: String?
    var ga_prefix: String?
    var id: Int?
    var image: String?
    var image_source: String?
    var share_url: String?
    var title: String?
    var type: Int?
    var images: [String]?
    var css: [String]?
    var js: [String]?
}
