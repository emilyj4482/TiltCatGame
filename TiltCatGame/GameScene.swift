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
        
        addBackgroundNode()
        addHouseNode()
        addCatFaceNode()
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
        
        addChild(houseNode)
    }
    
    private func addCatFaceNode() {
        let imageName = Cat.allCases.randomElement()?.rawValue ?? Cat.cheese.rawValue
        catFaceNode = SKSpriteNode(imageNamed: imageName)
        
        catFaceNode.size = CGSize(width: 60, height: 60)
        catFaceNode.position = CGPoint(x: frame.midX, y: frame.midY)
        
        addChild(catFaceNode)
    }
}
