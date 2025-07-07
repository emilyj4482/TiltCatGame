//
//  GameScene.swift
//  TiltCatGame
//
//  Created by EMILY on 08/07/2025.
//

import SpriteKit

class GameScene: SKScene {
    
    private let backgroundNode = SKSpriteNode(imageNamed: Assets.background.rawValue)
    private let houseNode = SKSpriteNode(imageNamed: Assets.house.rawValue)
    
    private var catFaceNode: SKSpriteNode!
    
    override func didMove(to view: SKView) {
        size = view.bounds.size
        
        setupFramePhysics()
        addBackgroundNode()
        addHouseNode()
        addCatFaceNode()
        
        physicsWorld.contactDelegate = self
    }
    
    private func setupFramePhysics() {
        physicsBody = SKPhysicsBody(edgeLoopFrom: frame)
        physicsBody?.categoryBitMask = PhysicsCategory.frame
        physicsBody?.collisionBitMask = PhysicsCategory.cat
        physicsBody?.contactTestBitMask = PhysicsCategory.none
    }
    
    private func addBackgroundNode() {
        backgroundNode.size = size
        backgroundNode.anchorPoint = .zero
        backgroundNode.zPosition = -1
        
        addChild(backgroundNode)
    }
    
    private func addHouseNode() {
        houseNode.size = CGSize(width: 70, height: 70)
        houseNode.position = CGPoint(x: frame.midX, y: size.height * 0.32)
        
        houseNode.physicsBody = SKPhysicsBody(texture: SKTexture(imageNamed: Assets.house.rawValue), size: houseNode.size)
        houseNode.physicsBody?.categoryBitMask = PhysicsCategory.house
        houseNode.physicsBody?.collisionBitMask = PhysicsCategory.none
        houseNode.physicsBody?.contactTestBitMask = PhysicsCategory.cat
        houseNode.physicsBody?.isDynamic = false
        
        addChild(houseNode)
    }
    
    private func addCatFaceNode() {
        let imageName = Cat.allCases.randomElement()?.rawValue ?? Cat.cheese.rawValue
        catFaceNode = SKSpriteNode(imageNamed: imageName)
        
        catFaceNode.size = CGSize(width: 60, height: 60)
        catFaceNode.position = CGPoint(x: frame.midX, y: frame.midY)
        
        catFaceNode.physicsBody = SKPhysicsBody(texture: SKTexture(imageNamed: imageName), size: catFaceNode.size)
        catFaceNode.physicsBody?.categoryBitMask = PhysicsCategory.cat
        catFaceNode.physicsBody?.collisionBitMask = PhysicsCategory.frame
        catFaceNode.physicsBody?.contactTestBitMask = PhysicsCategory.house
        catFaceNode.physicsBody?.isDynamic = true
        catFaceNode.physicsBody?.affectedByGravity = false
        catFaceNode.physicsBody?.allowsRotation = false
        
        addChild(catFaceNode)
    }
}

extension GameScene: SKPhysicsContactDelegate {
    
}
