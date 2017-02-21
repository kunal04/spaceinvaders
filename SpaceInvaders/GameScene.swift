//
//  GameScene.swift
//  SpaceInvaders
//
//  Created by Kunal kapadia on 5/2/17.
//  Copyright © 2017 Kunal kapadia. All rights reserved.
//

import SpriteKit
import GameplayKit
import CoreMotion


class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var starfield:SKEmitterNode!
    var starfieldNew:SKSpriteNode!
    var starfieldNew2:SKSpriteNode!
    var player:SKSpriteNode!
    var scoreLabel:SKLabelNode!
    var score:Int = 0 {
        didSet{
            scoreLabel.text = "Score: \(score)"
        }
    }
    
    var gameTimer:Timer!
    
    var possibleAliens = ["alien","alien2","alien3"]
    
    let alienCategory:UInt32 = 0x1 << 1
    let photoTorpedoCategory:UInt32 = 0x1 << 0
    
    

    
    
    
    override func didMove(to view: SKView) {
        
        //starfield
        starfieldNew = SKSpriteNode(imageNamed: "Background-HR")
        starfieldNew.anchorPoint = CGPoint(x: 0, y: 0)
        starfieldNew.position = CGPoint(x:0,y:0)
        self.addChild(starfieldNew)
        starfieldNew.zPosition = -1
        
        starfieldNew2 = SKSpriteNode(imageNamed: "Background-HR")
        starfieldNew2.anchorPoint = CGPoint(x: 0, y:0)
        starfieldNew2.position = CGPoint(x:0,y:4003)
        self.addChild(starfieldNew2)
        starfieldNew2.zPosition = -1
//        
//        print(starfieldNew.size.height)
//        print(starfieldNew.size.width)
//        print(self.frame.height)
//        print(self.frame.width)

        
        
        
        //player
        player = SKSpriteNode(imageNamed: "Spaceship")
        player.size.width = player.size.width / 5
        player.size.height = player.size.height / 5
        player.position =  CGPoint(x: self.frame.size.width / 2, y:player.size.height / 2 + 50)
        self.addChild(player)
        
        
        //physics
        self.physicsWorld.gravity = CGVector(dx: 0, dy: 0)
        self.physicsWorld.contactDelegate = self
        
        //score
        scoreLabel = SKLabelNode(text: "Score: 0")
        scoreLabel.position = CGPoint(x: 100, y: self.frame.size.height - 60)
        scoreLabel.fontSize = 36
        scoreLabel.fontColor = UIColor.white
        score = 0
        
        self.addChild(scoreLabel)
        
        //enemy
        gameTimer = Timer.scheduledTimer(timeInterval: 0.75, target: self, selector: #selector(addAlien), userInfo: nil, repeats: true)
        
        
        

        
    }
    
    func addAlien(){
        
        possibleAliens = GKRandomSource.sharedRandom().arrayByShufflingObjects(in: possibleAliens) as! [String]
        let alien = SKSpriteNode(imageNamed: possibleAliens[0])
        let randomAlienPosition = GKRandomDistribution(lowestValue: 0, highestValue: 414)
        let position = CGFloat(randomAlienPosition.nextInt())

        alien.position = CGPoint(x: position, y: self.frame.size.height + alien.size.height)
        
        alien.physicsBody = SKPhysicsBody(rectangleOf: alien.size)
        alien.physicsBody?.isDynamic = true
        alien.physicsBody?.categoryBitMask = alienCategory
        alien.physicsBody?.contactTestBitMask = photoTorpedoCategory
        alien.physicsBody?.collisionBitMask = 0
        
        
        
        self.addChild(alien)
        
        let animationDuration:TimeInterval = 1
        
        var actionArray = [SKAction]()

        actionArray.append(SKAction.move(to: CGPoint(x: position, y: -alien.size.height), duration: animationDuration))
        actionArray.append(SKAction.removeFromParent())
        
        alien.run(SKAction.sequence(actionArray))
    }

    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let location = 	touch.location(in: self)
            player.run(SKAction.moveTo(x: location.x, duration: 0.1))
        }
        fireTorpedo()
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let location = 	touch.location(in: self)
            player.run(SKAction.moveTo(x: location.x, duration: 0.1))
        }

    }
    
    
//    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
//        fireTorpedo()
//    }
    
    
    
    func fireTorpedo() {
        
        self.run(SKAction.playSoundFileNamed("torpedo.mp3", waitForCompletion: false))
        
        let torpedoNode = SKSpriteNode(imageNamed: "torpedo")
        torpedoNode.position = player.position
        torpedoNode.position.y += 5
        
        
        torpedoNode.physicsBody = SKPhysicsBody(circleOfRadius: torpedoNode.size.width / 2)
        torpedoNode.physicsBody?.isDynamic = true
        
        torpedoNode.physicsBody?.categoryBitMask = photoTorpedoCategory
        torpedoNode.physicsBody?.contactTestBitMask = alienCategory
        torpedoNode.physicsBody?.collisionBitMask = 0
        torpedoNode.physicsBody?.usesPreciseCollisionDetection = true
        
        self.addChild(torpedoNode)
        
        let animationDuration:TimeInterval = 0.7
        
        var actionArray = [SKAction]()
        
        actionArray.append(SKAction.move(to: CGPoint(x: player.position.x, y: self.frame.size.height + 10), duration: animationDuration))
        actionArray.append(SKAction.removeFromParent())
        
        torpedoNode.run(SKAction.sequence(actionArray))
        
        
    }
    
    
    
    
    
    
    
    
    
    func didBegin(_ contact: SKPhysicsContact) {
        var firstBody:SKPhysicsBody
        var secondBody:SKPhysicsBody
        
        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
            
            firstBody = contact.bodyA
            secondBody = contact.bodyB
        }else {
            firstBody = contact.bodyB
            secondBody = contact.bodyA
        }
        
        
        if (firstBody.categoryBitMask & photoTorpedoCategory) != 0 && (secondBody.categoryBitMask & alienCategory) != 0 {
            
            torpedoDidCollideWithAlien(torpedoNode: firstBody.node as! SKSpriteNode, alienNode: secondBody.node as! SKSpriteNode)
            
            
        }
    }
    
    
    func torpedoDidCollideWithAlien(torpedoNode:SKSpriteNode, alienNode:SKSpriteNode){
        
        let explosion = SKEmitterNode(fileNamed: "Explosion")!
        explosion.position = alienNode.position
        self.addChild(explosion)
        
        self.run(SKAction.playSoundFileNamed("explosion.mp3", waitForCompletion: false))
        
        torpedoNode.removeFromParent()
        alienNode.removeFromParent()
        
        
        self.run(SKAction.wait(forDuration: 2)){
            explosion.removeFromParent()
        }
        
        score += 5
    }
    
    
    

    
    
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
        starfieldNew.position = CGPoint(x: starfieldNew.position.x, y: starfieldNew.position.y - 4)
        starfieldNew2.position = CGPoint(x: starfieldNew2.position.x, y: starfieldNew2.position.y - 4)
        
        

        if starfieldNew.position.y < -4005 {
            starfieldNew.position.y = starfieldNew2.position.y + starfieldNew.size.height
        }
        if starfieldNew2.position.y < -4005 {
            starfieldNew2.position.y = starfieldNew.position.y + starfieldNew.size.height
        }
        

        
        
    }
}
