//
//  IntroScene.swift
//  MissileCommando
//
//  Created by Justin Dike on 7/1/15.
//  Copyright (c) 2015 CartoonSmart. All rights reserved.
//

import Foundation
import SpriteKit
import AVFoundation

class IntroScene: SKScene {
    
    var isPhone:Bool = true
    var screenWidth:CGFloat = 0
    var screenHeight:CGFloat = 0
    let instructionLabel:SKLabelNode = SKLabelNode(fontNamed: "BM germar")
    var introImage:SKSpriteNode?
    
    
    override func didMove(to view: SKView) {
        /* Setup your scene here */
        
        
        if (UIDevice.current.userInterfaceIdiom == .pad) {
            
            isPhone = false
            
        } else {
            
            isPhone = true
        }
        
        
        screenWidth = self.view!.bounds.width
        screenHeight  = self.view!.bounds.height
        
        print(screenWidth)
        print(screenHeight)
        
        self.backgroundColor = SKColor.black
        self.anchorPoint = CGPoint(x: 0.5, y: 0.0)
        
       
        var tex:SKTexture  = SKTexture(imageNamed: "intro_screen")
       
        if (UIDevice.current.userInterfaceIdiom == .pad) {
            
            //patches a bug with Xcode 7 where it is not recognizing asset catalog images specifically in the iPad slot,. I'd expect this if statement won't be needed in an upcoming update
             tex = SKTexture(imageNamed: "iPad_IntroScreen")
            
        }
        
        
        let theSize:CGSize = CGSize(width: screenWidth, height: screenHeight)
        introImage = SKSpriteNode(texture: tex, color: SKColor.clear, size: theSize)
        addChild(introImage!)
        introImage!.position = CGPoint(x: 0, y: screenHeight / 2)
        
        
        createInstructionLabel()
        
    }
    
    
    func createInstructionLabel() {
        
        
        instructionLabel.horizontalAlignmentMode = .center
        instructionLabel.verticalAlignmentMode = .center
        instructionLabel.fontColor = SKColor.white
        instructionLabel.text = "Touch to Begin Game"
        instructionLabel.zPosition = 1
        addChild(instructionLabel)
        
        if ( isPhone == true) {
            
            instructionLabel.position = CGPoint(x: 0, y: screenHeight * 0.15)
            instructionLabel.fontSize = 30
            
        } else {
            
            instructionLabel.position = CGPoint(x: 0, y: screenHeight * 0.20)
            instructionLabel.fontSize = 40
            
        }
        
        // Lets introduce SKActions
        
        let wait:SKAction = SKAction.wait(forDuration: 1)
        let fadeDown:SKAction = SKAction.fadeAlpha(to: 0, duration: 0.2)
        let fadeUp:SKAction = SKAction.fadeAlpha(to: 1, duration: 0.2)
        let seq:SKAction = SKAction.sequence( [wait, fadeDown, fadeUp] )
        let `repeat`:SKAction = SKAction.repeatForever(seq)
        instructionLabel.run(`repeat`)
        
    }
    
    
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        /* Called when a touch begins */
        
        let transition = SKTransition.reveal(with: SKTransitionDirection.down, duration: 1.0)
        let scene = GameScene(size: self.scene!.size)
        scene.scaleMode = SKSceneScaleMode.aspectFill
        
        self.scene!.view!.presentScene(scene, transition: transition)
        
        
        
        /*
        let fadeDown:SKAction = SKAction.fadeAlphaTo(0, duration: 0.2)
        let remove:SKAction = SKAction.removeFromParent()
        let seq:SKAction = SKAction.sequence( [fadeDown, remove] )
        
        instructionLabel.runAction(seq)
        introImage!.runAction(seq)
        */
        
    }
    
    override func update(_ currentTime: TimeInterval) {
        /* Called before each frame is rendered */
    }
    
}

