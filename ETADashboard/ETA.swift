//
//  ETA.swift
//  ETADashboard
//
//  Created by Pak on 2017-04-14.
//  Copyright © 2017 pakwlau.com. All rights reserved.
//

import Foundation


struct NextBus {
    let route:String
    var ETA:Int
    
}

class NextBusDataSource {
    
    var data = [NextBus]()
    func receiveNewData(newNextBus:NextBus){
        var isSameRouteFound = false
        
        // search if this bus route exist
        for n in 0..<data.count {
            if data[n].route == newNextBus.route {
                // if this bus route exist
                data[n].ETA = newNextBus.ETA
                isSameRouteFound = true
            }
        }
        
        // if this bus route does not exist
        if !isSameRouteFound {
            data.append(newNextBus)
        }
        
        // sorting by ETA
        data.sort(by: { $0.ETA < $1.ETA})
        print (data)
    }
}

enum Location{
    case Home
    case IC
}

struct BusRide{
    let bound:Bound
    let route:String
    let startingPoint:Location
    
    func getBusStopCode() -> (code:String , seq:Int) {
        
        
        switch self.bound {
        case .toKLN:
            switch self.startingPoint {
            // go to kowloon, waiting at Home
            case .Home:
                switch self.route {
                case "52X":
                    return ("CA07-S-3300-2",9)
                case "61M":
                    return ("CA07-S-3300-2",12)
                case "53":
                    return ("CA07-S-3300-2",40)
                default:
                    break;
                }
            // go to kowloon, waiting at IC
            case .IC:
                switch self.route {
                case "61M":
                    return ("TU17-S-1100-0",0)
                case "52X","53":
                    return ("TU17-S-1150-0",0)
                default:
                    break;
                }
            }
            
        case .toTM:
            // go to tm, waiting at IC
            switch self.route {
            case "61M","52X","53":
                // this is back Home instead
                return ("TU17-N-1450-0",0)
            default:
                break;
            }
            
        }
        
        
        return ("",0)
    }
}


enum Bound:Int{
    case toTM = 2
    case toKLN = 1
    //case circular = 3
}
