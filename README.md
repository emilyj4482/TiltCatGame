# TiltCatGame (고양이 기울이기 게임)
기기를 기울여서 고양이에게 먹이를 먹이는 게임입니다. `CoreMotion`과 물리 충돌 처리를 구현한 프로젝트입니다.
- `SpriteKit`으로 구현
- [개발과정을 담은 포스팅](https://velog.io/@emilyj4482/Core-Motion-%EA%B3%A0%EC%96%91%EC%9D%B4-%EA%B8%B0%EC%9A%B8%EC%9D%B4%EA%B8%B0-%EA%B2%8C%EC%9E%84)

## 목차
- [주요 구현내용](#주요-구현내용)
- [트러블슈팅](#트러블슈팅)

<img src="https://github.com/user-attachments/assets/1baf9f17-768c-4eae-b227-4df6a865b69d" width=400>

## 주요 구현내용
### 📌 physicsBody(물리) 추가
`SpriteKit`에서의 한 개체 단위인 노드. 노드에 물리를 부여하는 객체는 `SKPhysicsBody`입니다.
> [SKPhysicsBody에 대해 정리한 velog 포스트](https://velog.io/@emilyj4482/SpriteKit-SKPhysicsBody)

고양이 노드와 먹이 노드 간 충돌 처리를 위해 각각 물리를 부여하였습니다. 물리는 노드의 형태에 따라 부여하게 됩니다.
- 고양이 노드 : `texture`로 부여(고양이 얼굴 이미지 모양대로)
- 먹이 노드 : 종류 별로 모양이 천차만별이기 때문에, 원 형태로 일관되게 부여
```swift
class GameScene: SKScene {
    private var catFaceNode: SKSpriteNode!
    private var itemNode: SKSpriteNode!

    // ... //

    private func setupPhysicsBody() {
        catFaceNode.physicsBody = SKPhysicsBody(texture: SKTexture(imageNamed: "catImage"), size: catFaceNode.size)
        itemNode.physicsBody = SKPhysicsBody(circleOfRadius: itemNode.size.width * 0.4)
    }
}
```
- `isDynamic` : 움직이는 노드에 대해서 `true`, 아닌 노드는 `false` 할당
- `affectedByGravity` : 중력의 영향을 받을지 여부
```swift
itemNode.isDynamic = false

catFaceNode.isDynamic = true
catFaceNode.affectedByGravity = false    // 기기의 움직임에 따라 이동. 중력 영향 거부
```
### 📌 CoreMotion으로 기기 기울기 감지
`CoreMotion` 프레임워크의 `CMMotionManager`를 통해 실제 기기의 기울기를 인식하고, 기울기를 속도와 방향으로 전환하여 노드 물리에 적용하였습니다.
> 자세한 내용은 [개발과정을 담은 포스팅](https://velog.io/@emilyj4482/Core-Motion-%EA%B3%A0%EC%96%91%EC%9D%B4-%EA%B8%B0%EC%9A%B8%EC%9D%B4%EA%B8%B0-%EA%B2%8C%EC%9E%84)에 정리해두었습니다.
```swift
private func startDeviceMotionUpdates() {
    guard motionManager.isDeviceMotionAvailable else { return }

    motionManager.startDeviceMotionUpdates(to: .main) { [weak self] (motion, error) in
        guard let deviceMotion = motion else { return }

        let attitude = motion.attitude	// motion의 방향 데이터에 접근
        
        let sensitivity: CGFloat = 500.0	// 움직임 민감도
        let deadZone: Double = 0.1			// 데드존 : 작은 움직임 인식 정조(손떨림 등)
        
        var roll = attitude.roll	// 좌우 기울기
        var pitch = attitude.pitch	// 앞뒤 기울기
        
        // 데드존 적용 : 작은 움직임은 인식하지 않도록
        if abs(roll) < deadZone { roll = 0 }
        if abs(pitch) < deadZone { pitch = 0 }
        
        // 민감도를 적용하여 기울기를 속도로 변환
        let velocityX = CGFloat(roll) * sensitivity
        let velocityY = CGFloat(-pitch) * sensitivity * 1.5	// 기기 윗부분이 뒤로 눕도록 기울였을 때 노드가 위로 움직이도록 하기 위한 음수 처리
        
        // 노드의 물리 바디에 속도 적용
        if let physicsBody = catFaceNode.physicsBody {
            physicsBody.velocity = CGVector(dx: velocityX, dy: velocityY)
        }
    }
}
```
### 📌 물리 충돌 처리
- `physicsBody`에 `UInt32` 타입의 `BitMask` 값을 부여하면 물리 충돌을 인식할 수 있습니다. (자세한 설명은 [SKPhysicsBody에 관한 포스트](https://velog.io/@emilyj4482/SpriteKit-SKPhysicsBody) 참고)
```swift
struct PhysicsCategory {
    static let none: UInt32 = 0
    static let frame: UInt32 = 0x1 << 0
    static let cat: UInt32 = 0x1 << 1
    static let item: UInt32 = 0x1 << 2
}
```
```swift
itemNode.physicsBody?.categoryBitMask = PhysicsCategory.item
itemNode.physicsBody?.collisionBitMask = PhysicsCategory.none
itemNode.physicsBody?.contactTestBitMask = PhysicsCategory.cat

catFaceNode.physicsBody?.categoryBitMask = PhysicsCategory.cat
catFaceNode.physicsBody?.collisionBitMask = PhysicsCategory.frame
catFaceNode.physicsBody?.contactTestBitMask = PhysicsCategory.item
```
- 충돌 처리 : 게임 씬에 `SKPhysicsContactDelegate`를 채택하여 `didBegin` 메소드 활용
```swift
extension GameScene: SKPhysicsContactDelegate {
    func didBegin(_ contact: SKPhysicsContact) {
        let bodyA = contact.bodyA
        let bodyB = contact.bodyB
        
        if ((bodyA.categoryBitMask == PhysicsCategory.cat && bodyB.categoryBitMask == PhysicsCategory.item) ||
            (bodyA.categoryBitMask == PhysicsCategory.item && bodyB.categoryBitMask == PhysicsCategory.cat)) {
            // ... 고양이와 먹이 충돌 시 처리 ... 1. 야옹 효과음 재생 2. 랜덤 먹이 리스폰 3. 고양이 색깔 랜덤 변경 ... //
        }
    }
}
```
## 트러블슈팅
### ⚠️ 무거운 texture 물리 바디 문제
#### ☹️ 문제
고양이가 먹이를 먹을(고양이 노드와 먹이 노드가 충돌)수록 앱이 심하게 버벅거리는 현상

<img src="https://github.com/user-attachments/assets/c7f1edcc-fda7-481d-80cf-4efab1525839" width=870>

- 충돌이 감지되면 먹이 노드의 이미지가 5가지 중 랜덤 한가지로 변경되고, 랜덤 위치에 리스폰되도록 구현했음
- 게임이 진행될수록 프레임 드랍이 심해져 플레이가 불가능해짐
#### 🧐 원인
1. `texture` 기반 물리 바디 생성의 고비용 연산
   > `SpriteKit`에서 `SKPhysicsBody(texture: ...)`는 주어진 텍스처의 `alpha` 정보를 기반으로 실제 충돌 영역을 픽셀 단위로 계산하는데, 이 연산은 매우 무겁고 특히 해상도가 높은 이미지일수록 성능 부닥이 급격히 증가
2. 충돌마다 물리 바디를 반복 생성
   > 먹이 노드의 이미지를 변경할 때마다 물리 바디를 새로 생성, 교체
   > 충돌 → 이미지 변경 → 새로운 물리 바디 생성의 과정이 반복 : 프레임마다 반복되는 고비용 연산이 누적되어 앱이 버벅거리게 됨
#### 😇 해결
1. `texture` 대신 원 형태의 물리 바디 사용 : 단순 도형은 `SpriteKit` 내부에서 매우 빠르게 계산되므로 성능 부담이 거의 없음
```swift
itemNode.physicsBody = SKPhysicsBody(circleOfRadius: itemNode.size.width * 0.4)
```
2. 물리 바디 재사용 : 아이템 이미지가 바뀌더라도 물리 바디는 계속해서 원 형태를 유지
#### 😎 성과
- `SKPhysicsBody(texture:size:)`가 픽셀 단위로 충돌 영역을 계산하는 매우 무거운 연산임을 이해하게 됨
- 텍스처가 변경될 때마다 `physicsBody`를 생성하는 방식은 연산량이 충돌 횟수에 비례하여 폭발적으로 증가하므로 성능 저하를 초래한다는 사실을 학습
- `SKPhysicsBody`의 여러가지 종류에 대해 깊게 학습하는 계기가 됨
