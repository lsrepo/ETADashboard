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
import CoreLocation

class ETAExtensionViewController: UIViewController, NCWidgetProviding, CLLocationManagerDelegate {
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print(locations)
    }
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        
    }
    
    @IBAction func refreshUI(_ sender: Any) {
        self.runMainTask()
    }
    
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    @IBOutlet weak var dashboardTitle: UILabel!
    @IBOutlet weak var firstBusRoute: UILabel!
    @IBOutlet weak var firstBusETA: UILabel!
    @IBOutlet weak var secondBusETA: UILabel!
    @IBOutlet weak var secondBusRoute: UILabel!
    @IBOutlet weak var thirdBusRoute: UILabel!
    @IBOutlet weak var thirdBusETA: UILabel!

    var nextBusDataSource = NextBusDataSource()
    var locationManager = CLLocationManager()
    
    
    lazy var labels:[(route:UILabel,ETA:UILabel)] = {
        return [ (self.firstBusRoute,self.firstBusETA),
                 (self.secondBusRoute,self.secondBusETA),
                 (self.thirdBusRoute,self.thirdBusETA) ]
    }()
    
    func runMainTask(){
        
        // Prepare UI
        emptyLabels()
        loadingIndicator.alpha = 1
        loadingIndicator.startAnimating()
        
        // Prepare Location Detection
        let home = CLLocation(latitude: 22.37186363, longitude: 113.99397489)
        locationManager.startUpdatingLocation()
        
        
        // Location Deteaction
        if let location = locationManager.location {
            // Within 1 km
            if location.distance(from: home) < 1000 {
                print("You're close to home")
                self.getAllBusRidesETAfromHometoIC()
                
                // set dashBoard title
                dashboardTitle.text = "屋企去中轉站"
            }else{
                print("You're close to work")
                self.getAllBusRidesETAfromWorktoIC()
                
                // set dashBoard title
                dashboardTitle.text = "觀塘去中轉站"
            }
        }
        locationManager.stopUpdatingLocation()
        
    }
    
    func updateExtensionUI(){
        // Hide indicator
        loadingIndicator.alpha = 0
        loadingIndicator.stopAnimating()
        
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
    

    
    override func viewWillAppear(_ animated: Bool) {
        print("viewWillAppear")
        // Prepare UI
       
        // from home to ic by 52X
        runMainTask()
    }
    
    override func viewDidLoad() {
       setUpLocationManager()
        print("viewDidLoad")
    }
    
    func setUpLocationManager(){
        locationManager.delegate = self
        
        if CLLocationManager.authorizationStatus() == .notDetermined {
            self.locationManager.requestWhenInUseAuthorization()
        }
        
        locationManager.distanceFilter = kCLDistanceFilterNone
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    func segmentedControlTapped(sender:UISegmentedControl){
        print(sender)
    }
    func getAllBusRidesETAfromHometoIC(){
        
        let toKLNby52X = BusRide(bound: .toKLN, route: "52X", startingPoint: .Home)
        let toKLNby61M = BusRide(bound: .toKLN, route: "61M", startingPoint: .Home)
        let toKLNby53 = BusRide(bound: .toKLN, route: "53", startingPoint: .Home)
        
        getBusRideETA(busride: toKLNby52X)
        getBusRideETA(busride: toKLNby61M)
        getBusRideETA(busride: toKLNby53)
        
        let routes = [toKLNby52X,toKLNby61M,toKLNby53]
        for route in routes{
            getBusRideETA(busride: route)
        }
        
    }
    
    func getAllBusRidesETAfromWorktoIC(){
        let toTMby259D = BusRide(bound: .toTM , route: "259D", startingPoint: .Work)
        let toTMby61M = BusRide(bound: .toTM, route: "258D", startingPoint: .Work)
        let toTMby53 = BusRide(bound: .toTM, route: "62X", startingPoint: .Work)
        
        let routes = [toTMby259D,toTMby61M,toTMby53]
        for route in routes{
            getBusRideETA(busride: route)
        }
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
