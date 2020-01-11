//
//  GameScene.swift
//  FlappyBird
//
//  Created by user1 on 2020/01/06.
//  Copyright © 2020 yutaka.ito4. All rights reserved.
//
/*
 http://nerd0geek1.hatenablog.com/entry/2016/02/19/200000
 
 
*/

import SpriteKit


import AVFoundation



class GameScene: SKScene, SKPhysicsContactDelegate  {

    var scrollNode:SKNode!
    var wallNode:SKNode!
    var bird:SKSpriteNode!

    // 衝突判定カテゴリー
    let birdCategory: UInt32 = 1 << 0       // 0...000001
    let groundCategory: UInt32 = 1 << 1     // 0...000010
    let wallCategory: UInt32 = 1 << 2       // 0...000100
    let scoreCategory: UInt32 = 1 << 3      // 0...001000

    let item8Category: UInt32 = 1 << 4      // 0...010000
    let item19Category: UInt32 = 1 << 5     // 0...010000

    // スコア用
    var score = 0
    // アイテムスコア用
    var itemScore = 0
     var point = 0

    var scoreLabelNode:SKLabelNode!
    var bestScoreLabelNode:SKLabelNode!

    // アイテムスコア用
    var itemScoreLabelNode:SKLabelNode!
    // ポイント用
    var pointLabelNode:SKLabelNode!

   
    // スコアの保存用
    let userDefaults:UserDefaults = UserDefaults.standard

