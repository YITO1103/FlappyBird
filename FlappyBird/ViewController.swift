//
//  ViewController.swift
//  FlappyBird
//
//  Created by user1 on 2020/01/06.
//  Copyright © 2020 yutaka.ito4. All rights reserved.
//
import UIKit
import SpriteKit

class ViewController: UIViewController {
    
    
    var s: Int =  0
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        //init_view()
    }

    func init_view(){
            // SKViewに型を変換する
            let skView = self.view as! SKView

            // FPSを表示する
            skView.showsFPS = true

            // ノードの数を表示する
            skView.showsNodeCount = true
    /*
            // ビューと同じサイズでシーンを作成する
            let scene = GameScene(size:skView.frame.size)
            // ビューにシーンを表示する
            skView.presentScene(scene)
     */
            skView.presentScene(GameScene(size:skView.frame.size))
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
  

        init_view()
        
    }
    // ステータスバーを消す
    override var prefersStatusBarHidden: Bool {
        get {
            return true
        }
    }

}
