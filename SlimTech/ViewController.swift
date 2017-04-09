//
//  ViewController.swift
//  SlimTech
//
//  Created by Dawsen Richins on 2/13/17.
//  Copyright © 2017 Droplet. All rights reserved.
//

import UIKit
import JBChart
import CoreData

class ViewController: UIViewController, JBBarChartViewDelegate, JBBarChartViewDataSource, JBLineChartViewDataSource, JBLineChartViewDelegate, NSFetchedResultsControllerDelegate {
    
    @IBOutlet weak var barChart: JBBarChartView!
    @IBOutlet weak var switchButton: UIButton!
    @IBOutlet weak var segmentButton: UISegmentedControl!
    @IBOutlet weak var lineChart: JBLineChartView!
    
    @IBOutlet weak var informationLabel: UILabel!
    
    @IBOutlet weak var xLabel: UILabel!
    @IBOutlet weak var yLabel: UILabel!
    
    @IBOutlet weak var batteryUse: UILabel!
    @IBOutlet weak var batteryUseRight: UILabel!
    @IBOutlet weak var screenTime: UILabel!
    @IBOutlet weak var screenTimeRight: UILabel!
    @IBOutlet weak var mainApplication: UILabel!
    @IBOutlet weak var mainApplicationRight: UILabel!
    
    var controller: NSFetchedResultsController<Data>!
    
    
    //TEST DATA
    
    @IBOutlet weak var counterLabel: UILabel!
    var backgroundTask: UIBackgroundTaskIdentifier = UIBackgroundTaskInvalid
    //for output testing purposes
    var countNum = 1
    
    //var yValues = [0.5,1.5,3.5,4.0,4.1,7.7,9.9,10,11,11,11,11,11,11,11,12.5,13,13.2,13.3,15,15.1,15.1,15.1,17.9]
    //var xValues = [1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24]
    var yValues = [1.2,2.4,3.2,7.2,9.6,9.5,10.3,18.2,18.3,18.5,18.6,18.7,18.9,18.9,19.0,19.1,19.5,20.6,21.0,22.2,22.3,23.0,23.9,23.9]
    var xValues = [1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24]
    var battery = [99,98,97,96,95,94,93,92,91,90,89,88,87,86,85,84,83,82,81,80,79,78,77,76]
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.black
        switchButton.isHidden = true
        switchButton.isEnabled = false
        

        //initiate obersver::  **this function monitor if the app moved to the background state
        NotificationCenter.default.addObserver(self, selector: #selector(detectBackground), name: Notification.Name.UIApplicationDidEnterBackground, object: nil)
        //bottom view of application setup
        //sets label variables to default values
        batteryUse.isHidden = true
        screenTime.isHidden = true
        mainApplication.isHidden = true
        
     //creation for the barChart and LineChart views
        
        
        barChart.backgroundColor = UIColor.gray
        barChart.delegate = self
        barChart.dataSource = self
        barChart.minimumValue = 0
        barChart.maximumValue = CGFloat(yValues.max()!)
        
        lineChart.isHidden = true
        lineChart.backgroundColor = UIColor.gray
        lineChart.delegate = self
        lineChart.dataSource = self
        lineChart.minimumValue = 0
        lineChart.maximumValue = CGFloat(yValues.max()!)
        
        barChart.reloadData()
        lineChart.reloadData()
        
        informationLabel.textColor = UIColor.clear
        informationLabel.text = " "
        
        barChart.setState(.collapsed, animated: false)
        lineChart.setState(.collapsed, animated: false)
        
        //mathematical work around for the y and x axis labels
        //TODO: fix resizing issue
        var xString = " "
        var yString = ""
        var step = 3
        var i = 0
        
        /*while(i<8){
            xString += "    \(step)    "
            step = step+3
            i = i+1
        }*/
        xString = "      3       6       9      12       3      6       9      12"
        
        xLabel.text = xString
        
        var max: Double = Double(yValues.max()!)
        var increment = (Double(max)/9.0).rounded()
        i = 9
        max = 8 * increment
        
        while(i>0){
            if(i==9){
                yString += "\(Int(max))\n\n"
                max = max-increment
            } else if(i==1){
                yString += "0"
            } else{
                yString += "\(Int(max))\n\n"
                max = max - increment
            }
            
            i-=1
        }
        yLabel.text = yString
        
        
        
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
      
        //adds labels to the graph at the moment of appearance on the screen
        
        let footer = UILabel(frame: CGRect(x: 0, y: barChart.frame.height + 3, width: barChart.frame.width, height: 20))
        
        
        
        let header = UILabel(frame: CGRect(x: 0, y: 0, width: barChart.frame.width, height: 25))
        header.textColor = UIColor.black
        header.font = UIFont.systemFont(ofSize: 24)
        //header.text = "Phone Usage"
        informationLabel.textColor = UIColor.white
        header.textAlignment = NSTextAlignment.center
        
        
        //barChart.footerView = footer
        barChart.headerView = header
       

    }
   
    
    
