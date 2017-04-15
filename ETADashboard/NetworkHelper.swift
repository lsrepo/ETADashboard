//
//  NetworkHelper.swift
//  ETADashboard
//
//  Created by Pak on 2017-04-14.
//  Copyright © 2017 pakwlau.com. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

struct NetworkHelper{
    
    static func getJson(url:String, completion: @escaping (JSON)->() ) {
        
        Alamofire.request(url).responseData { response in
            debugPrint(response)
            
            if let data = response.result.value {
                let json = JSON(data: data)
                completion(json)
            }
        }
    }
}














//        let test = "bad"
//        
//        let requestUrl = URL(string: url)
//        let task = URLSession.shared.dataTask(with: requestUrl! ) { data, response, error in
//            guard error == nil else {
//                print(error!)
//                return
//            }
//            
//            guard let data = data else {
//                print("Data is empty")
//                return
//            }
//            
//           let json = try! JSONSerialization.jsonObject(with: data, options: [])
//            print("Got Data")
//            let test = "nice"
//        }

        

