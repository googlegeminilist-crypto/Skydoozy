//
//  ContentView.swift
//  Skydoozy
//
//  Created by Thomas Mellor on 20/01/2026.
//

import SwiftUI
import AVKit

struct ContentView: View {
    private let introVideoName = "Firefly Skydoozy animation logo with matrix code and rainbow same vido without word animation 636432"
    @State private var introPlayer: AVPlayer?

    var body: some View {
        introVideoFullScreen
    }

    @ViewBuilder
    private var introVideoFullScreen: some View {
        if let url = Bundle.main.url(forResource: introVideoName, withExtension: "mp4") {
            VideoPlayer(player: introPlayer)
                .aspectRatio(contentMode: .fit)
                .ignoresSafeArea()
                .background(Color.black)
                .onAppear {
                    if introPlayer == nil {
                        introPlayer = AVPlayer(url: url)
                        introPlayer?.play()
                    }
                }
                .onDisappear {
                    introPlayer?.pause()
                }
        } else {
            Text("Intro video not found in bundle.")
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.black)
        }
    }
}

#Preview {
    ContentView()
}
