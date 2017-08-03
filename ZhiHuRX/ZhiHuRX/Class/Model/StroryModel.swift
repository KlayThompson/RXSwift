//
//  StroryModel.swift
//  ZhiHuRX
//
//  Created by Kim on 2017/8/3.
//  Copyright © 2017年 Brain. All rights reserved.
//

import Foundation
import HandyJSON

struct ListModel: HandyJSON {
    var date: String?
    var stories: [StoryModel]?
    var top_stories: [StoryModel]?
}

struct StoryModel: HandyJSON {
    var ga_prefix: String?
    var id: Int?
    var images: [String]? //list_stories
    var title: String?
    var type: Int?
    var image: String? //top_stories
    var multipic = false
}
