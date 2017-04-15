//
//  KMBServer.swift
//  ETADashboard
//
//  Created by Pak on 2017-04-14.
//  Copyright © 2017 pakwlau.com. All rights reserved.
//

import Foundation

/// Fetch Data from KMB Server
struct KMBHelper{
    
    static func getETA(busride:BusRide, completion:@escaping (Int)->() ) {
        
        let route = busride.route
        let bound = busride.bound
        let busStop = busride.getBusStopCode()
        
        //http://search.kmb.hk/KMBWebSite/Function/FunctionRequest.ashx/?action=geteta&lang=1&route=52X&bound=1&servicetype=1&bsiCode=CA07S31000&seq=10
        var url = "http://search.kmb.hk/KMBWebSite/Function/FunctionRequest.ashx/?action=geteta&lang=1"
        
        url += "&route=" + route
        url += "&bound=" + "\(bound.rawValue)"
        url += "&bsiCode=" + busStop.code
        url += "&seq=" + "\(busStop.seq)"
        url += "&servicetype=1"
        
        NetworkHelper.getJson(url: url){ json in
            let nextBusArrival =  json["data"]["response"][0]["t"].stringValue
            let timeDifference = getTimeDifference(nextBusTime:nextBusArrival)
            completion(timeDifference)
        }
    }
    
    /// Expect 16:45 as nextBusTime
    static func getTimeDifference(nextBusTime:String) -> Int {
        
        if nextBusTime == "即將到達" ||  nextBusTime == "快將到達"{
            return 0
        }
        var differenceInMinutes:Int = -1
        let nextBusTimeComponents = nextBusTime.components(separatedBy: ":")
        guard (nextBusTimeComponents.count == 2)
            else{
                print("Error in separating the next bus time conponents")
            return -1
        }
        
        let nextBusHour = nextBusTimeComponents.first
        let nextBusMinutes = nextBusTimeComponents.last
        
        // process the time difference
        let currentDate = Date()
        let calendar = Calendar.current
        let currentHour = calendar.component(.hour, from: currentDate)
        let currentMinutes = calendar.component(.minute, from: currentDate)
        
        if let nbh = nextBusHour, let nbm = nextBusMinutes {
             differenceInMinutes = ( Int(nbh)! - currentHour )*60 + Int(nbm)! - currentMinutes
        }
        return differenceInMinutes
    }
   
}
