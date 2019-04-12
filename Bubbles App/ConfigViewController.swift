//
//  ConfigViewController.swift
//  Bubbles App
//
//  Created by APPLE DEVELOPER ACADEMY on 12/04/19.
//  Copyright © 2019 pastre. All rights reserved.
//

import UIKit

class ConfigViewController: UIViewController {

    @IBOutlet weak var modalView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func onBakcPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: {
            
        })
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        modalView.transform = CGAffineTransform(scaleX: 1, y: 0)
        UIView.animate(withDuration: 0.2) {
            self.modalView.transform = CGAffineTransform(scaleX: 1, y: 1)
        }
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
