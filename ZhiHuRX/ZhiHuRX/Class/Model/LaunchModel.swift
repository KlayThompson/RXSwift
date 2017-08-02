//
//  LaunchModel.swift
//  ZhiHuRX
//
//  Created by Kim on 2017/8/2.
//  Copyright © 2017年 Brain. All rights reserved.
//

import Foundation
import HandyJSON

struct LaunchModel:HandyJSON {
    var creatives: [LaunchModelImg]?
}

struct LaunchModelImg: HandyJSON {
    var url: String?
    var text: String?
    var start_time : Int?
    var impression_tracks: [String]?
}
