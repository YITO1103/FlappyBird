//
//  S02ViewController.swift
//  FlappyBird
//
//  Created by user1 on 2020/01/28.
//  Copyright © 2020 yutaka.ito4. All rights reserved.
//

import UIKit
import YLGIFImage




class S02ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBOutlet weak var demoImageView: UIImageView!
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
      /*
        loadGifAnimation()
        sleep(10)
        self.dismiss(animated: true, completion: nil)
        
        
        
        let storyboard: UIStoryboard = UIStoryboard(name: "main", bundle: nil)
        let next: UIViewController = storyboard.instantiateInitialViewController()!
        self.present(next, animated: true, completion: nil)
        
       */
        
    }
    func loadGifAnimation() {

        if let path = Bundle.main.url(forResource: "1111", withExtension: "gif") {
            if let data = try? Data(contentsOf: path) {
                let gifImage = YLGIFImage(data: data)
                self.demoImageView.image = gifImage
            }
        }
    }}
