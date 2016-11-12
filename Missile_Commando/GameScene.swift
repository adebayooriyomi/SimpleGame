//
//  GameScene.swift
//  Missile_Commando
//
//  Created by Justin Dike on 6/25/15.
//  Copyright (c) 2015 CartoonSmart. All rights reserved.
//

import SpriteKit
import AVFoundation


enum BodyType:UInt32 {
    
    case playerBase = 1
    case base = 2
    case bullet = 4
    case enemyMissile = 8
    case enemy = 16
    case ground = 32
    case enemyBomb = 64
    
}



enum UIUserInterfaceIdiom : Int {
    case unspecified
    
    case phone // iPhone and iPod touch style UI
    case pad // iPad style UI
}


class GameScene: SKScene, SKPhysicsContactDelegate  {
    
    let theSound:SKAction = SKAction.playSoundFileNamed("gun1.caf", waitForCompletion: false)
    let restoreHealth:SKAction = SKAction.playSoundFileNamed("restoreHealth.caf", waitForCompletion: false)
    let explosion1:SKAction = SKAction.playSoundFileNamed("explosion1.caf", waitForCompletion: false)
    let explosion2:SKAction = SKAction.playSoundFileNamed("explosion2.caf", waitForCompletion: false)
    let loud_bomb:SKAction = SKAction.playSoundFileNamed("loud_bomb.caf", waitForCompletion: false)
    let ricochet:SKAction = SKAction.playSoundFileNamed("ricochet.caf", waitForCompletion: false)
    let drone:SKAction = SKAction.playSoundFileNamed("drone.caf", waitForCompletion: false)
    
    let fail0:SKAction = SKAction.playSoundFileNamed("fail0.caf", waitForCompletion: false)
    let fail1:SKAction = SKAction.playSoundFileNamed("fail1.caf", waitForCompletion: false)
    let fail2:SKAction = SKAction.playSoundFileNamed("fail2.caf", waitForCompletion: false)
    
    let success0:SKAction = SKAction.playSoundFileNamed("success0.caf", waitForCompletion: false)
    let success1:SKAction = SKAction.playSoundFileNamed("success1.caf", waitForCompletion: false)
    let success2:SKAction = SKAction.playSoundFileNamed("success2.caf", waitForCompletion: false)
    



    
    let playerBase:SKSpriteNode = SKSpriteNode(imageNamed: "playerBase")
    let turret:SKSpriteNode = SKSpriteNode(imageNamed: "turret")
    let target:SKSpriteNode = SKSpriteNode(imageNamed: "target")
   
    var ground:SKSpriteNode = SKSpriteNode()
    var screenWidth:CGFloat = 0
    var screenHeight:CGFloat = 0
    var isPhone:Bool = true
    let loopingBG:SKSpriteNode = SKSpriteNode(imageNamed: "stars")
    let loopingBG2:SKSpriteNode = SKSpriteNode(imageNamed: "stars")
    let moon:SKSpriteNode = SKSpriteNode(imageNamed: "moon")
    
    let pauseButton:SKSpriteNode = SKSpriteNode(imageNamed: "pauseButton")
    
    
    
    var levelLabel:SKLabelNode = SKLabelNode(fontNamed: "BM germar")
    var statsLabel:SKLabelNode = SKLabelNode(fontNamed: "BM germar")
    var scoreLabel:SKLabelNode = SKLabelNode(fontNamed: "BM germar")
    
    var health:Int = 1
    var healthMeter:SKSpriteNode = SKSpriteNode(imageNamed: "healthMeter1")
    
    let tapRec = UITapGestureRecognizer()
    let pauseTap = UITapGestureRecognizer()

    
    
    let rotateRec = UIPanGestureRecognizer()
    var offset:CGFloat = 0
    let length:CGFloat = 200
    var theRotation:CGFloat = 0
    
    var activeBase:CGPoint = CGPoint.zero
    
    var droneSpeed:CFTimeInterval = 5
    var missileRate:CFTimeInterval = 2
    
    var baseArray = [CGPoint]()
  
    var level:Int = 1
    var attacksLaunched:Int = 0
    var attacksTotal:Int = 50
    var droneHowOften:UInt32 = 30
    var score:Int = 0
    
    
    var bgSoundPlayer:AVAudioPlayer?
    
