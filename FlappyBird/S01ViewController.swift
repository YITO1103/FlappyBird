//
//  S01ViewController.swift
//  FlappyBird
//
//  Created by user1 on 2020/01/28.
//  Copyright © 2020 yutaka.ito4. All rights reserved.
//

import UIKit
import YLGIFImage


class S01ViewController: UIViewController {

    @IBOutlet weak var demoImageView: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        //loadGifAnimation() 
        sleep(10)
        self.dismiss(animated: true, completion: nil)

        let viewController = self.storyboard?.instantiateViewController(withIdentifier: "main")
        self.present(viewController!, animated: true, completion: nil)
        //self.dismiss(animated: true, completion: nil)
    }
    func loadGifAnimation() {

        if let path = Bundle.main.url(forResource: "1111", withExtension: "gif") {
            if let data = try? Data(contentsOf: path) {
                let gifImage = YLGIFImage(data: data)
                self.demoImageView.image = gifImage
            }
        }
    }}
