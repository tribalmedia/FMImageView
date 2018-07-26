//
//  ViewController.swift
//  Example
//
//  Created by Hoang Trong Anh on 5/23/18.
//  Copyright © 2018 Hoang Trong Anh. All rights reserved.
//

import UIKit
import FMImageView

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func fmPresentImage(_ sender: Any) {
        let arrayURL = [
            URL(string: "https://media.funmee.jp/medias/6a6bdd8326c225b806021f39e19ed97b1cff8cc5/large.jpg")!,
            URL(string: "https://media.funmee.jp/medias/abbdda21d9c5859871bb88b521f6b4d2ab41601a/large.jpg")!,
        ]
        
        let vc = ImageSlideViewController(urls: arrayURL, fromImageView: nil)
        
        let button = UIButton()
        button.setImage(#imageLiteral(resourceName: "icn_like"), for: .normal)  
        button.addTarget(self, action: #selector(target1(_:)), for: .touchUpInside)
        let label = UILabel()
        label.text = "10"
        
        let button1 = UIButton()
        button1.setImage(#imageLiteral(resourceName: "icn_comment"), for: .normal)
        button1.addTarget(self, action: #selector(target2(_:)), for: .touchUpInside)
        let label1 = UILabel()
        label1.text = "20"
        
        vc.subAreaBottomView.append((button: button, label: label))
        vc.subAreaBottomView.append((button: button1, label: label1))
        
        self.present(vc, animated: true, completion: nil)
    }
    
    @objc func target1(_ sender: UIButton) {
        print(#function)
    }
    
    @objc func target2(_ sender: UIButton) {
        print(#function)
    }
    
}

