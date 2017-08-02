//
//  APIManger.swift
//  ZhiHuRX
//
//  Created by Kim on 2017/8/2.
//  Copyright © 2017年 Brain. All rights reserved.
//

import Foundation
import Moya

enum APIManager {
    case getLaunchImage
    case getNewsList
    case getMoreNews(String)
    case getThemeList
    case getThemeDesc(Int)
    case getNewsDesc(Int)
}

extension APIManager: TargetType {
    //基本url
    var baseURL: URL {
        return URL(string: "http://news-at.zhihu.com/api/")!
    }
    //拼接在基本url后面
    var path: String {
    
        switch self {
        case .getLaunchImage:
            return "7/prefetch-launch-images/750*1142"
        case .getNewsList:
            return "4/news/latest"
        case .getMoreNews(let date):
            return "4/news/before/" + date
        case .getThemeList:
            return "4/themes"
        case .getThemeDesc(let id):
            return "4/theme/\(id)"
        case .getNewsDesc(let id):
            return "4/news/\(id)"
        }
    }
    
    //请求方式
    var method: Moya.Method {
        //可以根据不同的枚举类型来返回get或者post
        return .get
    }
//    请求参数
    var parameters: [String : Any]? {
    
        return nil
    }
    
    /// 参数编码方式
    var parameterEncoding: ParameterEncoding {
        return URLEncoding.default
    }
    
    /// Provides stub data for use in testing.
    var sampleData: Data {
        return "".data(using: String.Encoding.utf8)!
    }
    
    /// The type of HTTP task to be performed.
    var task: Task {
        return .request
    }
    
    /// Whether or not to perform Alamofire validation. Defaults to `false`.
    var validate: Bool {
        return false
    }
    
}
