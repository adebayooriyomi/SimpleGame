//
//  EnemyMissile.swift
//  Missile_Commando
//
//  Created by Justin Dike on 6/26/15.
//  Copyright (c) 2015 CartoonSmart. All rights reserved.
//

import Foundation
import SpriteKit

class EnemyMissile: SKNode {
    
     let fireEmitter = SKEmitterNode(fileNamed: "FireParticles")
    var missileNode:SKSpriteNode = SKSpriteNode()
    var imageName:String = ""
    
    var hitsToKill:Int = 1
    var hitCount:Int = 0
    var damagePoints:Int = 4
    
    
    var missileAnimation:SKAction?
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override init () {
        
        super.init()
        
        
    }
    
    func createMissile(_ theImage:String) {
        
        
        
        missileNode = SKSpriteNode(imageNamed: theImage)
        self.addChild(missileNode)
        
        let body:SKPhysicsBody = SKPhysicsBody(circleOfRadius: missileNode.size.width / 2.25, center:CGPoint(x: 0, y: 0))
        body.isDynamic = true
        body.affectedByGravity = true
        body.allowsRotation = false
        
        
        body.categoryBitMask = BodyType.enemyMissile.rawValue
        body.contactTestBitMask = BodyType.ground.rawValue | BodyType.bullet.rawValue  | BodyType.base.rawValue | BodyType.playerBase.rawValue
        
        self.physicsBody = body
        
        self.name = "enemyMissile"
        
        //addParticles()
        setUpAnimation()
        
    }
    
    func setUpAnimation() {
        
        var array = [String]()
        
       for i in 1 ... 10 {
      
            
            let nameString = String(format: "enemyMissile%i", i)
            
            array.append(nameString)
        }
        
        //create another array this time with SKTexture as the type (textures being the .png images)
        var atlasTextures:[SKTexture] = []
       
        
        for i in 0 ..< array.count {
            
            let texture:SKTexture = SKTexture(imageNamed: array[i])
            atlasTextures.insert(texture, at:i)
            
        }
        
        let atlasAnimation = SKAction.animate(with: atlasTextures, timePerFrame: 1.0/20, resize: true , restore:false )
        missileAnimation =  SKAction.repeatForever(atlasAnimation)
        
        missileNode.run(missileAnimation!, withKey:"animation")
        
        
    }
    
    
    
    
   
    
    func addParticles(){
        
    
        fireEmitter?.name = "fireEmitter"
        fireEmitter?.zPosition = -1
        fireEmitter?.targetNode = self
       
        fireEmitter?.particleLifetime = 1
        
        if fireEmitter != nil {
            self.addChild(fireEmitter!)
 
        }
    }
    
   
    
    
    func hit() ->Bool {
        
        hitCount += 1
        
        if ( hitCount == hitsToKill) {
            
            self.removeFromParent()
            return true
            
        } else {
            damagePoints = 1
            
            if fireEmitter != nil{
                fireEmitter!.numParticlesToEmit = 1
            }
            
            missileNode.removeAction(forKey: "animation")
            return false
        }
        
        
    }
    func destroy(){
        
       
            
            self.name = "removeNode"
       
        
        
    }
    
    
    
    
}
