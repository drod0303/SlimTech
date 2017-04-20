//
//  SettingsVC.swift
//  SlimTech
//
//  Created by Dawsen Richins on 2/18/17.
//  Copyright © 2017 Droplet. All rights reserved.
//

import UIKit
import UserNotifications

class SettingsVC: UIViewController {
    
    @IBOutlet weak var timeAlertSwitch: UISwitch!
    @IBOutlet weak var percentAlertSwitch: UISwitch!
    
    @IBOutlet weak var timeAlertPicker: UIDatePicker!
    
    @IBOutlet weak var saveButton: UIButton!
    
    @IBOutlet weak var timeAlertLabel: UILabel!
    @IBOutlet weak var percentAlertLabel: UILabel!
    
    @IBOutlet weak var percentUsageTextEntry: UITextField!
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //configure user notification center
       UNUserNotificationCenter.current().delegate = self as? UNUserNotificationCenterDelegate
        
        
        view.backgroundColor = UIColor.black
        timeAlertPicker.setValue(UIColor.white, forKeyPath: "textColor")
        timeAlertPicker.timeZone = NSTimeZone.local
        
        saveButton.isHidden = true
        
        timeAlertPicker.isHidden = true
        
        percentUsageTextEntry.isHidden = true
        
        
        
        
        
    }

    

    
    //this function allows views to be erased rather than simply stacked upon
    @IBAction func backButtonPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }

    //button notifier that allows the time picker to be presented based upon the boolean value of a switch
    @IBAction func timeAlertSwitchPressed(_ sender: Any) {
        if(timeAlertSwitch.isOn){
            timeAlertPicker.isHidden = false
            saveButton.isHidden = false
        }
        else{
            
            timeAlertPicker.isHidden = true
            saveButton.isHidden = true
            timeAlertLabel.text = "Daily Usage Reminder"
        }
    }
    
    //setting provided in storyboard for when a percent usage reminder needs to be set
    //programmatically created a done button because storyboard didn't have environment needed for impolementation
    
    @IBAction func percentAlertSwitchPressed(_ sender: Any) {
        
        if (percentAlertSwitch.isOn == true){
            let keyPadDone = UIToolbar.init()
            keyPadDone.sizeToFit()
            let keyPadButtonDone = UIBarButtonItem.init(barButtonSystemItem: UIBarButtonSystemItem.done,
                                                  target: self, action: #selector(SettingsVC.donePressed(_:)))
            
            keyPadDone.items = [keyPadButtonDone] // You can even add cancel button too
            percentUsageTextEntry.inputAccessoryView = keyPadDone
            percentUsageTextEntry.isHidden = false
            percentUsageTextEntry.keyboardType = UIKeyboardType.numberPad
            percentUsageTextEntry.becomeFirstResponder()
        }
        else{
            percentAlertLabel.text = "Percent Cap Reminder"
            percentUsageTextEntry.isHidden = true
            percentUsageTextEntry.resignFirstResponder()
        }
        
    }
    
    //done button programmatically created (not present in storyboard)
    //done button allows for exit procedures when the user has entered a percent usage reminder
    
    @IBAction func donePressed(_ sender: Any) {
        if(percentUsageTextEntry.hasText == false){
            percentAlertSwitch.isOn = false
        }else if(Int(percentUsageTextEntry.text!)!>100){
            percentAlertLabel.text = "Percent Cap Reminder: 100%"
        }
        else{
            percentAlertLabel.text = "Percent Cap Reminder: \(percentUsageTextEntry.text!)%"
        }
        
        percentUsageTextEntry.resignFirstResponder()
        percentUsageTextEntry.isHidden = true
        
        
    }
    
    //allows for the time selected by the user to be saved into core data
    //still needs updating because there is a certain bug occuring when the time is before the current time
    @IBAction func saveButtonPressed(_ sender: Any) {
       
        saveButton.isHidden = true
        if(timeAlertPicker.isHidden == false){
            var hour = timeAlertPicker.value(forKeyPath: "hour") as? Int
            let minute = timeAlertPicker.value(forKeyPath: "minute") as? Int
            setUpLocalNotification(hour: hour!, minute: minute!)
            var minuteString = ""
            var hourString = ""
            
            if (minute!<10){
                minuteString = "0\(minute!)"
            }
            else{
                minuteString = "\(minute!)"
            }
            
            if (hour!>=12){
                if (hour! == 12){
                    hour! += 0
                }
                else{
                    hour! -= 12
                }
                hourString = "\(hour!)"
                timeAlertLabel.text = "Usage Reminder   " + hourString + ":" + minuteString + " PM"
                
            }
            else{
                if (hour! == 0){
                    hour! += 12
                }
                hourString = "\(hour!)"
                timeAlertLabel.text = "Usage Reminder   " + hourString + ":" + minuteString + " AM"
            }
            timeAlertPicker.isHidden = true
        }
    }
    
     func setUpLocalNotification(hour: Int, minute: Int) {
        
        // Request Notification Settings
        UNUserNotificationCenter.current().getNotificationSettings { (notificationSettings) in
            switch notificationSettings.authorizationStatus {
            case .notDetermined:
                self.requestAuthorization(completionHandler: { (success) in
                    guard success else { return }
                    
                    // Schedule Local Notification
                    self.scheduleLocalNotification()
                })
            case .authorized:
                // Schedule Local Notification
                self.scheduleLocalNotification()
            case .denied:
                print("Application Not Allowed to Display Notifications")
            }
        }
        
    }
    
    
    private func requestAuthorization(completionHandler: @escaping (_ success: Bool) -> ()) {
        // Request Authorization
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { (success, error) in
            if let error = error {
                print("Request Authorization Failed (\(error), \(error.localizedDescription))")
            }
            
            completionHandler(success)
        }
    }
    
    private func scheduleLocalNotification() {
        
        var hour = Calendar.current.component(.hour, from: Date())
        if(hour==0){
            hour = 24
        }else if (hour == 24){
            hour = 1
        }
        
        // Create Notification Content
        let notificationContent = UNMutableNotificationContent()
        
        // Configure Notification Content
        notificationContent.title = "Slimetch"
        notificationContent.subtitle = "Local Notification"
        notificationContent.body = "Total screen time used so far: \(screenTimeValues[hour-1]) hours"
        
        // Add Trigger
        let notificationTrigger = UNTimeIntervalNotificationTrigger(timeInterval: 10.0, repeats: false)

        
        // Create Notification Request
        let notificationRequest = UNNotificationRequest(identifier: "cocoacasts_local_notification", content: notificationContent, trigger: notificationTrigger)
        
        // Add Request to User Notification Center
        UNUserNotificationCenter.current().add(notificationRequest) { (error) in
            if let error = error {
                print("Unable to Add Notification Request (\(error), \(error.localizedDescription))")
            }
        }
    }
    
    
    
}



extension ViewController: UNUserNotificationCenterDelegate {
    
    
    
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert, .badge, .sound])
        
        
    }
    
}
