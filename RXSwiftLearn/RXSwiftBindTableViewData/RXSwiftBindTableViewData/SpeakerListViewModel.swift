//
//  SpeakerListViewModel.swift
//  RXSwiftBindTableViewData
//
//  Created by Kim on 2017/7/26.
//  Copyright © 2017年 Brain. All rights reserved.
//

import Foundation
import RxSwift

//struct SpeakerListViewModel {
//    
//    let data = [
//        Speaker(name: "Ben Sandofsky", twitterHandle: "@sandofsky"),
//        Speaker(name: "Carla White", twitterHandle: "@carlawhite"),
//        Speaker(name: "Jaimee Newberry", twitterHandle: "@jaimeejaimee"),
//        Speaker(name: "Natasha Murashev", twitterHandle: "@natashatherobot"),
//        Speaker(name: "Robi Ganguly", twitterHandle: "@rganguly"),
//        Speaker(name: "Virginia Roberts",  twitterHandle: "@askvirginia"),
//        Speaker(name: "Scott Gardner", twitterHandle: "@scotteg")
//    ]
//}
struct SpeakerListViewModel {
    let data = Observable.just([
        Speaker(name: "Ben Sandofsky", twitterHandle: "@sandofsky"),
        Speaker(name: "Carla White", twitterHandle: "@carlawhite"),
        Speaker(name: "Jaimee Newberry", twitterHandle: "@jaimeejaimee"),
        Speaker(name: "Natasha Murashev", twitterHandle: "@natashatherobot"),
        Speaker(name: "Robi Ganguly", twitterHandle: "@rganguly"),
        Speaker(name: "Virginia Roberts",  twitterHandle: "@askvirginia"),
        Speaker(name: "Scott Gardner", twitterHandle: "@scotteg")
        ])
    let ss = Observable.just(22).subscribe {
        print("22")
    }
    
}
