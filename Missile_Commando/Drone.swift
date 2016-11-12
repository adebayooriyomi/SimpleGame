//
//  Drone.swift
//  Missile_Commando
//
//  Created by Justin Dike on 6/30/15.
//  Copyright (c) 2015 CartoonSmart. All rights reserved.
//

import Foundation
import SpriteKit

class Drone:SKNode {
    

    var droneNode:SKSpriteNode = SKSpriteNode()
    
    var droneAnimation:SKAction?
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override init () {
        
        super.init()
        
        
    }

    func createDrone(){
        
        
        self.name = "drone"
        
        droneNode = SKSpriteNode(imageNamed:"drone1")
        self.addChild(droneNode)
        
        
        setUpAnimation()
        
        
    }
    
    
    func setUpAnimation() {
        
        let atlas = SKTextureAtlas (named: "drone")
        
        var array = [String]()
        
        //or setup an array with exactly the sequential frames start from 1
        
        
        //for var i=1; i <= 20; i += 1 {
        for i in 1 ... 20 {
        
            
            let nameString = String(format: "drone%i", i)
            
            array.append(nameString)
            
        }
        
        //create another array this time with SKTexture as the type (textures being the .png images)
        var atlasTextures:[SKTexture] = []
        
        
        
        //for (var i = 0; i < array.count; i++ ) {
            
        for i in 0 ..< array.count{
            
            let texture:SKTexture = atlas.textureNamed( array[i] )
            atlasTextures.insert(texture, at:i)
            
        }
        
        let atlasAnimation = SKAction.animate(with: atlasTextures, timePerFrame: 1.0/30, resize: true , restore:false )
        droneAnimation =  SKAction.repeatForever(atlasAnimation)
        
        droneNode.run(droneAnimation!, withKey:"animation")
        
        
    }

}
