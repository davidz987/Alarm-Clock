//
//  PopUpViewController.swift
//  Alarm Clock
//
//  Created by David Zhang on 1/15/18.
//  Copyright © 2018 David Zhang. All rights reserved.
//

import UIKit

class UIStoryboardSegueWithCompletion: UIStoryboardSegue {
    var completion: (() -> Void)?
    
    override func perform() {
        super.perform()
        if let completion = completion {
            completion()
        }
    }
}

class PopUpViewController: UIViewController {
    
    let file = "AnatomyTerms"
    var terms = [String]()

    @IBOutlet var popUp: UIView!
    @IBOutlet var TextToType: UITextView!
    @IBOutlet var TypedText: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        popUp.layer.masksToBounds = true;
        popUp.layer.cornerRadius = 8.0;
        
        if let path = Bundle.main.path(forResource: file, ofType: "txt") {
            do {
                let data = try String(contentsOfFile: path, encoding: .utf8)
                terms = data.components(separatedBy: .newlines)
            }
            catch {
                print(error)
            }
        }
        
        let index = arc4random_uniform(UInt32(terms.count))
        
        TextToType.text = terms[Int(index)]
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
