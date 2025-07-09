//
//  PhysicsCategory.swift
//  TiltCatGame
//
//  Created by EMILY on 08/07/2025.
//

import Foundation

struct PhysicsCategory {
    static let none: UInt32 = 0
    static let frame: UInt32 = 0x1 << 0
    static let cat: UInt32 = 0x1 << 1
    static let item: UInt32 = 0x1 << 2
}
