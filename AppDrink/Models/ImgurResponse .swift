//
//  ImgurResponse .swift
//  DrinkApp
//
//  Created by 陳秉軒 on 2022/5/16.
//

import Foundation


struct ImgurImageResponse:Codable{
    let data:Data
    struct Data:Codable{
        let link:URL
    }
}
