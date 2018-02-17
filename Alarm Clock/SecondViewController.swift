//
//  SecondViewController.swift
//  Alarm Clock
//
//  Created by David Zhang on 12/24/17.
//  Copyright © 2017 David Zhang. All rights reserved.
//

import UIKit

class SecondViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()

        /*let documentsUrl =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        do {
            let directoryContents = try FileManager.default.contentsOfDirectory(at: documentsUrl, includingPropertiesForKeys: nil, options: [])
            print(directoryContents)
            // process files
        } catch {
            print(error.localizedDescription)
        }*/
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: properties
    @IBOutlet weak var SetTime: UIDatePicker!
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        /*if segue.identifier! == "AddedAlarm"{
            let controller = (segue.destination) as! ViewController
            let pickedtime = SetTime.date
            let components = Calendar.current.dateComponents([.hour, .minute], from: pickedtime)
            let hour = components.hour!
            let minute = components.minute!
            let new_alarm = Alarm.init(hour: hour, minute: minute)
            (controller.alarms).append(new_alarm)
        }*/
    }

}
