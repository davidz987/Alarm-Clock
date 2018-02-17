//
//  ViewController.swift
//  Alarm Clock
//
//  Created by David Zhang on 12/24/17.
//  Copyright © 2017 David Zhang. All rights reserved.
//

import UIKit
import MediaPlayer
import os.log
import UserNotifications

class ViewController: UIViewController , UITableViewDataSource, UITableViewDelegate {
    
    var alarms = [Alarm]()
    var counter = 0
    var current_switch = UISwitch()
    var failed_ref = ""
    var failed_attempt = ""
    
    @IBOutlet var tableView: UITableView!
    
    let cellReuseIdentifier = "alarm"
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        //creates a new cell
        let cell:UITableViewCell = self.tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier) as UITableViewCell!
        cell.backgroundColor = UIColor.darkGray
        
        //adds text to the cell
        cell.textLabel?.text = (self.alarms[indexPath.row]).get_time()
        cell.textLabel?.font = UIFont(name:"Avenir", size:35)
        
        //adds a switch
        let newSwitch = UISwitch()
        newSwitch.isOn = self.alarms[indexPath.row].get_On_Off()
        newSwitch.addTarget(self, action: #selector(switchTriggered), for: .valueChanged)
        newSwitch.tag = indexPath.row
        cell.accessoryView = newSwitch
        
        return cell
    }
    
    func switching(sender : UISwitch){
        self.alarms[sender.tag].set_On_Off(on: sender.isOn)
        
        //reschedules notification
        if sender.isOn {
            self.alarms[sender.tag].set_notif()
        }
            //removes notification
        else {
            self.alarms[sender.tag].remove_notif()
        }
        
        saveAlarms()
    }
    
    @objc func switchTriggered(_ sender : UISwitch!){
        
        //trying to turn off
        if !sender.isOn {
            sender.setOn(true, animated: false)
            current_switch = sender
            self.performSegue(withIdentifier: "StopAlarm", sender: nil)
        }
        //trying to turn on
        else {
            switching(sender: sender)
            self.performSegue(withIdentifier: "Reminder", sender: nil)
        }
    }
    
    @IBAction func unwindToVC1FromPopUp(segue:UIStoryboardSegue) {
        let controller = segue.source as? PopUpViewController
        let ref = controller?.TextToType.text.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        let attempt = controller?.TypedText.text.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        if ref == attempt {
            current_switch.setOn(false, animated: false)
            switching(sender: current_switch)
        } else {
            self.failed_ref = ref!
            self.failed_attempt = attempt!
            if let segue = segue as? UIStoryboardSegueWithCompletion{
                segue.completion = {
                    self.performSegue(withIdentifier: "FailedStopAttempt", sender: nil)
                }
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "FailedStopAttempt" {
            let destination = segue.destination as! FailedAttemptViewController
            print(self.failed_ref)
            print(self.failed_attempt)
            destination.ref = self.failed_ref
            destination.attempt = self.failed_attempt
        }
    }
    
    //After failed stop alarm attempt
    @IBAction func failedBackToVC1FromPopUp(segue:UIStoryboardSegue) {
        //Does nothing
    }
    
    @IBAction func reminderBackToVC1FromPopUp(segue:UIStoryboardSegue) {
        //Does nothing
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.alarms.count
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //register the table view cell class and its reuse id
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellReuseIdentifier)
        
        //removes the extra empty cell divider lines
        self.tableView.tableFooterView = UIView()
        
        //this view controller itself will provide the delegate methods and row data for the table view.
        tableView.delegate = self
        tableView.dataSource = self
        
        if let savedAlarms = loadAlarms() {
            alarms += savedAlarms
        }
        
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //implements deleting of cells
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            //remove all notifs with that alarm
            alarms[indexPath.row].remove_notif()
            // remove the item from the data model
            alarms.remove(at: indexPath.row)
            // delete the table view row
            tableView.deleteRows(at: [indexPath], with: .fade)
            //saves alarms
            saveAlarms()
        }
    }
    
    //sets the height of each cell
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return 75.0
    }

    func addSorted(alarms: inout [Alarm], add: Alarm) {
        if alarms.count == 0 {
            alarms.append(add)
        }
        else if alarms[(alarms.count-1)].compare(alarm: add) <= 0 {alarms.append(add)}
        else if alarms[0].compare(alarm: add) > 0 {alarms.insert(add, at:0)}
        else {
            for i in 0...(alarms.count-2){
                if alarms[i].compare(alarm: add) <= 0 && alarms[i+1].compare(alarm: add) > 0 {
                    alarms.insert(add, at:i+1)
                    break
                }
            }
        }
    }
    
    //Backing out of adding an alarm
    @IBAction func backToVC1(segue:UIStoryboardSegue) {
        //Does nothing
    }
    
    @IBAction func unwindToVC1(segue:UIStoryboardSegue) {
        let controller = segue.source as? SecondViewController
        let SetTime = controller!.SetTime
        let pickedtime = SetTime!.date
        let components = Calendar.current.dateComponents([.hour, .minute], from: pickedtime)
        let hour = components.hour!
        let minute = components.minute!
        let new_alarm = Alarm.init(hour: hour, minute: minute, index: self.counter, on_off: true)
        self.counter = self.counter+1
        addSorted(alarms: &self.alarms, add: new_alarm)
        
        tableView.reloadData()
        
        //Save alarms
        saveAlarms()
    }
    
    private func saveAlarms() {
        let isSuccessfulSave = NSKeyedArchiver.archiveRootObject(alarms, toFile: Alarm.ArchiveURL.path)
        if isSuccessfulSave {
            os_log("Alarms successfully saved.", log: OSLog.default, type: .debug)
        } else {
            os_log("Failed to save alarms...", log: OSLog.default, type: .error)
        }
    }
    
    private func loadAlarms() -> [Alarm]? {
        //erases all saved coded data
        //let isSuccessfulSave = NSKeyedArchiver.archiveRootObject([], toFile: Alarm.ArchiveURL.path)
        
        //erases all pending notifications
        //let center = UNUserNotificationCenter.current()
        //center.removeAllPendingNotificationRequests()
        
        return NSKeyedUnarchiver.unarchiveObject(withFile: Alarm.ArchiveURL.path) as? [Alarm]
    }
}

