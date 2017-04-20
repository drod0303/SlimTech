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
    
    //for background testing
    @IBOutlet weak var counterLabel: UILabel!
    var backgroundTask: UIBackgroundTaskIdentifier = UIBackgroundTaskInvalid
    var countNum = 1
    //end testing
    
    //test graph values
    
 
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.black
        switchButton.isHidden = true
        switchButton.isEnabled = false
        generateTestData()
        attemptFetch()
        
        //for background testing
        //this function monitor if the app moved to the background state
        NotificationCenter.default.addObserver(self, selector: #selector(detectBackground), name: Notification.Name.UIApplicationDidEnterBackground, object: nil)
        //end testing
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
        barChart.maximumValue = CGFloat(screenTimeValues.max()!)
        
        lineChart.isHidden = true
        lineChart.backgroundColor = UIColor.gray
        lineChart.delegate = self
        lineChart.dataSource = self
        lineChart.minimumValue = 0
        lineChart.maximumValue = CGFloat(screenTimeValues.max()!)
        
        barChart.reloadData()
        lineChart.reloadData()
        
        informationLabel.textColor = UIColor.clear
        informationLabel.text = " "
        
        barChart.setState(.collapsed, animated: false)
        lineChart.setState(.collapsed, animated: false)
        
        //mathematical work around for the y and x axis labels
        var xString = " "
        var yString = ""
        var i = 0
        
        xString = "      3       6       9      12       3      6       9      12"
        
        xLabel.text = xString
        
        var max: Double = Double(screenTimeValues.max()!)
        let increment = (Double(max)/9.0)
        i = 9
        max = max.rounded()
        
        while(i>0){
            if(i==9){
                max = Double(round(10*max)/10)
                yString += "\(max)\n\n"
                max = max-increment
            } else if(i==1){
                yString += "0"
            } else{
                max = Double(round(10*max)/10)
                yString += "\(max)\n\n"
                max = max - increment
            }
            
            i-=1
        }
        yLabel.text = yString
        
        
        
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
      
        //adds labels to the graph at the moment of appearance on the screen
        
        
        
        let header = UILabel(frame: CGRect(x: 0, y: 0, width: barChart.frame.width, height: 25))
        header.textColor = UIColor.black
        header.font = UIFont.systemFont(ofSize: 24)
        informationLabel.textColor = UIColor.white
        header.textAlignment = NSTextAlignment.center
        
        barChart.headerView = header
       

    }
   
    
    
    @IBAction func switchButtonPressed(_ sender: Any) {
        //allows for the switching between views of line graph and bar graph
        //also updates corresponding labels for each view when it appears
        
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
    
    //Depedning on switch button implemented this function will
    //also switch between the two graph views
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
  
    
    //reloads data of the graph every time a switch between the graphs is made
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        barChart.reloadData()
        lineChart.reloadData()
        
        var timer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(ViewController.showChart), userInfo: nil, repeats: false)
    }
    
    
    //gets rid of the graph view with an animation every time new view is presented
    override func viewDidDisappear(_ animated: Bool) {
        
        super.viewDidDisappear(animated)
        hideChart()
        
    }
    //necessary function calls for the JBChart Library graphs to work properly
    func hideChart(){
        barChart.setState(.collapsed, animated: true)
        lineChart.setState(.collapsed, animated: true)
        
    }
    
    //necessary function calls for the JBChart Library graphs to work properly
    func showChart(){
        barChart.setState(.expanded, animated: true)
        lineChart.setState(.expanded, animated: true)
        
    }
    
    //MARK: JBBarChartView
    
    //returns the number of bars necessary to represent the data given to the chart
    func numberOfBars(in barChartView: JBBarChartView!) -> UInt {
        
        return UInt(screenTimeValues.count)
    }
    
    //returns the value of the maximum height needed to represent the data given to the chart
    func barChartView(_ barChartView: JBBarChartView!, heightForBarViewAt index: UInt) -> CGFloat {
        //returning the height for each bar on the graph
        return CGFloat(screenTimeValues[Int(index)])
        
    }
    
    //switches the color between each graph
    func barChartView(_ barChartView: JBBarChartView!, colorForBarViewAt index: UInt) -> UIColor! {
        
        return (index % 2 == 0) ? UIColor.darkGray : UIColor.white
        
        
    }
    
    //provides animation for the clicking mechanism on the graph
    //displays the data to the user for that time clicked
    func barChartView(_ barChartView: JBBarChartView!, didSelectBarAt index: UInt, touch touchPoint: CGPoint) {
      
        let data = screenTimeValues[Int(index)]
        let key = timeOfDay[Int(index)]
        
        let arrayKey = Int(index)
        let time = calculateTime(data: Double(data))
        
        
        if(arrayKey < 11 || arrayKey == 23){
            informationLabel.text = "Usage at \(key) AM"
        }else {
            informationLabel.text = "Usage at \(key) PM"
        }
        screenTimeRight.text = time
        batteryUseRight.text = "\(battery[Int(index)])%"
        batteryUse.isHidden = false
        screenTime.isHidden = false
        
    }
    
    
    //this function allows for code action upon user diselection of an item
    func didDeselect(_ barChartView: JBBarChartView!) {
        
    }
    
    //if a bar is selected by the user then a black highlight will surround it
    func barSelectionColor(for barChartView: JBBarChartView!) -> UIColor! {
        return UIColor.black
    }
    
    //pads the amount of space between each value on the chart
    func barPadding(for barChartView: JBBarChartView!) -> CGFloat {
        return CGFloat(2.0)
    }
    
    
    //MARK: JBLineChartView
    
    //can have up to multiple lines in line chart view
    //however for our finished project we shall only have one depicting the data
    func numberOfLines(in lineChartView: JBLineChartView!) -> UInt {
        return 1
    }
    
    //returns value of highest value given to line chart
    func lineChartView(_ lineChartView: JBLineChartView!, numberOfVerticalValuesAtLineIndex lineIndex: UInt) -> UInt {
        if (lineIndex == 0){
            return UInt(screenTimeValues.count)
        }
        
        return 0
    }
    
    //returns value for the x axis at which the user clicks
    func lineChartView(_ lineChartView: JBLineChartView!, verticalValueForHorizontalIndex horizontalIndex: UInt, atLineIndex lineIndex: UInt) -> CGFloat {
        if(lineIndex == 0) {
            return CGFloat(screenTimeValues[Int(horizontalIndex)])
        }
        
        return 0
    }
    
    //returns the color for the line
    //can support multiple line coloring
    func lineChartView(_ lineChartView: JBLineChartView!, colorForLineAtLineIndex lineIndex: UInt) -> UIColor! {
        if (lineIndex == 0){
            return UIColor.white
        }
        
        return UIColor.purple
    }
    
    // allows values to be represented by a dot instead of just a line alone
    func lineChartView(_ lineChartView: JBLineChartView!, showsDotsForLineAtLineIndex lineIndex: UInt) -> Bool {
        return true
    }
    
    //returns the color for the highlight at the selected index
    func lineChartView(_ lineChartView: JBLineChartView!, selectionColorForDotAtHorizontalIndex horizontalIndex: UInt, atLineIndex lineIndex: UInt) -> UIColor! {
        return UIColor.black
    }
    
    //makes the line smoother as opposed to a rough and jagged connection of dots
    func lineChartView(_ lineChartView: JBLineChartView!, smoothLineAtLineIndex lineIndex: UInt) -> Bool {
        return true
    }
    
    //creates the white highlight below the line graph curve
    func lineChartView(_ lineChartView: JBLineChartView!, fillColorForLineAtLineIndex lineIndex: UInt) -> UIColor! {
        return UIColor.white
    }
    
    //allows for update of the lower view upon selection in the line chart
    func lineChartView(_ lineChartView: JBLineChartView!, didSelectLineAt lineIndex: UInt, horizontalIndex: UInt) {
        if (lineIndex == 0){
            let data = screenTimeValues[Int(horizontalIndex)]
            let key = timeOfDay[Int(horizontalIndex)]
            let arrayKey = Int(horizontalIndex)
            if(arrayKey > 11){
               // key = key - 12
            }
            let time = calculateTime(data: Double(data))
            screenTimeRight.text = time
            batteryUseRight.text = "\(battery[Int(horizontalIndex)])%"


            if(arrayKey < 11 || arrayKey == 23){
                informationLabel.text = "Usage at \(key) AM"
            }else {
                informationLabel.text = "Usage at \(key) PM"
            }
        }
        batteryUse.isHidden = false
        screenTime.isHidden = false
       // mainApplication.isHidden = false

    }
    
    //if the user deselects the chart then you could update certain values here
    func didDeselectLine(in lineChartView: JBLineChartView!) {
        //informationLabel.text = ""
    }
    
    //returns the size for the dots at each value on the line graph
    func lineChartView(_ lineChartView: JBLineChartView!, dotRadiusForDotAtHorizontalIndex horizontalIndex: UInt, atLineIndex lineIndex: UInt) -> CGFloat {
        return CGFloat(8)
    }
    
    func calculateTime(data:Double) -> String{
        var time = ""
        var minutes = 0.0
        let value = data
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
    
    
    //for background testing
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func registerBackgroundTask() {
        //.beginBackgroundTask start the long running task
        backgroundTask = UIApplication.shared.beginBackgroundTask { [weak self] in
            self?.endBackgroundTask()
        }
        assert(backgroundTask != UIBackgroundTaskInvalid)
    }
    
    //when start button is no longer highlighted
    func endBackgroundTask() {
        print("Background task ended.")
        //must call .endBackgroundTask or else app will be terminated
        UIApplication.shared.endBackgroundTask(backgroundTask)
        backgroundTask = UIBackgroundTaskInvalid
    }
    
   
    
    //count add function to output to the Counter label
    func addOne() {
        
        countNum += 1
      
        
        
        //showing results in the consel of what state the app is in
        switch UIApplication.shared.applicationState {
        case .active: break
            //print("App is foreground")
        //    counterLabel.text = results
        case .background:
            print("App is backgrounded. Next number = \(countNum)")
            print("Background time remaining = \(UIApplication.shared.backgroundTimeRemaining) seconds")
            break
        case .inactive:
            print("App is inactive")
            break
        }
    }
    
    //when app enter the background state
    func detectBackground() {
        print("App is in background")
        registerBackgroundTask()
        //Timer.scheduledTimer repeat a function at a certain interval for every 1 second
       Timer.scheduledTimer(timeInterval: 1, target: self,
                                           selector: #selector(addOne), userInfo: nil, repeats: true)
        
    }
    //end testing
    

    
    
    
    //////////////*****   CORE DATA IMPLEMENTATION     *****///////////////////
    
    
    func attemptFetch(){
        
        let fetchRequest: NSFetchRequest<Data> = Data.fetchRequest()
        let timeSort = NSSortDescriptor(key: "timeOfDay", ascending: false)
        fetchRequest.sortDescriptors = [timeSort]
        
        let controller = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
        controller.delegate = self
        self.controller = controller
        
        do{
            try controller.performFetch()
        } catch {
            let error = error as NSError
            print("\(error) HELLO WORLD")
        }
        
        let resultsOfFetch = controller.fetchedObjects
        let size = resultsOfFetch?.count
        var step = 0
        
        while(step<size!){
            battery[Int(resultsOfFetch![step].timeOfDay)] = resultsOfFetch![step].battery
            screenTimeValues[Int(resultsOfFetch![step].timeOfDay)] = resultsOfFetch![step].screenTime
            
            step = step + 1
        }
        
        
        
    }
    
   
    
    
    func generateTestData(){
        
        var one: Data!
        one = Data(context: context)
        
        one.screenTime = 0.5
        one.battery = 99.0
        one.timeOfDay = 0
        
        var two: Data!
        two = Data(context: context)
        
        two.screenTime = 0.8
        two.battery = 98.0
        two.timeOfDay = 1
        
        var three: Data!
        three = Data(context: context)
        
        three.screenTime = 1.5
        three.battery = 96.0
        three.timeOfDay = 2
        
        var four: Data!
        four = Data(context: context)
        
        four.screenTime = 2.3
        four.battery = 90.0
        four.timeOfDay = 3
        
        var five: Data!
        five = Data(context: context)
        
        five.screenTime = 2.4
        five.battery = 87.0
        five.timeOfDay = 4
        
        var six: Data!
        six = Data(context: context)
        
        six.screenTime = 2.6
        six.battery = 84.0
        six.timeOfDay = 5
        
        var seven: Data!
        seven = Data(context: context)
        
        seven.screenTime = 4.9
        seven.battery = 83.0
        seven.timeOfDay = 6
        
        var eight: Data!
        eight = Data(context: context)
        
        eight.screenTime = 5.2
        eight.battery = 82.0
        eight.timeOfDay = 7
        
        var nine: Data!
        nine = Data(context: context)
        
        nine.screenTime = 5.3
        nine.battery = 75
        nine.timeOfDay = 8
        
        var ten: Data!
        ten = Data(context: context)
        
        ten.screenTime = 5.4
        ten.battery = 75
        ten.timeOfDay = 9
        
        var eleven: Data!
        eleven = Data(context: context)
        
        eleven.screenTime = 5.5
        eleven.battery = 70
        eleven.timeOfDay = 10

        var twelve: Data!
        twelve = Data(context: context)
        
        twelve.screenTime = 5.6
        twelve.battery = 70
        twelve.timeOfDay = 11
        
        var onep: Data!
        onep = Data(context: context)
        
        onep.screenTime = 7
        onep.battery = 70
        onep.timeOfDay = 12

        var twop: Data!
        twop = Data(context: context)
        
        twop.screenTime = 7.1
        twop.battery = 68
        twop.timeOfDay = 13

        var threep: Data!
        threep = Data(context: context)
        
        threep.screenTime = 7.1
        threep.battery = 67
        threep.timeOfDay = 14

        var fourp: Data!
        fourp = Data(context: context)
        
        fourp.screenTime = 7.1
        fourp.battery = 60
        fourp.timeOfDay = 15

        var fivep: Data!
        fivep = Data(context: context)
        
        fivep.screenTime = 8.3
        fivep.battery = 55
        fivep.timeOfDay = 16



        
        
        ad.saveContext()
    }
    
    
    func configureArray(indexPath: NSIndexPath){
        
        let data = controller.object(at: indexPath as IndexPath)
       
        battery.insert(data.battery, at: Int(data.timeOfDay))
        screenTimeValues.insert(data.screenTime, at: Int(data.timeOfDay))
        timeOfDay.insert(Int(data.timeOfDay), at: Int(data.timeOfDay))
    }
    
    
    
    
    
    
    
    

}