    // ---------------------------------------------------
    // SKView上にシーンが表示されたときに呼ばれるメソッド
    // ---------------------------------------------------
    override func didMove(to view: SKView) {

        
        // 重力を設定
         physicsWorld.gravity = CGVector(dx: 0, dy: -4)
         physicsWorld.contactDelegate = self

         // 背景色を設定
         backgroundColor = UIColor(red: 0.15, green: 0.75, blue: 0.90, alpha: 1)

         // スクロールするスプライトの親ノード
         scrollNode = SKNode()
         addChild(scrollNode)

         // 壁用のノード
         wallNode = SKNode()
         scrollNode.addChild(wallNode)
        // 各種スプライトを生成する処理をメソッドに分割
        setupGround()
        setupCloud()

        setupScoreLabel()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.didMove_sub01()
        }
    }
    
    func didMove_sub01 (){
        
        outputSound("start")

        setupWall()
        setupItems()
        setupBird()
 
    }
    
    // ---------------------------------------------------
    // スコア表示用ラベルの初期化
    // ---------------------------------------------------
    func setupScoreLabel() {
        let colorLabel =  UIColor.blue
        let zPositionLabel = CGFloat(100)
        let xPositionLabel = CGFloat(10)

        var yPositionLabel = CGFloat(60)
        
        score = 0
        scoreLabelNode = SKLabelNode(fontNamed: "AvenirNext-Bold")
        scoreLabelNode.fontColor = colorLabel
        scoreLabelNode.position = CGPoint(x: xPositionLabel, y: self.frame.size.height - yPositionLabel) ; yPositionLabel += 30
        scoreLabelNode.zPosition = zPositionLabel // 一番手前に表示する
        scoreLabelNode.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.left
        scoreLabelNode.text = "Score:\(score)"
        self.addChild(scoreLabelNode)

        bestScoreLabelNode = SKLabelNode(fontNamed: "AvenirNext-Bold")
        bestScoreLabelNode.fontColor = colorLabel
        bestScoreLabelNode.position = CGPoint(x: xPositionLabel, y: self.frame.size.height - yPositionLabel) ; yPositionLabel += 30
        bestScoreLabelNode.zPosition = zPositionLabel // 一番手前に表示する
        bestScoreLabelNode.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.left

        let bestScore = userDefaults.integer(forKey: "BEST")
        bestScoreLabelNode.text = "Best Score:\(bestScore)"
        self.addChild(bestScoreLabelNode)


        // アイテムスコア用
        itemScore = 0
        itemScoreLabelNode = SKLabelNode(fontNamed: "AvenirNext-Bold")
        itemScoreLabelNode.fontColor = colorLabel
        itemScoreLabelNode.position = CGPoint(x: xPositionLabel, y: self.frame.size.height - yPositionLabel) ; yPositionLabel += 30
        itemScoreLabelNode.zPosition = zPositionLabel // 一番手前に表示する
        itemScoreLabelNode.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.left
        itemScoreLabelNode.text = "アイテムスコア:\(score)"
        self.addChild(itemScoreLabelNode)
        
        // ポイント用
        point = 0
        pointLabelNode = SKLabelNode(fontNamed: "AvenirNext-Bold")
        pointLabelNode.fontColor = colorLabel
        pointLabelNode.position = CGPoint(x: xPositionLabel, y: self.frame.size.height - yPositionLabel)
        pointLabelNode.zPosition = zPositionLabel // 一番手前に表示する
        pointLabelNode.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.left
        pointLabelNode.text = "ポイント:\(point)"
        self.addChild(pointLabelNode)


    }
    
    // ---------------------------------------------------
    // 画面をタップした時に呼ばれる
    // ---------------------------------------------------
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if scrollNode.speed > 0 {
            // 鳥の速度をゼロにする
            bird.physicsBody?.velocity = CGVector.zero

            // for Test
            // 鳥の速度を??にする
            //bird.physicsBody?.velocity = CGVector.init(dx: 10, dy: 1)

            // 鳥に縦方向の力を与える
            bird.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 40))
        }
        else if bird.speed == 0 {
            // Speed 0 ＝落ちた状態
            restart()
        }
    }

    var player: AVAudioPlayer?
    // サウンド出力
    func outputSound(_ fileName: String) {
        if let sound = NSDataAsset(name: fileName) {
            player = try? AVAudioPlayer(data: sound.data)
            player?.play()
        }
    }
    
    // ---------------------------------------------------
    // SKPhysicsContactDelegateのメソッド。衝突したときに呼ばれる
    // ---------------------------------------------------
    func didBegin(_ contact: SKPhysicsContact) {
        // ゲームオーバーのときは何もしない
        if scrollNode.speed <= 0 {
            outputSound( "fin2")
            return
        }

        if (contact.bodyA.categoryBitMask & scoreCategory) == scoreCategory ||
            (contact.bodyB.categoryBitMask & scoreCategory) == scoreCategory {
            // スコア用の物体と衝突した
            score += 1
            
            scoreLabelNode.text = "Score:\(score)"

            // ベストスコア更新か確認する
            var bestScore = userDefaults.integer(forKey: "BEST")
            if score > bestScore {
                bestScore = score
                bestScoreLabelNode.text = "Best Score:\(bestScore)"
                userDefaults.set(bestScore, forKey: "BEST")
                userDefaults.synchronize()
            }
            
            print("スコア用の物体と衝突 score=" + score.description)
        }
        else if (contact.bodyA.categoryBitMask & item8Category) == item8Category ||
                (contact.bodyB.categoryBitMask & item8Category) == item8Category {
            // itemと衝突した
            contact.bodyA.node!.removeFromParent()
            
            outputSound( "get")
            point += 8
            itemScore += 1
            
            itemScoreLabelNode.text = "アイテムスコア:\(itemScore)"
            pointLabelNode.text = "ポイント:\(point)"
            
        } else if (contact.bodyA.categoryBitMask & item19Category) == item19Category ||
                (contact.bodyB.categoryBitMask & item19Category) == item19Category {
            // itemと衝突した
            contact.bodyA.node!.removeFromParent()

            outputSound( "get")
            point += 19
            itemScore += 1
            itemScoreLabelNode.text = "アイテムスコア:\(itemScore)"
            pointLabelNode.text = "ポイント:\(point)"
                    
        }   else {
            
            // 壁か地面と衝突した
            if (contact.bodyA.categoryBitMask & groundCategory == groundCategory ||
                contact.bodyB.categoryBitMask & groundCategory == groundCategory){
                print("地面と衝突")
            }
            else{
                print("壁と衝突")
                outputSound( "don")
                
            }

            // スクロールを停止させる
            scrollNode.speed = 0

            bird.physicsBody?.collisionBitMask = groundCategory

            let roll = SKAction.rotate(byAngle: CGFloat(Double.pi) * CGFloat(bird.position.y) * 0.01, duration:1)
            bird.run(roll, completion:{
                self.bird.speed = 0
            })
        }
    }
    // ---------------------------------------------------
    // restart
    // ---------------------------------------------------
    func restart() {
        score = 0
        point = 0
        itemScore = 0
        scoreLabelNode.text =  "Score:\(score)"
         itemScoreLabelNode.text = "アイテムスコア:\(itemScore)"
        pointLabelNode.text = "ポイント:\(point)"
        
        
        bird.position = CGPoint(x: self.frame.size.width * 0.2, y:self.frame.size.height * 0.7)
        bird.physicsBody?.velocity = CGVector.zero
        bird.physicsBody?.collisionBitMask = groundCategory | wallCategory
        bird.zRotation = 0

        wallNode.removeAllChildren()

        bird.speed = 1
        scrollNode.speed = 1
        
        outputSound("start")
    }

    // ---------------------------------------------------
    // 鳥を表示
    // ---------------------------------------------------
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

        // 物理演算を設定
        bird.physicsBody = SKPhysicsBody(circleOfRadius: bird.size.height / 2)

        // 衝突した時に回転させない
        bird.physicsBody?.allowsRotation = false

        // 衝突のカテゴリー設定
        bird.physicsBody?.categoryBitMask = birdCategory
        bird.physicsBody?.collisionBitMask = groundCategory | wallCategory // | itemCategory
        bird.physicsBody?.contactTestBitMask = groundCategory | wallCategory | item8Category | item19Category        // アニメーションを設定
        bird.run(flap)

        // スプライトを追加する
        addChild(bird)
    }
    // ---------------------------------------------------
    // 地面をスクロール
    // ---------------------------------------------------
    func setupGround() {
        // 地面の画像を読み込む
        let groundTexture = SKTexture(imageNamed: "ground")
        groundTexture.filteringMode = .nearest

        // 必要な枚数を計算
        let needNumber = Int(self.frame.size.width / groundTexture.size().width) + 2

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

            // スプライトに物理演算を設定する
            sprite.physicsBody = SKPhysicsBody(rectangleOf: groundTexture.size())

            // 衝突のカテゴリー設定
            sprite.physicsBody?.categoryBitMask = groundCategory

            // 衝突の時に動かないように設定する
            sprite.physicsBody?.isDynamic = false

            // スプライトを追加する
            scrollNode.addChild(sprite)
        }
    }
    // ---------------------------------------------------
    // 空をスクロール
    // ---------------------------------------------------
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
    // ---------------------------------------------------
    // 壁をスクロール
    // ---------------------------------------------------
    func setupWall() {
        // 壁の画像を読み込む
        let wallTexture = SKTexture(imageNamed: "wall")
        wallTexture.filteringMode = .linear

        // 移動する距離を計算
        let movingDistance = CGFloat(self.frame.size.width + wallTexture.size().width)

        // 画面外まで移動するアクションを作成
        let moveWall = SKAction.moveBy(x: -movingDistance, y: 0, duration:TimeInterval(groundMoveTime))

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

            // スプライトに物理演算を設定する
            under.physicsBody = SKPhysicsBody(rectangleOf: wallTexture.size())
            under.physicsBody?.categoryBitMask = self.wallCategory

            // 衝突の時に動かないように設定する
            under.physicsBody?.isDynamic = false

            wall.addChild(under)

            // 上側の壁を作成
            let upper = SKSpriteNode(texture: wallTexture)
            upper.position = CGPoint(x: 0, y: under_wall_y + wallTexture.size().height + slit_length)

            // スプライトに物理演算を設定する
            upper.physicsBody = SKPhysicsBody(rectangleOf: wallTexture.size())
            upper.physicsBody?.categoryBitMask = self.wallCategory

            // 衝突の時に動かないように設定する
            upper.physicsBody?.isDynamic = false

            wall.addChild(upper)

            // スコアアップ用のノード
            let scoreNode = SKNode()
            scoreNode.position = CGPoint(x: upper.size.width + birdSize.width / 2, y: self.frame.height / 2)
            scoreNode.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: upper.size.width, height: self.frame.size.height))
            scoreNode.physicsBody?.isDynamic = false
            scoreNode.physicsBody?.categoryBitMask = self.scoreCategory
            scoreNode.physicsBody?.contactTestBitMask = self.birdCategory

            wall.addChild(scoreNode)

            wall.run(wallAnimation)

            self.wallNode.addChild(wall)
        })

        // 次の壁作成までの時間待ちのアクションを作成
        let waitAnimation = SKAction.wait(forDuration: 2)

        // 壁を作成->時間待ち->壁を作成を無限に繰り返すアクションを作成
        let repeatForeverAnimation = SKAction.repeatForever(SKAction.sequence([createWallAnimation, waitAnimation]))

        wallNode.run(repeatForeverAnimation)
    }
    
    let groundMoveTime = 4
    // ---------------------------------------------------
    // アイテム 30 30
    // ---------------------------------------------------
    func setupItems() {
        // 壁の画像を読み込む
        let item8Texture = SKTexture(imageNamed: "item8")
        item8Texture.filteringMode = .nearest

        let item19Texture = SKTexture(imageNamed: "item19")
        item19Texture.filteringMode = .nearest


        // 移動する距離を計算
        let movingDistance8 = CGFloat(self.frame.size.width + item8Texture.size().width)
        let movingDistance19 = CGFloat(self.frame.size.width + item19Texture.size().width)

        // 画面外まで移動するアクションを作成
        let moveItem8 = SKAction.moveBy(x: -movingDistance8, y: 0, duration: TimeInterval(groundMoveTime))
        let moveItem19 = SKAction.moveBy(x: -movingDistance19, y: 0, duration: TimeInterval(groundMoveTime))

        // 自身を取り除くアクションを作成
        let removeItem = SKAction.removeFromParent()

        // アニメーションを順に実行するアクションを作成
        let itemAnimation8 = SKAction.sequence([moveItem8, removeItem])
        let itemAnimation19 = SKAction.sequence([moveItem19, removeItem])

        // 画像サイズを取得
        let itemSize = SKTexture(imageNamed: "item8").size()


        // 生成するアクションを作成
        let createWallAnimation = SKAction.run({
            let pos_x = self.frame.size.width  - item8Texture.size().width  * 3           //ノードを作成
            let itemNode8 = SKNode()
            itemNode8.position = CGPoint(x: pos_x, y: 0)
            let itemNode19 = SKNode()
            itemNode19.position = CGPoint(x: pos_x, y: 0)
            
            let random0 = Int(CGFloat.random(in: 0..<99)) % 2
        
            itemNode8.zPosition = -40
            itemNode19.zPosition = -50

            if random0 == 1 {
                itemNode8.zPosition = -50
                itemNode19.zPosition = -40
                
            }
            var random_y = CGFloat.random(in: 0..<(itemSize.height * 3))
            if random0 == 1 {
                random_y = -(random_y)
            }

            var itemSpNode8 : SKSpriteNode
            var itemSpNode19 : SKSpriteNode

            itemSpNode8 = SKSpriteNode(texture: item8Texture)
            itemSpNode8.position = CGPoint(x: 0, y: self.frame.size.height / 2 + item8Texture.size().height / 2 + random_y )
            itemSpNode8.physicsBody = SKPhysicsBody(rectangleOf: item8Texture.size())
            itemSpNode8.physicsBody?.categoryBitMask = self.item8Category

            itemSpNode19 = SKSpriteNode(texture: item19Texture)
            itemSpNode19.position = CGPoint(x: 0, y: self.frame.size.height / 2 + item8Texture.size().height / 2 + random_y )
            itemSpNode19.physicsBody = SKPhysicsBody(rectangleOf: item19Texture.size())
            itemSpNode19.physicsBody?.categoryBitMask = self.item19Category

            if random0 == 1 {
                itemSpNode8.physicsBody?.categoryBitMask = 0
                itemSpNode8.isHidden = true
            }
            else{
                itemSpNode19.physicsBody?.categoryBitMask = 0
                itemSpNode19.isHidden = true

            }

            // 衝突の時に動かないように設定する
            itemSpNode8.physicsBody?.isDynamic = false
            itemNode8.addChild(itemSpNode8)
            itemSpNode19.physicsBody?.isDynamic = false
            itemNode19.addChild(itemSpNode19)

            
            itemNode8.run(itemAnimation8)
            itemNode19.run(itemAnimation19)

            self.wallNode.addChild(itemNode8)
            self.wallNode.addChild(itemNode19)

        })

        // 次の壁作成までの時間待ちのアクションを作成
        let waitAnimation = SKAction.wait(forDuration: 2)
        // 壁を作成->時間待ち->壁を作成を無限に繰り返すアクションを作成
        let repeatForeverAnimation = SKAction.repeatForever(SKAction.sequence([createWallAnimation, waitAnimation]))

        wallNode.run(repeatForeverAnimation)
    }
}
