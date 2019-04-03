//
//  OptionsView.swift
//  Bubbles App
//
//  Created by APPLE DEVELOPER ACADEMY on 03/04/19.
//  Copyright © 2019 pastre. All rights reserved.
//

import Foundation
import UIKit

class OptionsView1: UIView{
    
    var autoButton: UIButton!
    var touchButton: UIButton!
    var blowButton: UIButton!
    var cameraButton: UIButton!
    
    let icons = [
        "blow": UIImage(named: "blow")!,
        "auto": UIImage(named: "catavento")!,
        "touch": UIImage(named: "touch")!,
        //        "camera": UIImage(named: "camera")!,
    ]
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.initButtons()
        self.initConstrains()
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func initConstrains(){
        
    }
    
    func initButtons(){
        self.autoButton = UIButton()
        self.touchButton = UIButton()
        self.blowButton = UIButton()
        self.cameraButton = UIButton()
    
    }
}
