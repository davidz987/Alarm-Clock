//
//  FailedAttemptViewController.swift
//  Alarm Clock
//
//  Created by David Zhang on 1/17/18.
//  Copyright © 2018 David Zhang. All rights reserved.
//

import UIKit

class FailedAttemptViewController: UIViewController {

    var ref = ""
    var attempt = ""
    
    @IBOutlet var popUp: UIView!
    @IBOutlet var Failed_Reference: UITextView!
    @IBOutlet var Failed_Attempt: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        popUp.layer.masksToBounds = true;
        popUp.layer.cornerRadius = 8.0;
        
        Failed_Reference.text = ref
        Failed_Attempt.text = attempt
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    

}
