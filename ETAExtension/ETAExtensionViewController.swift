//
//  TodayViewController.swift
//  ETAExtension
//
//  Created by Pak on 2017-04-15.
//  Copyright © 2017 pakwlau.com. All rights reserved.
//

import UIKit
import NotificationCenter
import Alamofire
import SwiftyJSON

class ETAExtensionViewController: UIViewController, NCWidgetProviding {
    
    @IBAction func refreshUI(_ sender: Any) {
        self.getAllBusRidesETAfromHometoIC()
    }
    @IBOutlet weak var firstBusRoute: UILabel!
    @IBOutlet weak var firstBusETA: UILabel!
    @IBOutlet weak var secondBusETA: UILabel!
    @IBOutlet weak var secondBusRoute: UILabel!
    @IBOutlet weak var thirdBusRoute: UILabel!
    @IBOutlet weak var thirdBusETA: UILabel!
    
    var nextBusDataSource = NextBusDataSource()
    
    lazy var labels:[(route:UILabel,ETA:UILabel)] = {
        return [ (self.firstBusRoute,self.firstBusETA),
                 (self.secondBusRoute,self.secondBusETA),
                 (self.thirdBusRoute,self.thirdBusETA) ]
    }()
    
    func updateExtensionUI(){
        let nextBusData = nextBusDataSource.data
        
        // Make sure there are enough labels for the data
        guard nextBusData.count <= labels.count
            else{
                return
        }
        
        // update labels text
        for n in 0..<nextBusData.count {
            labels[n].route.text = String(nextBusData[n].route)
            
            // process ETA
            let eta = nextBusData[n].ETA
            
            if eta > 0 {
                labels[n].ETA.text = String(nextBusData[n].ETA) + " 分鐘"
            }else if eta == 0{
                labels[n].ETA.text = "就到啦"
            }else if eta == -1{
                labels[n].ETA.text = "-"
            }
        }
    }
    
    func emptyLabels(){
        for label in self.labels {
            label.route.text = ""
            label.ETA.text = ""
        }
    }
    
//    override func viewDidLoad() {
//        print("viewDidLoad")
//        // Prepare UI
//        emptyLabels()
//       
//    }
    
    override func viewWillAppear(_ animated: Bool) {
        print("viewWillAppear")
        // Prepare UI
        emptyLabels()
        // from home to ic by 52X
        getAllBusRidesETAfromHometoIC()
    }
   
    
    func getAllBusRidesETAfromHometoIC(){
        let toKLNby52X = BusRide(bound: .toKLN, route: "52X", startingPoint: .Home)
        let toKLNby61M = BusRide(bound: .toKLN, route: "61M", startingPoint: .Home)
        let toKLNby53 = BusRide(bound: .toKLN, route: "53", startingPoint: .Home)
        
        getBusRideETA(busride: toKLNby52X)
        getBusRideETA(busride: toKLNby61M)
        getBusRideETA(busride: toKLNby53)
        
    }
    
    func getBusRideETA(busride:BusRide){
        KMBHelper.getETA(busride: busride){ nextBusInMinutes in
            
            let bus = NextBus(route: busride.route, ETA: nextBusInMinutes)
            self.nextBusDataSource.receiveNewData(newNextBus: bus)
            self.updateExtensionUI()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func widgetPerformUpdate(completionHandler: (@escaping (NCUpdateResult) -> Void)) {
        // Perform any setup necessary in order to update the view.
        
        // If an error is encountered, use NCUpdateResult.Failed
        // If there's no update required, use NCUpdateResult.NoData
        // If there's an update, use NCUpdateResult.NewData
        
        completionHandler(NCUpdateResult.newData)
    }
    
}