    @IBAction func switchButtonPressed(_ sender: Any) {
        //allows for the switching between views of line graph and bar graph
        
        if(barChart.isHidden == true){
            
            barChart.isHidden = false
            lineChart.isHidden = true
            
            barChart.footerView = lineChart.footerView
            barChart.headerView = lineChart.headerView
        }
        else{
            
            barChart.isHidden = true
            lineChart.isHidden = false
            
            lineChart.footerView = barChart.footerView
            lineChart.headerView = barChart.headerView
            
        }
    }
    
    @IBAction func segmentButtonPressed(_ sender: Any) {
        if(barChart.isHidden == true){
            
            barChart.isHidden = false
            lineChart.isHidden = true
            
            barChart.footerView = lineChart.footerView
            barChart.headerView = lineChart.headerView
        }
        else{
            
            barChart.isHidden = true
            lineChart.isHidden = false
            
            lineChart.footerView = barChart.footerView
            lineChart.headerView = barChart.headerView
            
        }

    }
  
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        //reloads data of the graph every time a switch between the graphs is made
        barChart.reloadData()
        lineChart.reloadData()
        
        var timer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: Selector("showChart"), userInfo: nil, repeats: false)
    }
    
    
    override func viewDidDisappear(_ animated: Bool) {
        //gets rid of the graph view with an animation every time new view is presented
        super.viewDidDisappear(animated)
        hideChart()
        
    }

    func hideChart(){
        barChart.setState(.collapsed, animated: true)
        lineChart.setState(.collapsed, animated: true)
        
        
    }
    
    
    func showChart(){
        barChart.setState(.expanded, animated: true)
        lineChart.setState(.expanded, animated: true)
        
    }
    
    //MARK: JBBarChartView
    
    func numberOfBars(in barChartView: JBBarChartView!) -> UInt {
        
        return UInt(yValues.count)
    }
    
    func barChartView(_ barChartView: JBBarChartView!, heightForBarViewAt index: UInt) -> CGFloat {
        //returning the height for each bar on the graph
        return CGFloat(yValues[Int(index)])
        
    }
    
    func barChartView(_ barChartView: JBBarChartView!, colorForBarViewAt index: UInt) -> UIColor! {
        //switches the color between each graph
        return (index % 2 == 0) ? UIColor.darkGray : UIColor.white
        
        
    }
    
    
    func barChartView(_ barChartView: JBBarChartView!, didSelectBarAt index: UInt, touch touchPoint: CGPoint) {
        //provides animation for the clicking mechanism on the graph
        //displays the data to the user for that time clicked
        var data = yValues[Int(index)]
        var key = xValues[Int(index)]
        
        var arrayKey = Int(index)
        if(arrayKey > 11){
            key = key - 12
        }
        var time = calculateTime(data: data)
        
        
        if(arrayKey < 11 || arrayKey == 23){
            informationLabel.text = "Usage at \(key) AM"
        }else {
            informationLabel.text = "Usage at \(key) PM"
        }
        screenTimeRight.text = time
        batteryUseRight.text = "\(battery[Int(index)])"
        batteryUse.isHidden = false
        screenTime.isHidden = false
        mainApplication.isHidden = false
        
    }
    
    func didDeselect(_ barChartView: JBBarChartView!) {
        //informationLabel.text = ""
    }
    
    func barSelectionColor(for barChartView: JBBarChartView!) -> UIColor! {
        return UIColor.black
    }
    func barPadding(for barChartView: JBBarChartView!) -> CGFloat {
        return CGFloat(2.0)
    }
    
    
    //MARK: JBLineChartView
    
    func numberOfLines(in lineChartView: JBLineChartView!) -> UInt {
        return 1
    }
    
    func lineChartView(_ lineChartView: JBLineChartView!, numberOfVerticalValuesAtLineIndex lineIndex: UInt) -> UInt {
        if (lineIndex == 0){
            return UInt(yValues.count)
        }
        
        return 0
    }
    
    func lineChartView(_ lineChartView: JBLineChartView!, verticalValueForHorizontalIndex horizontalIndex: UInt, atLineIndex lineIndex: UInt) -> CGFloat {
        if(lineIndex == 0) {
            return CGFloat(yValues[Int(horizontalIndex)])
        }
        
        return 0
    }
    
    func lineChartView(_ lineChartView: JBLineChartView!, colorForLineAtLineIndex lineIndex: UInt) -> UIColor! {
        if (lineIndex == 0){
            return UIColor.white
        }
        
        return UIColor.purple
    }
    
    func lineChartView(_ lineChartView: JBLineChartView!, showsDotsForLineAtLineIndex lineIndex: UInt) -> Bool {
        return true
    }
    
    func lineChartView(_ lineChartView: JBLineChartView!, selectionColorForDotAtHorizontalIndex horizontalIndex: UInt, atLineIndex lineIndex: UInt) -> UIColor! {
        return UIColor.black
    }
    
    func lineChartView(_ lineChartView: JBLineChartView!, smoothLineAtLineIndex lineIndex: UInt) -> Bool {
        return true
    }
    
    func lineChartView(_ lineChartView: JBLineChartView!, didSelectLineAt lineIndex: UInt, horizontalIndex: UInt) {
        if (lineIndex == 0){
            var data = yValues[Int(horizontalIndex)]
            var key = xValues[Int(horizontalIndex)]
            var arrayKey = Int(horizontalIndex)
            if(arrayKey > 11){
                key = key - 12
            }
            var time = calculateTime(data: data)
            screenTimeRight.text = time
            batteryUseRight.text = "\(battery[Int(horizontalIndex)])"


            if(arrayKey < 11 || arrayKey == 23){
                informationLabel.text = "Usage at \(key) AM"
            }else {
                informationLabel.text = "Usage at \(key) PM"
            }
        }
        batteryUse.isHidden = false
        screenTime.isHidden = false
        mainApplication.isHidden = false

    }
    
    func didDeselectLine(in lineChartView: JBLineChartView!) {
        //informationLabel.text = ""
    }
    
    func lineChartView(_ lineChartView: JBLineChartView!, dotRadiusForDotAtHorizontalIndex horizontalIndex: UInt, atLineIndex lineIndex: UInt) -> CGFloat {
        return CGFloat(8)
    }
    
    func calculateTime(data:Double) -> String{
        var time = ""
        var minutes = 0.0
        var value = data
        if(data != value.rounded()){
            minutes = data - value.rounded()
            minutes = 60*minutes
            if(minutes<0){
                minutes = minutes*(-1)
                minutes = 60 - minutes
            }
            time = "\(Int(data)) hrs, \(Int(minutes)) min"
        }else{
            time = "\(Int(data)) hrs"
        }
        
        
        return time
    }
   /* func lineChartView(_ lineChartView: JBLineChartView!, fillColorForLineAtLineIndex lineIndex: UInt) -> UIColor! {
        if (lineIndex == 0) {
            return UIColor.darkGray
        }
        else {
            return UIColor.white
        }
    }*/
    
    
    ////////////////////// Background functions ////////////////////////// 
    
    //remove observer
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func startBackgroundTask() {
        //.beginBackgroundTask start the long running task
        backgroundTask = UIApplication.shared.beginBackgroundTask { [weak self] in
            self?.endBackgroundTask()
        }
        assert(backgroundTask != UIBackgroundTaskInvalid)
    }
   
    func endBackgroundTask() {
        print("Background task ended.")
        //must call .endBackgroundTask or else app will be terminated
        UIApplication.shared.endBackgroundTask(backgroundTask)
        backgroundTask = UIBackgroundTaskInvalid
    }
    
    //count add function to output to the Counter label
    func getData() {
        
        //countNUm, total, results are for testing purposes
        var total = countNum
        countNum += 1
        let results = "\(total)"
       
        //showing results in the consel of what state the app is in
        switch UIApplication.shared.applicationState {
        case .active:
            print("App is foreground")
        //    counterLabel.text = results
        case .background:
            print("App is backgrounded. Next number = \(countNum)")
            print("Background time remaining = \(UIApplication.shared.backgroundTimeRemaining) seconds")
        case .inactive:
            print("App is inactive")
            break
        }
    }
    
    //when app enter the background state
    func detectBackground() {
        print("App is in background")
        startBackgroundTask()
        //Timer.scheduledTimer repeat a function at a certain interval for every 1 second
       Timer.scheduledTimer(timeInterval: 1, target: self,
                                           selector: #selector(getData), userInfo: nil, repeats: true)
        
    }
    

    //////////////*****   CORE DATA IMPLEMENTATION     *****///////////////////
    
    
    func attemptFetch(){
        
        let fetchRequest: NSFetchRequest<Data> = Data.fetchRequest()
       // let dateSort = NSSortDescriptor(key: "created", ascending: false)
       // fetchRequest.sortDescriptors = [dateSort]
        
        let controller = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
        
        do{
            try controller.performFetch()
        } catch {
            let error = error as NSError
            print("\(error)")
        }
        
        
    }
    
    
    
    
    
    
    
    
    
    
    
    
    

}

