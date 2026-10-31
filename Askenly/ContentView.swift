//
//  ContentView.swift
//  Askenly
//
//  Created by derp on 10/30/26.
//

import BraisenlyAI
import BraisenlySwiftUI
import SwiftUI

struct ContentView: View {
    @State private var controller: AIChatWorkspaceController

    init(controller: AIChatWorkspaceController? = nil) {
        _controller = State(initialValue: controller ?? AIChatWorkspaceController())
    }

    var body: some View {
        AIChatWorkspaceView(controller: controller)
    }
}

#Preview {
    ContentView()
}
