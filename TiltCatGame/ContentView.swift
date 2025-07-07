//
//  ContentView.swift
//  TiltCatGame
//
//  Created by EMILY on 08/07/2025.
//

import SwiftUI
import SpriteKit

struct ContentView: View {
    
    private let scene = GameScene()
    
    var body: some View {
        SpriteView(scene: scene)
            .ignoresSafeArea()
    }
}

#Preview {
    ContentView()
}
