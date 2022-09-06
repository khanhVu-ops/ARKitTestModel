//
//  IntroVC.swift
//  ObjectDetection-CoreML
//
//  Created by KhanhVu on 9/6/22.
//  Copyright © 2022 tucan9389. All rights reserved.
//

import UIKit

class IntroVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func didTapBtn2D(_ sender: Any) {
        let st = UIStoryboard(name: "Main", bundle: nil)
        let vc = st.instantiateViewController(withIdentifier: "Detect2DVC") as! Detect2DVC
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func didTapBtn3D(_ sender: Any) {
        let st = UIStoryboard(name: "Main", bundle: nil)
        let vc = st.instantiateViewController(withIdentifier: "Object3DVC") as! Object3DVC
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
