//
//  S01ViewController.swift
//  FlappyBird
//
//  Created by user1 on 2020/01/28.
//  Copyright © 2020 yutaka.ito4. All rights reserved.
//

import UIKit

class S01ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        sleep(10)
        self.dismiss(animated: true, completion: nil)

        let viewController = self.storyboard?.instantiateViewController(withIdentifier: "main")
        self.present(viewController!, animated: true, completion: nil)
        //self.dismiss(animated: true, completion: nil)
    }

}
