//
//  GameScene.swift
//  TiltCatGame
//
//  Created by EMILY on 08/07/2025.
//

import SpriteKit
import CoreMotion

class GameScene: SKScene {
    
    private let motionManager = CMMotionManager()
    
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
        startDeviceMotionUpdates()
    }
    
    override func willMove(from view: SKView) {
        stopDeviceMotionUpdates()
    }
    
    private func setupFramePhysics() {
        physicsBody = SKPhysicsBody(edgeLoopFrom: frame)
        physicsBody?.categoryBitMask = PhysicsCategory.frame
        physicsBody?.collisionBitMask = PhysicsCategory.cat
        physicsBody?.contactTestBitMask = PhysicsCategory.none
        physicsBody?.restitution = 0.0
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
        catFaceNode.physicsBody?.restitution = 0.0
        catFaceNode.physicsBody?.linearDamping = 0.7    // Essential for natural movement
        catFaceNode.physicsBody?.angularDamping = 0.9   // Prevent unwanted rotation
        
        addChild(catFaceNode)
    }
}

extension GameScene: SKPhysicsContactDelegate {
    private func startDeviceMotionUpdates() {
        guard motionManager.isDeviceMotionAvailable else {
            print("[Error] Device motion is not available")
            return
        }
        
        // update interval - 60 updates per 1 second
        motionManager.deviceMotionUpdateInterval = 1.0 / 60.0
        
        // start device motion updates
        motionManager.startDeviceMotionUpdates(to: .main) { [weak self] (motion, error) in
            guard let deviceMotion = motion else {
                print("[Error] Failed to get device motion data")
                return
            }
            
            if let error = error {
                print("[Error] \(error.localizedDescription)")
                return
            }
            
            self?.handleDeviceMotion(deviceMotion)
        }
    }
    
    private func handleDeviceMotion(_ motion: CMDeviceMotion) {
        let attitude = motion.attitude
        
        let sensitivity: CGFloat = 500.0
        let deadZone: Double = 0.1
        
        var roll = attitude.roll
        var pitch = attitude.pitch
        
        if abs(roll) < deadZone { roll = 0 }
        if abs(pitch) < deadZone { pitch = 0 }
        
        let velocityX = CGFloat(roll) * sensitivity
        let velocityY = CGFloat(-pitch) * sensitivity * 1.5
        
        if let physicsBody = catFaceNode.physicsBody {
            physicsBody.velocity = CGVector(dx: velocityX, dy: velocityY)
        }
    }
    
    private func stopDeviceMotionUpdates() {
        motionManager.stopDeviceMotionUpdates()
    }
}
