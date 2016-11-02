//
//  ViewController.swift
//  siriKit-Intents
//
//  Created by yesway on 2016/11/2.
//  Copyright © 2016年 joker. All rights reserved.
//

import UIKit
import Intents

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        INPreferences.requestSiriAuthorization { (status) in
            
            if status == .authorized {
                print("start use Siri")
            } else {
                print("Hmmm... This demo app is going to pretty useless if you don't enable Siri. Fancy changing your mind?")
            }
            
        }
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

