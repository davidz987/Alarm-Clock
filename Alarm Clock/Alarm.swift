//
//  Alarm.swift
//  Alarm Clock
//
//  Created by David Zhang on 12/24/17.
//  Copyright © 2017 David Zhang. All rights reserved.
//

import Foundation
import UserNotifications
import os.log

class Alarm: NSObject, NSCoding {
    var identifier:String
    var hard_hour:Int
    var hard_minute: Int
    var hour = 00
    var minute = 00
    var AM_PM = "AM"
    var On_Off = true //true = on, false = off
    var notif:[UNNotificationRequest] = []
    var notif_ids = [String]()
    
    struct PropertyKey {
        static let identifier = "identifier"
        static let hour = "hour"
        static let minute = "minute"
        static let On_Off = "On_Off"
    }
    
    //MARK: Archiving Paths
    
    static let DocumentsDirectory = FileManager().urls(for: .documentDirectory, in: .userDomainMask).first!
    static let ArchiveURL = DocumentsDirectory.appendingPathComponent("alarms")
    
    /* Creates 15 consecutive notifs, every 20 seconds starting from initialization
     * User must open one of the notifs, press stop, open the app, complete the task
     * Then the notifs will stop. Notifs must conitinue to go off even when the app
     * is open all the way until the user successfully completes the task.
     */
    
    init (hour: Int, minute: Int, index: Int, on_off: Bool){
        
        self.hard_hour = hour
        self.hard_minute = minute
        
        if hour >= 12 {
            if hour < 24 {
                self.AM_PM = "PM"
            }
            if hour > 12 {
                self.hour = hour - 12
            }
            else {
                self.hour = hour
            }
        }
        else {
            self.hour = hour
        }
        self.minute = minute
        
        self.identifier = "Alarm"+String(index)
        
        //creates and registers notification for alarm
        let content = UNMutableNotificationContent()
        content.title = NSString.localizedUserNotificationString(forKey: "Wake up!", arguments: nil)
        content.body = NSString.localizedUserNotificationString(forKey: "Rise and shine! It's morning time!",
                                                                arguments: nil)
        content.categoryIdentifier = "Alarm_going_off"
        content.sound = UNNotificationSound(named: "Constellation.aiff")
        
        let center = UNUserNotificationCenter.current()
        
        // Configure the trigger for a set time wakeup
        for i in 0...4 {
            var dateInfo = DateComponents()
            if (minute + i) > 59 {
                dateInfo.hour = hour + 1
                dateInfo.minute = (minute - 60) + i
            } else {
                dateInfo.hour = hour
                dateInfo.minute = minute + i
            }
            dateInfo.second = 0
            let trigger1 = UNCalendarNotificationTrigger(dateMatching: dateInfo, repeats: true)
            dateInfo.second = 20
            let trigger2 = UNCalendarNotificationTrigger(dateMatching: dateInfo, repeats: true)
            dateInfo.second = 40
            let trigger3 = UNCalendarNotificationTrigger(dateMatching: dateInfo, repeats: true)
            
            let id1 = "notif_00_" + String(i)
            let id2 = "notif_20_" + String(i)
            let id3 = "notif_40_" + String(i)
            self.notif_ids.append(id1)
            self.notif_ids.append(id2)
            self.notif_ids.append(id3)
            
            // Create the request object.
            let request1 = UNNotificationRequest(identifier: id1, content: content, trigger: trigger1)
            let request2 = UNNotificationRequest(identifier: id2, content: content, trigger: trigger2)
            let request3 = UNNotificationRequest(identifier: id3, content: content, trigger: trigger3)

            // Schedule the request.
            center.add(request1) { (error : Error?) in
                if let theError = error {
                    print(theError.localizedDescription)
                }
            }
            center.add(request2) { (error : Error?) in
                if let theError = error {
                    print(theError.localizedDescription)
                }
            }
            center.add(request3) { (error : Error?) in
                if let theError = error {
                    print(theError.localizedDescription)
                }
            }
            self.notif.append(request1)
            self.notif.append(request2)
            self.notif.append(request3)
        }
        
        self.On_Off = on_off
        
        //remove notifs if set to off
        if !self.On_Off {
            center.removePendingNotificationRequests(withIdentifiers: notif_ids)
        }
    }
    
    //if self > alarm then 1, if equal then 0, if self < alarm then -1
    func compare (alarm: Alarm) -> Int {
        if self.AM_PM == "AM" && alarm.AM_PM == "PM" {return -1}
        else if self.AM_PM == "PM" && alarm.AM_PM == "AM" {return 1}
        else {
            if self.hour == 12 && alarm.hour != 12 {return -1}
            else if self.hour != 12 && alarm.hour == 12 {return 1}
            else if self.hour == alarm.hour {
                if self.minute > alarm.minute {return 1}
                else if self.minute < alarm.minute {return -1}
                else {return 0}
            }
            else if self.hour > alarm.hour {return 1}
            else {return -1}
        }
    }
    
    func get_On_Off () -> Bool {
        return self.On_Off
    }
    
    func set_On_Off (on: Bool) {
        self.On_Off = on
    }
    
    func set_notif () {
        let center = UNUserNotificationCenter.current()
        for notif in self.notif {
            center.add(notif) { (error : Error?) in
                if let theError = error {
                    print(theError.localizedDescription)
                }
            }
        }
    }
    
    func remove_notif () {
        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: notif_ids)
    }
    
    func get_time () -> String {
        return String(self.hour) + ":" + String(format: "%02d", self.minute) + " " + self.AM_PM
    }
    
    //MARK: NSCoding
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(self.identifier, forKey: PropertyKey.identifier)
        aCoder.encode(String(self.hard_hour), forKey: PropertyKey.hour)
        aCoder.encode(String(self.hard_minute), forKey: PropertyKey.minute)
        aCoder.encode(String(self.On_Off), forKey: PropertyKey.On_Off)
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        // The identifier is required. If we cannot decode an identifier string, the initializer should fail.
        guard let identifier = aDecoder.decodeObject(forKey: PropertyKey.identifier) as? String else {
            os_log("Unable to decode the name for a Meal object.", log: OSLog.default, type: .debug)
            return nil
        }
        let hour = aDecoder.decodeObject(forKey: PropertyKey.hour) as! String
        let minute = aDecoder.decodeObject(forKey: PropertyKey.minute) as! String
        let index = identifier[identifier.index(before: identifier.endIndex)]
        let On_Off = aDecoder.decodeObject(forKey: PropertyKey.On_Off) as! String
        self.init(hour: Int(hour)!, minute: Int(minute)!, index: Int(String(index))!, on_off: Bool(On_Off)!)
    }
    
}
