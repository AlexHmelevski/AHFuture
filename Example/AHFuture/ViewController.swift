//
//  ViewController.swift
//  AHFuture
//
//  Created by AlexHmelevskiAG on 04/08/2017.
//  Copyright (c) 2017 AlexHmelevskiAG. All rights reserved.
//

import UIKit
import AHFuture
enum TestError: Error {
    
}

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        let future = AHFuture<Int,TestError>.init { (completion) in
            
        }
        
        
        
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

