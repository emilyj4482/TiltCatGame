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
    private var itemNode: SKSpriteNode!
    private var catFaceNode: SKSpriteNode!
    
    private let countLabel: SKLabelNode = {
        let node = SKLabelNode(text: "0 meow")
        
        node.fontColor = .white
        node.fontName = "HelveticaNeue-Bold"
        node.fontSize = 27
        
        return node
    }()
    
    private var count: Int = 0 {
        didSet {
            countLabel.text = "\(count) meow"
        }
    }
    
    private let meowSound: SKAudioNode = {
        let node = SKAudioNode(fileNamed: Assets.meow.rawValue)
        
        node.isPositional = true
        node.autoplayLooped = false
        
        return node
    }()
    
    override func didMove(to view: SKView) {
        size = view.bounds.size
        
        setupFramePhysics()
        addBackgroundNode()
        addCountLabel()
        addItemNode()
        addCatFaceNode()
        
        physicsWorld.contactDelegate = self
        startDeviceMotionUpdates()
        
        addChild(meowSound)
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
    
    private func addCountLabel() {
        countLabel.position = CGPoint(x: frame.midX, y: size.height - 100)
        
        addChild(countLabel)
    }
    
    private func addItemNode() {
        let imageName = Item.allCases.randomElement()?.rawValue ?? Item.tuna.rawValue
        itemNode = SKSpriteNode(imageNamed: imageName)
        
        itemNode.size = CGSize(width: 70, height: 70)
        itemNode.position = CGPoint(x: frame.midX, y: size.height * 0.32)
        
        setupItemPhysicsBody()
        
        addChild(itemNode)
    }
    
    private func setupItemPhysicsBody() {
        itemNode.physicsBody = SKPhysicsBody(circleOfRadius: itemNode.size.width * 0.4)
        itemNode.physicsBody?.categoryBitMask = PhysicsCategory.item
        itemNode.physicsBody?.collisionBitMask = PhysicsCategory.none
        itemNode.physicsBody?.contactTestBitMask = PhysicsCategory.cat
        itemNode.physicsBody?.isDynamic = false
    }
    
    private func addCatFaceNode() {
        let imageName = Cat.allCases.randomElement()?.rawValue ?? Cat.cheese.rawValue
        catFaceNode = SKSpriteNode(imageNamed: imageName)
        
        catFaceNode.size = CGSize(width: 60, height: 60)
        catFaceNode.position = CGPoint(x: frame.midX, y: frame.midY)
        
        setupCatFacePhysicsBody(imageName)
        
        addChild(catFaceNode)
    }
    
    private func setupCatFacePhysicsBody(_ imageName: String) {
        catFaceNode.physicsBody = SKPhysicsBody(texture: SKTexture(imageNamed: imageName), size: catFaceNode.size)
        catFaceNode.physicsBody?.categoryBitMask = PhysicsCategory.cat
        catFaceNode.physicsBody?.collisionBitMask = PhysicsCategory.frame
        catFaceNode.physicsBody?.contactTestBitMask = PhysicsCategory.item
        catFaceNode.physicsBody?.isDynamic = true
        catFaceNode.physicsBody?.affectedByGravity = false
        catFaceNode.physicsBody?.allowsRotation = false
        catFaceNode.physicsBody?.restitution = 0.0
        catFaceNode.physicsBody?.linearDamping = 0.7    // Essential for natural movement
        catFaceNode.physicsBody?.angularDamping = 0.9   // Prevent unwanted rotation
    }
    
    private func changeCatFaceImage() {
        let imageName = Cat.allCases.randomElement()?.rawValue ?? Cat.cheese.rawValue
        catFaceNode.texture = SKTexture(imageNamed: imageName)
    }
    
    private func changeItemImage() {
        let imageName = Item.allCases.randomElement()?.rawValue ?? Item.tuna.rawValue
        itemNode.texture = SKTexture(imageNamed: imageName)
    }
    
    private var isContactProcessing = false
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
    
    func didBegin(_ contact: SKPhysicsContact) {
        guard !isContactProcessing else { return }
        
        let bodyA = contact.bodyA
        let bodyB = contact.bodyB
        
        if ((bodyA.categoryBitMask == PhysicsCategory.cat && bodyB.categoryBitMask == PhysicsCategory.item) ||
            (bodyA.categoryBitMask == PhysicsCategory.item && bodyB.categoryBitMask == PhysicsCategory.cat)) {
            isContactProcessing = true
            
            count += 1
            
            playMeowSound()
            repositionItemNode()
            changeItemImage()
            changeCatFaceImage()
        }
    }
    
    private func repositionItemNode() {
        let randomX = CGFloat.random(in: 50...(size.width - 50))
        let randomY = CGFloat.random(in: 100...(countLabel.position.y - 100))
        
        let originalPhysicsBody = itemNode.physicsBody
        itemNode.physicsBody = nil
        
        itemNode.position = CGPoint(x: randomX, y: randomY)
        itemNode.physicsBody = originalPhysicsBody
        
        // Small delay to prevent multiple contacts from same collision
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
            self?.isContactProcessing = false
        }
    }
    
    private func playMeowSound() {
        let playAction = SKAction.play()
        meowSound.run(playAction)
    }
}
