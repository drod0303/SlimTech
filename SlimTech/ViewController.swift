//
//  ViewController.swift
//  SlimTech
//
//  Created by Dawsen Richins on 2/13/17.
//  Copyright © 2017 Droplet. All rights reserved.
//

import UIKit
import JBChart

class ViewController: UIViewController, JBBarChartViewDelegate, JBBarChartViewDataSource {
    
    @IBOutlet weak var barChart: JBBarChartView!
    
    @IBOutlet weak var informationLabel: UILabel!
    
   
    var chartData = [0.5,1.5,3.5,4.0,4.1,7.7,9.9,10,11,11,11,11,11,11,11,12.5,13,13.2,13.3,15,15.1,15.1,15.1,18]
    var chartLegend = [1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24]

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.darkGray
    
        //bar chart setup
        barChart.backgroundColor = UIColor.darkGray
        barChart.delegate = self
        barChart.dataSource = self
        barChart.minimumValue = 0
        barChart.maximumValue = CGFloat(chartData.max()!)
        
        barChart.reloadData()
        
        barChart.setState(.collapsed, animated: false)
        
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
      
        let footerView = UIView(frame: CGRect(x: 0, y: 0, width: barChart.frame.width, height: 16))
        
        var xAxis = ""
        var section = Int(barChart.frame.width)/chartLegend.count
        var iterator = 0
        
        while(iterator<chartLegend.count)
        {
            if(iterator%2 == 0)
            {
                xAxis += "  "
            }
            
            xAxis += "\(chartLegend[iterator])"
            xAxis+=" "
            
            
            
            iterator += 1
            
        }
    
        
        
        
        let footer1 = UILabel(frame: CGRect(x: 0, y: 0, width: barChart.frame.width - 26 , height: 16))
        footer1.textColor = UIColor.white
        footer1.text = xAxis/*"\(chartLegend[0])"*/
        //footer1.backgroundColor = UIColor.red
        
        /*let footer2 = UILabel(frame: CGRect(x: barChart.frame.width/2 - 26, y: 0, width: barChart.frame.width/2 - 29, height: 16))
        footer2.textColor = UIColor.white
        footer2.text = "\(chartLegend[chartLegend.count - 1])"
        footer2.textAlignment = NSTextAlignment.right
        //footer2.backgroundColor = UIColor.green
        */
        
        footerView.addSubview(footer1)
        //footerView.addSubview(footer2)
        
        
        
        let header = UILabel(frame: CGRect(x: 0, y: 0, width: barChart.frame.width, height: 50))
        header.textColor = UIColor.white
        header.font = UIFont.systemFont(ofSize: 24)
        header.text = "Phone Usage"
        header.textAlignment = NSTextAlignment.center
        footer1.font = UIFont.systemFont(ofSize: 8)
        
        barChart.footerView = footerView
        barChart.headerView = header

    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        barChart.reloadData()
        
        var timer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: Selector("showChart"), userInfo: nil, repeats: false)
    }
    
    
    override func viewDidDisappear(_ animated: Bool) {
        
        super.viewDidDisappear(animated)
        hideChart()
        
    }

    func hideChart(){
        barChart.setState(.collapsed, animated: true)
        
        
    }
    
    
    func showChart(){
        barChart.setState(.expanded, animated: true)
        
    }
    
    //MARK: JBBarChartView
    
    func numberOfBars(in barChartView: JBBarChartView!) -> UInt {
        
        return UInt(chartData.count)
    }
    
    func barChartView(_ barChartView: JBBarChartView!, heightForBarViewAt index: UInt) -> CGFloat {
        
        return CGFloat(chartData[Int(index)])
        
    }
    
    func barChartView(_ barChartView: JBBarChartView!, colorForBarViewAt index: UInt) -> UIColor! {
        
        return (index % 2 == 0) ? UIColor.lightGray : UIColor.white
        
    }
    
    
    func barChartView(_ barChartView: JBBarChartView!, didSelectBarAt index: UInt, touch touchPoint: CGPoint) {
        
        let data = chartData[Int(index)]
        let key = chartLegend[Int(index)]
        
        informationLabel.text = "Usage at \(key): \(data)"
        
    }
    
    func didDeselect(_ barChartView: JBBarChartView!) {
        informationLabel.text = ""
    }
    

}