    override func didMove(to view: SKView) {
        /* Setup your scene here */
        
        
        if (UIDevice.current.userInterfaceIdiom == .pad) {
            
            isPhone = false
            
        } else {
            
            isPhone = true
        }
       
        self.anchorPoint = CGPoint(x: 0.5, y: 0.0)
        
        self.backgroundColor = SKColor.black
        
        physicsWorld.contactDelegate = self
        physicsWorld.gravity = CGVector(dx:0, dy:-0.1)
        
        screenWidth = self.view!.bounds.width
        screenHeight = self.view!.bounds.height
        
        setLevelVars()
        
        
        createGround()
        addPlayer()
        
        
        
        baseArray.append(CGPoint( x: screenWidth * 0.15, y: ground.position.y ))
        baseArray.append(CGPoint( x: screenWidth * 0.3, y: ground.position.y ))
        baseArray.append(CGPoint( x: screenWidth * 0.45, y: ground.position.y ))
        
        baseArray.append(CGPoint( x: -screenWidth * 0.15, y: ground.position.y ))
        baseArray.append(CGPoint( x: -screenWidth * 0.3, y: ground.position.y ))
        baseArray.append(CGPoint( x: -screenWidth * 0.45, y: ground.position.y ))
        
        addBases()
        
        
        rotateRec.addTarget(self, action:#selector(GameScene.rotatedView(_:)))
        self.view!.addGestureRecognizer(rotateRec)
        
        tapRec.addTarget(self, action:#selector(GameScene.tappedView))
        tapRec.numberOfTouchesRequired = 1
        tapRec.numberOfTapsRequired = 1
        self.view!.addGestureRecognizer(tapRec)
        
       
        
       // createFiringParticles( CGPoint(x: 0, y: 0),  force: CGVector(dx: 0, dy: 20))
        
        
        ///////////////////////
        
        addChild(loopingBG)
        addChild(loopingBG2)
        addChild(moon)
        
        loopingBG.zPosition = -200
        loopingBG2.zPosition = -200
        moon.zPosition = -199
        
        startLoopingBackground()
        
        startGame()
        
        createLevelLabel()
        createStatsLabel()
        createScoreLabel()
        
        createInstructionLabel()
        
        playBackgroundSound("levelsound")
        
        updateAllLabels()
        
        addPauseButton()
    }
    
    func updateAllLabels(){
        
        let highScoreDefault = UserDefaults.standard
        
        if highScoreDefault.value(forKey: "highscore") != nil {
            score = highScoreDefault.value(forKey: "highscore") as! Int
            scoreLabel.text = "Score: " + String(score)
        }
        
        if highScoreDefault.value(forKey: "currentLevel") != nil {
            level = highScoreDefault.value(forKey: "currentLevel") as! Int
            levelLabel.text = "Level: " + String(level)
        }
        
        if highScoreDefault.value(forKey: "attacksLaunched") != nil {
            attacksLaunched = highScoreDefault.value(forKey: "attacksLaunched") as! Int
        }
        
        if highScoreDefault.value(forKey: "attacksTotal") != nil {
            attacksTotal = highScoreDefault.value(forKey: "attacksTotal") as! Int
            statsLabel.text = "Wave: " + String(attacksLaunched) + "/" + String(attacksTotal)
        }
 
    }
    
    func startGame(){
        
        initiateEnemyFiring()
        
       // startDotLoop()
        
        startGameOverTesting()
        
        initiateDrone()
        
        createMainLabel("Defend!")
        
        
        
        clearOutOfSceneItems()
        
    }
    
    
    func  clearOutOfSceneItems(){
    
        clearBullets()
        clearEnemyMissiles()
        
       
        
        let wait:SKAction = SKAction.wait(forDuration: 2)
        let block:SKAction = SKAction.run(clearOutOfSceneItems)
        let seq:SKAction = SKAction.sequence([wait, block])
        self.run(seq, withKey:"clearAction")
    
    }
        
    
    func setLevelVars(){
        
        attacksTotal = level * 25
         //attacksTotal = level * 100
        
        if (level == 1 ){
            
            droneHowOften = 30
            droneSpeed = 4
            missileRate = 3
            
        } else if (level == 2){
            
            droneHowOften = 20
            droneSpeed = 3
            missileRate = 2.5
            
        } else if (level == 3){
            
            droneHowOften = 15
            droneSpeed = 2
            missileRate = 2
            
        } else {
        
            droneHowOften = 10
            droneSpeed = 2
            missileRate = 1.25
            
        }
        
    }
    
    
    
    func initiateDrone(){        
        
        let block:SKAction = SKAction.run(launchDrone)
        let wait:SKAction = SKAction.wait(forDuration: 10)
        let seq:SKAction = SKAction.sequence([wait, block])
        self.run(seq)
        
    }
    
    func launchDrone(){
        
        playSound(soundVariable: drone)
        
        let theDrone:Drone = Drone()
        theDrone.createDrone()
        addChild(theDrone)
        theDrone.position = CGPoint(x: (screenWidth / 2) + theDrone.droneNode.size.width, y: screenHeight * 0.8)
        
        let move:SKAction = SKAction.moveBy(x: -(screenWidth + (theDrone.droneNode.size.width * 2)) , y: 0, duration: 10)
        let remove:SKAction = SKAction.removeFromParent()
        let seq:SKAction = SKAction.sequence([move, remove])
        
        theDrone.run(seq)
        
        
        let randomDrop = arc4random_uniform( 6 )
        let waitToDrop:SKAction = SKAction.wait( forDuration: CFTimeInterval(randomDrop) + 2)
        let blockDrop:SKAction = SKAction.run(dropBombFromDrone)
        let dropSequence:SKAction = SKAction.sequence([waitToDrop, blockDrop])
        self.run(dropSequence, withKey:"dropBombAction")
        
        
        
        // launch next drone
        
        
        let randomTime = arc4random_uniform( droneHowOften )
        
        let block:SKAction = SKAction.run(launchDrone)
        let wait:SKAction = SKAction.wait( forDuration: CFTimeInterval(randomTime) + 10)
        let seq2:SKAction = SKAction.sequence([wait, block])
        self.run(seq2, withKey:"droneAction")
        
    }
    
    func dropBombFromDrone(){
        
        
        attacksLaunched += 1
        updateStats()
        
        var dronePosition:CGPoint = CGPoint.zero
        
        self.enumerateChildNodes(withName: "drone") {
            node, stop in
            
            dronePosition = node.position
            
        }
        
        
        let droneBomb:SKSpriteNode = SKSpriteNode(imageNamed: "droneBomb")
        droneBomb.name = "droneBomb"
        droneBomb.position = CGPoint(x: dronePosition.x, y: dronePosition.y - 45)
        
        droneBomb.physicsBody = SKPhysicsBody(circleOfRadius: droneBomb.size.width / 3 )
        droneBomb.physicsBody!.categoryBitMask = BodyType.enemyBomb.rawValue
        droneBomb.physicsBody!.contactTestBitMask = BodyType.base.rawValue | BodyType.bullet.rawValue
        droneBomb.physicsBody!.isDynamic = true
        droneBomb.physicsBody!.affectedByGravity = false
        droneBomb.physicsBody!.allowsRotation = false
        
        self.addChild(droneBomb)
        
        let scaleY:SKAction = SKAction.scaleX(by: 1, y:1.5, duration:0.5)
        droneBomb.run(scaleY)
        
        let move:SKAction = SKAction.move(to: activeBase, duration: droneSpeed)
        droneBomb.run(move)
        
        
    }
    
    
    
    func initiateEnemyFiring(){
        
     
        
        let block:SKAction = SKAction.run(launchEnemyMissile)
        let wait:SKAction = SKAction.wait(forDuration: missileRate)
        let seq:SKAction = SKAction.sequence([block, wait])
        let repeated:SKAction = SKAction.repeatForever(seq)
        self.run(repeated, withKey:"enemyFiringAction")
    }
    
    
    
    func launchEnemyMissile(){
        
        attacksLaunched += 1
        updateStats()
        
        let randomX = arc4random_uniform( UInt32(screenWidth) )
        let missile:EnemyMissile = EnemyMissile()
        missile.createMissile("enemyMissile")
        addChild(missile)
        missile.position = CGPoint( x: CGFloat(randomX) - (screenWidth / 2), y: screenHeight + 50)
        
        
        let randomVecX = arc4random_uniform( 20 )
        
        let vecX:CGFloat = CGFloat(randomVecX) / 10
        
        
        if ( missile.position.x < 0) {
            
            // on left on left side of screen
            //missile.physicsBody?.applyForce(CGVector(dx: 10, dy: 0))
            missile.physicsBody?.applyImpulse(CGVector(dx: vecX, dy: 0))
            
        } else {
            // on right side of screen
            // missile.physicsBody?.applyForce(CGVector(dx: -10, dy: 0))
             missile.physicsBody?.applyImpulse(CGVector(dx: -vecX, dy: 0))
           
        }
        
        
    }
    
   
    func startDotLoop(){
        
        
        
        let block:SKAction = SKAction.run(addDot)
        let wait:SKAction = SKAction.wait(forDuration: 1 / 60)
        let seq:SKAction = SKAction.sequence([block, wait])
        let repeated:SKAction = SKAction.repeatForever(seq)
        self.run(repeated, withKey:"dotAction")
        
        
    }
    func addDot(){
        
        self.enumerateChildNodes(withName: "enemyMissile") {
            node, stop in
            
        
        let dot:SKSpriteNode = SKSpriteNode(imageNamed: "dot")
        dot.position = node.position
        self.addChild(dot)
        dot.zPosition = -1
        dot.xScale = 0.3
        dot.yScale = 0.3
        let fade:SKAction = SKAction.fadeAlpha(to: 0.0, duration: 3)
        let grow:SKAction = SKAction.scale(to: 3.0, duration: 3)
        let color:SKAction = SKAction.colorize(with: SKColor.red, colorBlendFactor: 1, duration: 3)
        let group:SKAction = SKAction.group([fade, grow, color ])
        let remove:SKAction = SKAction.removeFromParent()
        let seq:SKAction = SKAction.sequence([ group, remove])
        dot.run(seq)
            
        }
        
        
        
    }
    
   
    
    
    
    func startLoopingBackground(){
        
        resetLoopingBackground()
        
        let move:SKAction = SKAction.moveBy(x: -loopingBG2.size.width, y: 0, duration: 80)
        let moveBack:SKAction = SKAction.moveBy(x: loopingBG2.size.width, y: 0, duration: 0)
        let seq:SKAction = SKAction.sequence([move, moveBack])
        let repeated:SKAction = SKAction.repeatForever(seq)
        
        loopingBG.run(repeated)
        loopingBG2.run(repeated)
        
        
        let moveMoon:SKAction = SKAction.moveBy(x: -screenWidth * 2, y: 0, duration: 60)
        let moveMoonBack:SKAction = SKAction.moveBy(x: screenWidth * 2, y: 0, duration: 0)
        let seqMoon:SKAction = SKAction.sequence([moveMoon, moveMoonBack])
        let repeatMoon:SKAction = SKAction.repeatForever(seqMoon)
        
        moon.run(repeatMoon)
        
    }
    
    func resetLoopingBackground(){
        
   
            
        loopingBG.position = CGPoint(x: 0, y: loopingBG2.size.height / 2 )
        loopingBG2.position = CGPoint(x: loopingBG2.size.width, y: loopingBG2.size.height / 2 )
       
        
        moon.position = CGPoint(x: (screenWidth / 2) + moon.size.width, y: screenHeight / 2 )
        
    }
    
    
    
    func addPlayer(){
        
        addChild(playerBase)
        playerBase.zPosition = 100
        playerBase.position = CGPoint(x: 0, y: ground.position.y + playerBase.size.height / 2)
        playerBase.physicsBody = SKPhysicsBody(circleOfRadius: playerBase.size.width / 2 )
        playerBase.physicsBody!.categoryBitMask = BodyType.playerBase.rawValue
        playerBase.physicsBody!.isDynamic = false
        
        
        addChild(turret)
        turret.zPosition = 99
        
        turret.anchorPoint = CGPoint(x: 0.5, y: 0.0)
        turret.position = CGPoint(x: 0, y: playerBase.position.y )
        
        
        
        addChild(target)
        turret.zPosition = 98
        target.position = CGPoint(x: turret.position.x, y: turret.position.y + length)
        
        
        addChild(healthMeter)
        healthMeter.zPosition = 1000
        healthMeter.position = CGPoint(x: 0, y: playerBase.position.y - 20)
        
        
    }
    
    func addPauseButton(){
        pauseButton.zPosition = 1000
        pauseButton.position = CGPoint( x: self.frame.width/2 - 20, y: playerBase.position.y - 18)
        pauseButton.color = UIColor.white
        addChild(pauseButton)
        
        pauseTap.addTarget(self, action:#selector(GameScene.tappedView))
        pauseTap.numberOfTouchesRequired = 1
        pauseTap.numberOfTapsRequired = 1
        self.pauseButton.addGestureRecognizer(pauseTap)

        
    }
    
    func createGround() {
        
        let theSize:CGSize = CGSize(width: screenWidth, height: 70)
        let tex:SKTexture = SKTexture(imageNamed: "rocky_ground")
      
        ground = SKSpriteNode(texture: tex, color: SKColor.clear, size: theSize)
        ground.physicsBody = SKPhysicsBody(rectangleOf:theSize)
        ground.physicsBody!.categoryBitMask = BodyType.ground.rawValue
        ground.physicsBody!.contactTestBitMask = BodyType.enemyMissile.rawValue
        ground.physicsBody!.isDynamic = false
        
       
        addChild(ground)
        
        if ( isPhone == true) {
            
            ground.position = CGPoint(x: ground.position.x , y: 0)
            
        } else {
            
            ground.position = CGPoint(x: ground.position.x , y: theSize.height / 2)
        }
        
        
        ground.zPosition = 500
        
        
    }
    
    func addBases(){
        
        for item in baseArray {
            
            let base:Base = Base(imageNamed:"base")
            addChild(base)
            base.position = CGPoint(x: item.x, y: item.y + base.size.height / 2)
            
        }
        
        
    }
    
    
    
    func rotatedView(_ sender:UIPanGestureRecognizer) {
        
        let translation = sender.translation(in: self.view)        
        
        
        if (sender.state == .began) {
            
            //do anything you want when the rotation gesture has begun
           
            
            
            let fade:SKAction = SKAction.fadeAlpha(to: 1, duration: 0.5)
            target.run(fade)
            
            
        }
        
        if (sender.state == .changed) {
            
            //do anything you want when the rotation gesture has begun
    
            
            theRotation = CGFloat( -translation.x/100) + offset
           // theRotation = theRotation * -1
            
            
            let maxRotation:CGFloat = 1.4
            
            if (theRotation < -maxRotation) {
                
                theRotation = -maxRotation
                
            } else if (theRotation > maxRotation) {
                
                theRotation = maxRotation
                
            }
            
            turret.zRotation = theRotation
            target.zRotation = theRotation
            
            //println(theRotation)
            
            
            let xDist:CGFloat = sin(theRotation) * length
            let yDist:CGFloat = cos(theRotation) * length
            
            target.position = CGPoint( x: turret.position.x - xDist, y: turret.position.y + yDist)
                
            
            
        }
        
        if (sender.state == .ended) {
            
            //do anything you want when the rotation gesture has ended
           
            
            self.offset = theRotation
            
        }
        
        
    }
    
    
    func tappedView() {
        
         playSound(soundVariable: theSound)
        
        createBullet()
        
        
        rattle(playerBase)
        rattle(turret)
    }
    
    func rattle(_ node:SKSpriteNode) {
        
        let rattleUp:SKAction = SKAction.moveBy(x: 0, y:5, duration: 0.05)
        let rattleDown:SKAction = SKAction.moveBy(x: 0, y:-5, duration: 0.05)
        let seq:SKAction = SKAction.sequence([rattleUp, rattleDown])
        let repeated:SKAction = SKAction.repeat(seq, count: 3)
        
        node.run(repeated)
        
        
    }
    
    func createFiringParticles(_ location:CGPoint, force:CGVector){
        
  
       
        guard let fireEmitter = SKEmitterNode(fileNamed: "FireParticles") else{
            return
        }
        
        fireEmitter.position = location
        fireEmitter.name = "fireEmitter"
        fireEmitter.zPosition = 1
        fireEmitter.targetNode = self
        fireEmitter.numParticlesToEmit = 50
        
        fireEmitter.xAcceleration = force.dx
        fireEmitter.yAcceleration = -force.dy
        
        self.addChild(fireEmitter)
        

    }
    
    
    func createBullet(){
        
        let bullet:SKSpriteNode = SKSpriteNode(imageNamed:"bullet")
        bullet.physicsBody = SKPhysicsBody(circleOfRadius: bullet.size.width / 3 )
        bullet.physicsBody!.categoryBitMask = BodyType.bullet.rawValue
        bullet.zRotation = theRotation
       
        
        
        let xDist:CGFloat = sin(theRotation) * 70
        let yDist:CGFloat = cos(theRotation) * 70
        
        let forceXDist:CGFloat = sin(theRotation) * 250
        let forceYDist:CGFloat = cos(theRotation) * 250
        
        bullet.position = CGPoint( x: turret.position.x - xDist, y: turret.position.y + yDist)
        
       
        
        addChild(bullet)
        
        let theForce:CGVector = CGVector(dx: turret.position.x - forceXDist, dy: turret.position.y +  forceYDist)
        
        bullet.physicsBody!.applyForce(theForce)
        bullet.name = "bullet"
       
        
        //createFiringParticles( bullet.position,  force:theForce)
        
        
    }
    
    
     /*
   
    override func update(currentTime: CFTimeInterval) {
        //Called before each frame is rendered
        
        
        
    }
    
    */

    
    func clearBullets(){
        
        self.enumerateChildNodes(withName: "bullet") {
            node, stop in
            
            
            if ( node.position.x < -(self.screenWidth / 2)  ) {
                node.removeFromParent()
                
                
            } else if ( node.position.x > (self.screenWidth / 2)  ) {
                
                node.removeFromParent()
                
                
            } else if (node.position.y > self.screenHeight  ) {
                
               
                node.removeFromParent()
                
            }
            
            
            
        }

        
        
    }
    
    func clearEnemyMissiles(){
        
        self.enumerateChildNodes(withName: "enemyMissile") {
            node, stop in
            
            
            if ( node.position.x < -(self.screenWidth / 2)  ) {
               
                node.removeFromParent()
                
                
            } else if ( node.position.x > (self.screenWidth / 2)  ) {
              
                node.removeFromParent()
                
                
            }
            
            
        }
        
        
        
    }
    
    
    
    
    
    func didBegin(_ contact: SKPhysicsContact) {
        
        
        _ = contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask
        
        
        //// check bullet and base
        
        
        //enemyMissile and player bullet
        
        if (contact.bodyA.categoryBitMask == BodyType.enemyMissile.rawValue  && contact.bodyB.categoryBitMask == BodyType.bullet.rawValue ) {
            
            
            if let missile = contact.bodyA.node! as? EnemyMissile {
                
                let thePoint:CGPoint = missile.position
                
                if (  missile.hit() == true ) {
                    
                    createExplosion(thePoint , image:"explosion")
                    updateScore(15)
                     playSound(soundVariable: explosion1)
                    
                } else {
                    //
                    updateScore(5)
                     playSound(soundVariable: ricochet)
                    
                }
                
            }
            
            
            contact.bodyB.node?.name = "removeNode"
            
            
            
            
        } else if (contact.bodyA.categoryBitMask == BodyType.bullet.rawValue  && contact.bodyB.categoryBitMask == BodyType.enemyMissile.rawValue ) {
            
            if let missile = contact.bodyB.node! as? EnemyMissile {
                
                
                let thePoint:CGPoint = missile.position
                
                if (  missile.hit() == true ) {
                    
                    createExplosion(thePoint , image:"explosion")
                    updateScore(15)
                    playSound(soundVariable: explosion1)
                } else {
                    //
                    updateScore(5)
                    playSound(soundVariable: ricochet)
                    
                }
                
                
            }
            
            contact.bodyA.node?.name = "removeNode"
            
            
            
        }
        
        //enemyBomb and player bullet
        
       else if (contact.bodyA.categoryBitMask == BodyType.enemyBomb.rawValue  && contact.bodyB.categoryBitMask == BodyType.bullet.rawValue ) {
            
            
            createExplosion(contact.bodyA.node!.position , image:"explosion2")
            
            contact.bodyA.node?.name = "removeNode"
            contact.bodyB.node?.name = "removeNode"
            
            updateScore(50)
            
            playSound(soundVariable: loud_bomb)
            
            
        } else if (contact.bodyA.categoryBitMask == BodyType.bullet.rawValue  && contact.bodyB.categoryBitMask == BodyType.enemyBomb.rawValue ) {
            
            createExplosion(contact.bodyB.node!.position , image:"explosion2")
            
            contact.bodyA.node?.name = "removeNode"
            contact.bodyB.node?.name = "removeNode"
            
            updateScore(50)
            
            playSound(soundVariable: loud_bomb)
            
        }
        
        
        
        else if (contact.bodyA.categoryBitMask == BodyType.base.rawValue  && contact.bodyB.categoryBitMask == BodyType.bullet.rawValue ) {
            
            contact.bodyB.node?.name = "removeNode"
            
            
        } else if (contact.bodyA.categoryBitMask == BodyType.bullet.rawValue  && contact.bodyB.categoryBitMask == BodyType.base.rawValue ) {
            
            contact.bodyA.node?.name = "removeNode"
            
        }

        
        
        //// check playerBase and enemyMissile
        
        else if (contact.bodyA.categoryBitMask == BodyType.enemyMissile.rawValue  && contact.bodyB.categoryBitMask == BodyType.playerBase.rawValue ) {
            
            
            if let missile = contact.bodyA.node! as? EnemyMissile {
                
                missile.destroy()
                createExplosion(missile.position , image:"explosion")
            }
            subtractHealth()
            
            playSound(soundVariable: explosion2)
            
        } else if (contact.bodyA.categoryBitMask == BodyType.playerBase.rawValue  && contact.bodyB.categoryBitMask == BodyType.enemyMissile.rawValue ) {
            
            
            if let missile = contact.bodyB.node! as? EnemyMissile {
                
                missile.destroy()
                createExplosion(missile.position , image:"explosion")
                
                
            }
            subtractHealth()
            
            playSound(soundVariable: explosion2)
            
        }
        
      
       
        
        //// check ground and enemyMissile
        
       else if (contact.bodyA.categoryBitMask == BodyType.enemyMissile.rawValue  && contact.bodyB.categoryBitMask == BodyType.ground.rawValue ) {
            
           
            
            if let missile = contact.bodyA.node! as? EnemyMissile {
                
                missile.destroy()
                createExplosion(missile.position , image:"explosion")
            }
        
            playSound(soundVariable: explosion2)
            
        } else if (contact.bodyA.categoryBitMask == BodyType.ground.rawValue  && contact.bodyB.categoryBitMask == BodyType.enemyMissile.rawValue ) {
           
            
            if let missile = contact.bodyB.node! as? EnemyMissile {
                
               missile.destroy()
               createExplosion(missile.position , image:"explosion")
            }
        
            playSound(soundVariable: explosion2)
            
        }
        
       

        
        
        //enemyMissile and base
        
       else if (contact.bodyA.categoryBitMask == BodyType.enemyMissile.rawValue  && contact.bodyB.categoryBitMask == BodyType.base.rawValue ) {
            
            
            if let missile = contact.bodyA.node! as? EnemyMissile {
                
                    
                    if let base = contact.bodyB.node! as? Base {
                        
                        base.hit( missile.damagePoints )
                        
                    }
                    
                
                
                missile.destroy()
                createExplosion(missile.position , image:"explosion")
               
            }
            
           
            playSound(soundVariable: explosion2)
            

            
        } else if (contact.bodyA.categoryBitMask == BodyType.base.rawValue  && contact.bodyB.categoryBitMask == BodyType.enemyMissile.rawValue ) {
            
            if let missile = contact.bodyB.node! as? EnemyMissile {
                
                
                    
                    if let base = contact.bodyA.node! as? Base {
                        
                        base.hit(missile.damagePoints)
                        
                    }
                    
                
                
                missile.destroy()
                createExplosion(missile.position , image:"explosion")
            }
            
            
            playSound(soundVariable: explosion2)
            
        }
        
        //enemyBomb and base
        
        else if (contact.bodyA.categoryBitMask == BodyType.enemyBomb.rawValue  && contact.bodyB.categoryBitMask == BodyType.base.rawValue ) {
            
            
                if let base = contact.bodyB.node! as? Base {
                    
                    base.hit( base.maxDamage)
                    
                }
            
                 createExplosion(contact.bodyA.node!.position , image:"explosion2")
                 contact.bodyA.node?.name = "removeNode"
        
                playSound(soundVariable: explosion2)
            
            
        } else if (contact.bodyA.categoryBitMask == BodyType.base.rawValue  && contact.bodyB.categoryBitMask == BodyType.enemyBomb.rawValue ) {
            
           
                
                if let base = contact.bodyA.node! as? Base {
                    
                    base.hit(base.maxDamage)
                    
                }
                
            
                createExplosion(contact.bodyB.node!.position , image:"explosion2")
                contact.bodyB.node?.name = "removeNode"
        
                playSound(soundVariable: explosion2)
            
            
        }
        
        
    }

    
    
    func createExplosion(_ atLocation:CGPoint , image:String  ) {
        
        let explosion:SKSpriteNode = SKSpriteNode(imageNamed: image)
        explosion.position = atLocation
        self.addChild(explosion)
        explosion.zPosition = 1
        explosion.xScale = 0.1
        explosion.yScale = 0.1
        let grow:SKAction = SKAction.scale(to: 1.0, duration: 0.5)
         grow.timingMode = .easeOut
        let color:SKAction = SKAction.colorize(with: SKColor.white, colorBlendFactor: 0.5, duration: 0.5)
        
        let group:SKAction = SKAction.group([grow, color ])
       
        
        
        let fade:SKAction = SKAction.fadeAlpha(to: 0.0, duration: 1)
          fade.timingMode = .easeIn
        let shrink:SKAction = SKAction.scale(to: 0.8, duration: 1)
        
        let group2:SKAction = SKAction.group([fade, shrink ])
      
        
        let remove:SKAction = SKAction.removeFromParent()
        let seq:SKAction = SKAction.sequence([ group, group2, remove])
        explosion.run(seq)
        
        
    }
    
    func startGameOverTesting(){
        
        
        
        let block:SKAction = SKAction.run(gameOverTest)
        let wait:SKAction = SKAction.wait(forDuration: 1)
        let seq:SKAction = SKAction.sequence([block, wait])
        let repeated:SKAction = SKAction.repeatForever(seq)
        self.run(repeated, withKey:"gameOverTest")
        
        
    }
    
    func gameOverTest() {
        
        var destroyedBases:Int = 0
        
        self.enumerateChildNodes(withName: "base") {
            node, stop in
            
           
            
            if let someBase:Base = node as? Base {
                
                if (someBase.alreadyDestroyed) {
                    
                    destroyedBases += 1
                    
                } else {
                    
                   
                   self.activeBase = someBase.position
                    
                }
                
            }
            
            
            if ( destroyedBases == self.baseArray.count) {
                
                self.gameOver()
                
            }
            
            
            
        }
        
    }
    
    func explodeAllMissiles(){
        
        
        playSound(soundVariable: explosion1)
        
        self.enumerateChildNodes(withName: "enemyMissile") {
            node, stop in
            
            
            if let enemyMissile:EnemyMissile = node as? EnemyMissile {
                
                self.createExplosion(enemyMissile.position, image: "explosion")
                enemyMissile.destroy()
                
            }
            
        }
        
        self.enumerateChildNodes(withName: "droneBomb") {
            node, stop in
            
            
            self.createExplosion(node.position, image: "explosion2")
            node.removeFromParent()
            
        }
        
        
    }
    
    
    func failSounds(){
        
         playRandomSound("fail", withRange: 3)
    }
    
    
    func gameOver() {
        
        
        let wait:SKAction = SKAction.wait(forDuration: 2)
        let block:SKAction = SKAction.run(failSounds)
        let seq:SKAction = SKAction.sequence( [wait, block])
        self.run(seq)
        
       
    
        createMainLabel("Game Over")
        
        explodeAllMissiles()
        stopGameActions()
        moveDownBases()
        
        let wait2:SKAction = SKAction.wait(forDuration: 6)
        let block2:SKAction = SKAction.run(restartGame )
        let seq2:SKAction = SKAction.sequence( [wait2, block2 ] )
        self.run(seq2)

        
    }
    
    func restartGame(){
        
        level = 1
        score = 0
        attacksLaunched = 0
        
        levelLabel.text = "Level: " + String(level)
        
        setLevelVars()
        
        startGame()
        resetHealth()
        
    }
    
    func stopGameActions(){
        
        
        self.removeAction(forKey: "gameOverTest")
        self.removeAction(forKey: "droneAction")
        self.removeAction(forKey: "enemyFiringAction")
        self.removeAction(forKey: "dotAction")
        self.removeAction(forKey: "clearAction")
        self.removeAction(forKey: "dropBombAction") 
        
        
    }
    
    func moveDownBases(){
        
         playSound(soundVariable: restoreHealth)
        
        
        self.enumerateChildNodes(withName: "base") {
            node, stop in
            
            
            
            if let someBase:Base = node as? Base {
                
               let wait:SKAction = SKAction.wait(forDuration: 2)
               let moveDown:SKAction = SKAction.moveBy(x: 0, y: -200, duration: 3)
               let block:SKAction = SKAction.run( someBase.revive )
               let moveUp:SKAction = SKAction.moveBy(x: 0, y: 200, duration: 1)
               let seq:SKAction = SKAction.sequence( [wait, moveDown, block, moveUp ] )
                someBase.run(seq)
                
            }
            
        }
        
        
    }
   
    
    
    func createLevelLabel() {
        
       
        levelLabel.horizontalAlignmentMode = .left
        levelLabel.verticalAlignmentMode = .center
        levelLabel.fontColor = SKColor.white
        levelLabel.text = "Level: " + String(level)
     
        levelLabel.zPosition = 300
        
        addChild(levelLabel)
        
        
        if (isPhone == true ) {
            
            levelLabel.position = CGPoint(x: (screenWidth / 2) * 0.7, y: screenHeight - 30 )
               levelLabel.fontSize = 20
        } else  {
             levelLabel.position = CGPoint(x: (screenWidth / 2) * 0.7, y: screenHeight - 30 )
               levelLabel.fontSize = 40
        }
        
        
        
    }
    func createStatsLabel() {
        
        
        statsLabel.horizontalAlignmentMode = .left
        statsLabel.verticalAlignmentMode = .center
        statsLabel.fontColor = SKColor.white
        statsLabel.text = "Wave: " + String(attacksLaunched) + "/" + String(attacksTotal)
        
        statsLabel.zPosition = 300
        
        addChild(statsLabel)
        
        
        if (isPhone == true ) {
            
            statsLabel.position = CGPoint(x: -(screenWidth / 2) * 0.9, y: screenHeight - 30 )
            statsLabel.fontSize = 20
        } else  {
            statsLabel.position = CGPoint(x: -(screenWidth / 2) * 0.9, y: screenHeight - 30 )
            statsLabel.fontSize = 40
        }
        
        
        
    }
    func createScoreLabel() {
        
        
        scoreLabel.horizontalAlignmentMode = .center
        scoreLabel.verticalAlignmentMode = .center
        scoreLabel.fontColor = SKColor.white
        scoreLabel.text = "Score: " + String(score)
       
        scoreLabel.zPosition = 300
        
        addChild(scoreLabel)
        
        
        if (isPhone == true ) {
            
            scoreLabel.position = CGPoint(x: 0, y: screenHeight - 30 )
             scoreLabel.fontSize = 20
            
        } else  {
            scoreLabel.position = CGPoint(x: 0, y: screenHeight - 30 )
             scoreLabel.fontSize = 40
            
        }
        
        
        
    }
    
    
    func createMainLabel(_ theText:String) {
        
        
        let bigMiddleLabel:SKLabelNode = SKLabelNode(fontNamed: "BM germar")
        
        bigMiddleLabel.horizontalAlignmentMode = .center
        bigMiddleLabel.verticalAlignmentMode = .center
        bigMiddleLabel.fontColor = SKColor.white
        bigMiddleLabel.text = theText
        bigMiddleLabel.fontSize = 100
        bigMiddleLabel.zPosition = 300
        
        addChild(bigMiddleLabel)
        
        
        if (isPhone == true ) {
            
            bigMiddleLabel.position = CGPoint(x:0 , y: (screenHeight / 2) + 15 )
            
        } else  {
            bigMiddleLabel.position = CGPoint(x: 0 , y: screenHeight / 2 )
            
        }
        
        
        let wait:SKAction = SKAction.wait(forDuration: 2)
        let fade:SKAction = SKAction.fadeAlpha(to: 0, duration: 1)
        let remove:SKAction = SKAction.removeFromParent()
        let seq:SKAction = SKAction.sequence( [wait, fade, remove])
        bigMiddleLabel.run(seq)
        
        
        
    }
    func createInstructionLabel() {
        
        
        let instructionLabel:SKLabelNode = SKLabelNode(fontNamed: "BM germar")
        
        instructionLabel.horizontalAlignmentMode = .center
        instructionLabel.verticalAlignmentMode = .center
        instructionLabel.fontColor = SKColor.white
        instructionLabel.text = "Rotate Fingers to Swivel Turret, Tap to Fire"
        
        instructionLabel.zPosition = 300
        
        addChild(instructionLabel)
        
        
        if (isPhone == true ) {
            
            instructionLabel.position = CGPoint(x:0 , y: (screenHeight / 2) - 55 )
            instructionLabel.fontSize = 20
            
        } else  {
            instructionLabel.position = CGPoint(x: 0 , y: (screenHeight / 2) - 85 )
            instructionLabel.fontSize = 30
            
        }
        
        
        let wait:SKAction = SKAction.wait(forDuration: 2)
        let fade:SKAction = SKAction.fadeAlpha(to: 0, duration: 1)
        let remove:SKAction = SKAction.removeFromParent()
        let seq:SKAction = SKAction.sequence( [wait, fade, remove])
        instructionLabel.run(seq)
        
        
        
    }
    
    func updateScore(_ scoreToAdd:Int) {
        
        score = score + scoreToAdd
        
        scoreLabel.text = "Score: " + String(score)
        
        let highScoreDefault = UserDefaults.standard
        highScoreDefault.setValue(score, forKey: "highscore")
        highScoreDefault.synchronize()

    }
    
    func updateStats() {
        
         statsLabel.text = "Wave: " + String(attacksLaunched) + "/" + String(attacksTotal)
        
        let highScoreDefault = UserDefaults.standard
        highScoreDefault.setValue(attacksLaunched, forKey: "attacksLaunched")
        highScoreDefault.setValue(attacksTotal, forKey: "attacksTotal")
        highScoreDefault.synchronize()
        
        if ( attacksLaunched == attacksTotal){
            
            stopGameActions()
            createMainLabel("Success!")
            moveDownBases()
            explodeAllMissiles()
            
            let wait:SKAction = SKAction.wait(forDuration: 4)
            let block:SKAction = SKAction.run(levelUp)
            let seq:SKAction = SKAction.sequence( [wait, block])
            self.run(seq)
            
        }
    }
    
    func successSound(){
        
        playRandomSound("success", withRange: 3)
        
    }
    
    func levelUp(){
        
        let wait:SKAction = SKAction.wait(forDuration: 1)
        let block:SKAction = SKAction.run(successSound)
        let seq:SKAction = SKAction.sequence( [wait, block])
        self.run(seq)
        
        
        attacksLaunched = 0
        level += 1
        
        levelLabel.text = "Level: " + String(level)
        
        let highScoreDefault = UserDefaults.standard
        highScoreDefault.setValue(level, forKey: "currentLevel")
        highScoreDefault.synchronize()
        
        resetHealth()
        
        setLevelVars()
        
        startGame()
        
    }
    
    
    override func didSimulatePhysics() {
        
        self.enumerateChildNodes(withName: "removeNode") {
            node, stop in
            
            node.removeFromParent()
            
            
        }
    }
    
    
    func subtractHealth(){
        
        health = health + 1
        healthMeter.texture = SKTexture(imageNamed: "healthMeter" + String(health) )
        
        if (health == 6 ){
            
            gameOver()
        }
        
    }
    func resetHealth(){
        
        health = 1
        healthMeter.texture = SKTexture(imageNamed: "healthMeter" + String(health) )
        
        
        
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        
        for touch in (touches as Set<UITouch>) {
            let location = touch.location(in: self)
            
            if (location.x > (screenWidth / 2) * 0.9 && location.y > screenHeight * 0.9) {
            
                if (self.view?.isPaused == false) {
                    
                    self.view?.isPaused = true
                } else {
                    
                    self.view?.isPaused = false
                }
                
            }
        }
        
        
        
    }
    
    
    func playBackgroundSound(_ name:String) {
        
        
        if (bgSoundPlayer != nil) {
            
            bgSoundPlayer!.stop()
            bgSoundPlayer = nil
            
        }
        
        
        let fileURL:URL = Bundle.main.url( forResource: name , withExtension: "mp3")!
        
        do {
            bgSoundPlayer = try AVAudioPlayer(contentsOf: fileURL)
        } catch _ {
            bgSoundPlayer = nil
        }
        
        
        bgSoundPlayer!.volume = 0.5  //half volume
        bgSoundPlayer!.numberOfLoops = -1
        bgSoundPlayer!.prepareToPlay()
        bgSoundPlayer!.play()
        
        
    }
    
    
    func playSound(soundVariable : SKAction){
        
        
        self.run(soundVariable)
        
        
    }
    
    func playRandomSound(_ baseName:String, withRange:UInt32){
        
        // if withRange = 5, then the randomNum will be either 0, 1, 2, 3, or 4
        
        
        let randomNum = arc4random_uniform( withRange )
        
        if baseName == "fail"{
            
            switch randomNum {
                case 0:
                    playSound(soundVariable: fail0)
                case 1:
                    playSound(soundVariable: fail1)
                case 2:
                    playSound(soundVariable: fail2)

                default:
                    playSound(soundVariable: fail0)
            }
        }else if baseName == "success"{
            switch randomNum {
            case 0:
                playSound(soundVariable: success0)
            case 1:
                playSound(soundVariable: success1)
            case 2:
                playSound(soundVariable: success2)
                
            default:
                playSound(soundVariable: success0)
            }
        }
        
    }
    
    func touchesBegan(touches: NSSet!, withEvent event: UIEvent!){
        var touch:UITouch = touches.anyObject() as! UITouch
        //pauseTap.text = "Pause"
        //pauseTap.fontSize = 50
        pauseButton.position = CGPoint(self.frame.size.width/2, self.frame.size.height/2)
        
        /* bouton play/pause */
        
        var locationPause: CGPoint = touch.locationInNode(self)
        if self.nodeAtPoint(locationPause) == self.pause
        {
            addChild(pauseText) // add the text
            pause.removeFromParent ()  // to avoid error when you touch again
            self.runAction (SKAction.runBlock(self.pauseGame))
        }
        
    }
    
    
}
