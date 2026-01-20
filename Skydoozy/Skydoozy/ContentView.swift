//
//  ContentView.swift
//  Skydoozy
//
//  Created by Thomas Mellor on 20/01/2026.
//

import SwiftUI
import AVKit
import WebKit

struct ContentView: View {
    private let introVideoName = "Firefly Skydoozy animation logo with matrix code and rainbow same vido without word animation 636432"
    @State private var introPlayer: AVPlayer?
    @State private var introEndObserver: NSObjectProtocol?
    @State private var showWeb = false

    var body: some View {
        Group {
            if showWeb {
                WebGameView(url: webGameURL)
                    .ignoresSafeArea()
            } else {
                introVideoFullScreen
            }
        }
    }

    private var webGameURL: URL {
        Bundle.main.url(forResource: "index", withExtension: "html")
            ?? URL(string: "https://skydoozy.skybammy.com/")!
    }

    @ViewBuilder
    private var introVideoFullScreen: some View {
        if let url = Bundle.main.url(forResource: introVideoName, withExtension: "mp4") {
            ZStack {
                Color.black.ignoresSafeArea()
                if let player = introPlayer {
                    IntroVideoPlayer(player: player)
                        .ignoresSafeArea()
                }
            }
            .onAppear {
                if introPlayer == nil {
                    let player = AVPlayer(url: url)
                    introPlayer = player
                    attachIntroEndObserver(to: player)
                    player.play()
                }
            }
            .onDisappear {
                introPlayer?.pause()
                clearIntroEndObserver()
            }
        } else {
            Text("Intro video not found in bundle.")
                .foregroundColor(.secondary)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.black)
        }
    }

    private func attachIntroEndObserver(to player: AVPlayer) {
        clearIntroEndObserver()
        introEndObserver = NotificationCenter.default.addObserver(
            forName: .AVPlayerItemDidPlayToEndTime,
            object: player.currentItem,
            queue: .main
        ) { _ in
            showWeb = true
        }
    }

    private func clearIntroEndObserver() {
        if let observer = introEndObserver {
            NotificationCenter.default.removeObserver(observer)
            introEndObserver = nil
        }
    }
}

struct IntroVideoPlayer: UIViewControllerRepresentable {
    let player: AVPlayer

    func makeUIViewController(context: Context) -> AVPlayerViewController {
        let controller = AVPlayerViewController()
        controller.player = player
        controller.videoGravity = .resizeAspect
        controller.showsPlaybackControls = false
        controller.view.backgroundColor = .black
        return controller
    }

    func updateUIViewController(_ uiViewController: AVPlayerViewController, context: Context) {
        if uiViewController.player !== player {
            uiViewController.player = player
        }
    }
}

struct WebGameView: UIViewRepresentable {
    let url: URL

    func makeUIView(context: Context) -> WKWebView {
        let config = WKWebViewConfiguration()
        config.mediaTypesRequiringUserActionForPlayback = []
        let view = WKWebView(frame: .zero, configuration: config)
        view.isOpaque = false
        view.backgroundColor = .black
        view.scrollView.isScrollEnabled = false
        view.load(URLRequest(url: url))
        return view
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {
        if uiView.url != url {
            uiView.load(URLRequest(url: url))
        }
    }
}

#Preview {
    ContentView()
}
