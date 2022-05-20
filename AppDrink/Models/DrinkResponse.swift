//
//  DrinkResponse.swift
//  DrinkApp
//
//  Created by 陳秉軒 on 2022/5/5.
//

import Foundation

//定義飲料menu AirTable Get 回傳型別
struct DrinkMenu:Codable{
    let records:[Records]
    
    struct Records:Codable{
        let id:String
        let fields:Fields
        
        struct Fields:Codable{
            let imageUrl:URL
            let iceOnly:String
            let name:String
            let price: Int
            let mikeCapPrice:Int?
            let number:Int
        }
    }
}

//定義order資料 AirTable Get＆Post 上傳、回傳型別
struct DrinkOrder:Codable{
    var records:[Records]
    
    struct Records:Codable{
        var id:String?
        var fields:Fields
        
        struct Fields:Codable{
            var orderName:String
            var drinkName:String
            var mikeCap:String
            var drinkSuger:String
            var drinkIce:String
            var add:String?
            var total:Int
            var cups:Int
            var pic:URL?
        }
    }
}

//暫存order資料自定義型別
class dataForOrderPost{
    static var orderName = ""
    static var drinkName = ""
    static var mikeCap = ""
    static var drinkSuger = ""
    static var drinkIce = ""
    static var add = [String]()
    static var total = 0
    static var cups = 0
    
    class func clearAll(){
        
        drinkName = ""
        mikeCap = ""
        drinkSuger = ""
        drinkIce = ""
        add = [String]()
        total = 0
        cups = 0
    }
}
