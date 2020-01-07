//
//  GameScene.swift
//  FlappyBird
//
//  Created by user1 on 2020/01/06.
//  Copyright © 2020 yutaka.ito4. All rights reserved.
//

import SpriteKit

class GameScene: SKScene {
    // // スクロールするスプライトの親ノード
    var scrollNode:SKNode!
    var wallNode:SKNode!
    var bird:SKSpriteNode!
    
    
    
    // SKView上にシーンが表示されたときに呼ばれるメソッド
    override func didMove(to view: SKView) {
        // 画面を構築する処理を書いたり、ゲームの初期設定を行う。
        
        
        // 背景色を設定
        backgroundColor = UIColor(red: 0.15, green: 0.75, blue: 0.90, alpha: 1)

        // スクロールするスプライトの親ノード
        scrollNode = SKNode()
        addChild(scrollNode)
        
        
        print("[GameScene] frame.size-------------------")
        print(self.frame.size)

        // 各種スプライトを生成する処理をメソッドに分割
        setupGround()   // 地面をスクロール
        setupCloud()    // 空をスクロール
        
        
        // 壁用のノード
        wallNode = SKNode()   // 追加
        scrollNode.addChild(wallNode)   // 追加

        // 各種スプライトを生成する処理をメソッドに分割
        setupGround()
        setupCloud()
        setupWall()   // 追加
        setupBird()
        
    }
    // 鳥を表示
    func setupBird() {
        // 鳥の画像を2種類読み込む
        let birdTextureA = SKTexture(imageNamed: "bird_a")
        birdTextureA.filteringMode = .linear
        let birdTextureB = SKTexture(imageNamed: "bird_b")
        birdTextureB.filteringMode = .linear

        // 2種類のテクスチャを交互に変更するアニメーションを作成
        let texturesAnimation = SKAction.animate(with: [birdTextureA, birdTextureB], timePerFrame: 0.2)
        let flap = SKAction.repeatForever(texturesAnimation)

        // スプライトを作成
        bird = SKSpriteNode(texture: birdTextureA)
        bird.position = CGPoint(x: self.frame.size.width * 0.2, y:self.frame.size.height * 0.7)

        // アニメーションを設定
        bird.run(flap)

        // スプライトを追加する
        addChild(bird)
    }
    // 地面をスクロール
    func setupGround() {



        // 地面の画像を読み込む
        let groundTexture = SKTexture(imageNamed: "ground")
        groundTexture.filteringMode = .nearest


        // 必要な枚数を計算
        let needNumber = Int(self.frame.size.width / groundTexture.size().width) + 2
        print("[groundTexture] size-------------------")
        print(groundTexture.size().width.description + "," + groundTexture.size().height.description)
        print("必要な枚数:" + needNumber.description)
        

        // スクロールするアクションを作成
        // 左方向に画像一枚分スクロールさせるアクション
        let moveGround = SKAction.moveBy(x: -groundTexture.size().width , y: 0, duration: 5)

        // 元の位置に戻すアクション
        let resetGround = SKAction.moveBy(x: groundTexture.size().width, y: 0, duration: 0)

        // 左にスクロール->元の位置->左にスクロールと無限に繰り返すアクション
        let repeatScrollGround = SKAction.repeatForever(SKAction.sequence([moveGround, resetGround]))

        // groundのスプライトを配置する
        for i in 0..<needNumber {
            let sprite = SKSpriteNode(texture: groundTexture)

            // スプライトの表示する位置を指定する
            sprite.position = CGPoint(
                x: groundTexture.size().width / 2  + groundTexture.size().width * CGFloat(i),
                y: groundTexture.size().height / 2
            )

            // スプライトにアクションを設定する
            sprite.run(repeatScrollGround)

            // スプライトを追加する
            scrollNode.addChild(sprite)
        }
    }
    // 空をスクロール
    func setupCloud() {
        // 雲の画像を読み込む
        let cloudTexture = SKTexture(imageNamed: "cloud")
        cloudTexture.filteringMode = .nearest

        // 必要な枚数を計算
        let needCloudNumber = Int(self.frame.size.width / cloudTexture.size().width) + 2

        
        print("[groundTexture] size-------------------")
        print(cloudTexture.size().width.description + "," + cloudTexture.size().height.description)
        print("必要な枚数:" + needCloudNumber.description)
        
        
        
        
        // スクロールするアクションを作成
        // 左方向に画像一枚分スクロールさせるアクション
        let moveCloud = SKAction.moveBy(x: -cloudTexture.size().width , y: 0, duration: 20)

        // 元の位置に戻すアクション
        let resetCloud = SKAction.moveBy(x: cloudTexture.size().width, y: 0, duration: 0)

        // 左にスクロール->元の位置->左にスクロールと無限に繰り返すアクション
        let repeatScrollCloud = SKAction.repeatForever(SKAction.sequence([moveCloud, resetCloud]))

        // スプライトを配置する
        for i in 0..<needCloudNumber {
            let sprite = SKSpriteNode(texture: cloudTexture)
            sprite.zPosition = -100 // 一番後ろになるようにする

            // スプライトの表示する位置を指定する
            sprite.position = CGPoint(
                x: cloudTexture.size().width / 2 + cloudTexture.size().width * CGFloat(i),
                y: self.size.height - cloudTexture.size().height / 2
            )
            print("Cloudスプライト(" + i.description + "):" + sprite.position.debugDescription)
            // スプライトにアニメーションを設定する
            sprite.run(repeatScrollCloud)

            // スプライトを追加する
            scrollNode.addChild(sprite)
        }
    }
    // 壁をスクロール
    func setupWall() {
        // 壁の画像を読み込む
        let wallTexture = SKTexture(imageNamed: "wall")
        // 当たり判定を行うスプライトに貼り付けるテクスチャは.linearを設定して画質優先にした方が一般的には良い
        wallTexture.filteringMode = .linear
        print("[wallTexture] size-------------------")
        print(wallTexture.size().width.description + "," + wallTexture.size().height.description)

        // 移動する距離を計算 Sceneの横幅＋壁の横幅
        let movingDistance = CGFloat(self.frame.size.width + wallTexture.size().width)
        print("[移動する距離：" + movingDistance.description)

        // 画面外まで移動するアクションを作成
        let moveWall = SKAction.moveBy(x: -movingDistance, y: 0, duration:4)
        // 自身を取り除くアクションを作成
        let removeWall = SKAction.removeFromParent()

        // 2つのアニメーションを順に実行するアクションを作成
        let wallAnimation = SKAction.sequence([moveWall, removeWall])

        // 鳥の画像サイズを取得
        let birdSize = SKTexture(imageNamed: "bird_a").size()

        // 鳥が通り抜ける隙間の長さを鳥のサイズの3倍とする
        let slit_length = birdSize.height * 3

        // 隙間位置の上下の振れ幅を鳥のサイズの3倍とする
        let random_y_range = birdSize.height * 3

        // 下の壁のY軸下限位置(中央位置から下方向の最大振れ幅で下の壁を表示する位置)を計算
        let groundSize = SKTexture(imageNamed: "ground").size()
        let center_y = groundSize.height + (self.frame.size.height - groundSize.height) / 2
        let under_wall_lowest_y = center_y - slit_length / 2 - wallTexture.size().height / 2 - random_y_range / 2

        // 壁を生成するアクションを作成
        let createWallAnimation = SKAction.run({
            // 壁関連のノードを乗せるノードを作成
            let wall = SKNode()
            wall.position = CGPoint(x: self.frame.size.width + wallTexture.size().width / 2, y: 0)
            wall.zPosition = -50 // 雲より手前、地面より奥

            // 0〜random_y_rangeまでのランダム値を生成
            let random_y = CGFloat.random(in: 0..<random_y_range)
            // Y軸の下限にランダムな値を足して、下の壁のY座標を決定
            let under_wall_y = under_wall_lowest_y + random_y

            // 下側の壁を作成
            let under = SKSpriteNode(texture: wallTexture)
            under.position = CGPoint(x: 0, y: under_wall_y)

            wall.addChild(under)

            // 上側の壁を作成
            let upper = SKSpriteNode(texture: wallTexture)
            upper.position = CGPoint(x: 0, y: under_wall_y + wallTexture.size().height + slit_length)

            wall.addChild(upper)

            wall.run(wallAnimation)

            self.wallNode.addChild(wall)
        })

        // 次の壁作成までの時間待ちのアクションを作成
        let waitAnimation = SKAction.wait(forDuration: 2)

        // 壁を作成->時間待ち->壁を作成を無限に繰り返すアクションを作成
        let repeatForeverAnimation = SKAction.repeatForever(SKAction.sequence([createWallAnimation, waitAnimation]))

        wallNode.run(repeatForeverAnimation)
    }


    
}