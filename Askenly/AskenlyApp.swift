//
//  AskenlyApp.swift
//  Askenly
//
//  Created by derp on 10/30/26.
//

import BraisenlyAI
import BraisenlySwiftUI
import SwiftUI

@main
struct AskenlyApp: App {
    @State private var workspaceController = AIChatWorkspaceController()

    var body: some Scene {
        WindowGroup {
            ContentView(controller: workspaceController)
        }
    }
}
