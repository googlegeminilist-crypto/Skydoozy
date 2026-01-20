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
                if let url = webGameURL {
                    WebGameView(url: url)
                        .ignoresSafeArea()
                } else {
                    Text("App web content missing from bundle.")
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color.black)
                }
            } else {
                introVideoFullScreen
                    .contentShape(Rectangle())
                    .onTapGesture {
                        showWeb = true
                        introPlayer?.pause()
                        clearIntroEndObserver()
                    }
            }
        }
    }

    private var webGameURL: URL? {
        Bundle.main.url(forResource: "index", withExtension: "html")
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
        let userScriptSource = """
        (function() {
          var meta = document.querySelector('meta[name=viewport]');
          if (!meta) {
            meta = document.createElement('meta');
            meta.name = 'viewport';
            document.head.appendChild(meta);
          }
          meta.content = 'width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no, viewport-fit=cover';
          document.documentElement.style.width = '100%';
          document.documentElement.style.height = 'auto';
          document.documentElement.style.overflow = 'auto';
          document.body.style.width = '100%';
          document.body.style.height = 'auto';
          document.body.style.margin = '0';
          document.body.style.overflow = 'auto';
          document.body.style.webkitOverflowScrolling = 'touch';
          document.body.classList.remove('intro-open');
          var overlay = document.getElementById('introOverlay');
          if (overlay) {
            overlay.classList.add('is-hidden');
            overlay.setAttribute('aria-hidden', 'true');
          }
          var hideSelectors = ['.blog-panel', '.intro-overlay', '.intro-video', '.intro-skip', 'video'];
          hideSelectors.forEach(function(sel) {
            document.querySelectorAll(sel).forEach(function(el) {
              el.style.display = 'none';
            });
          });
          document.querySelectorAll('video').forEach(function(el) {
            try { el.pause(); } catch (e) {}
            el.removeAttribute('src');
          });
          var introAudio = document.getElementById('introAudio');
          if (introAudio) {
            try { introAudio.pause(); } catch (e) {}
            introAudio.muted = true;
            introAudio.volume = 0;
            introAudio.removeAttribute('src');
          }
          var voice = document.getElementById('voiceAudio');
          if (voice) {
            try { voice.pause(); } catch (e) {}
            voice.muted = true;
            voice.volume = 0;
          }
          var poppy = document.getElementById('poppyAudio');
          if (poppy) {
            try { poppy.pause(); } catch (e) {}
            poppy.muted = true;
            poppy.volume = 0;
          }
        })();
        """
        let script = WKUserScript(source: userScriptSource, injectionTime: .atDocumentEnd, forMainFrameOnly: true)
        let controller = WKUserContentController()
        let appFlag = WKUserScript(
            source: "window.SKYDOOZY_APP = true;",
            injectionTime: .atDocumentStart,
            forMainFrameOnly: true
        )
        controller.addUserScript(appFlag)
        controller.addUserScript(script)
        config.userContentController = controller
        let view = WKWebView(frame: .zero, configuration: config)
        view.isOpaque = false
        view.backgroundColor = .black
        view.scrollView.isScrollEnabled = true
        view.scrollView.bounces = true
        view.scrollView.alwaysBounceVertical = true
        view.scrollView.contentInsetAdjustmentBehavior = .never
        let accessURL = url.deletingLastPathComponent()
        view.loadFileURL(url, allowingReadAccessTo: accessURL)
        return view
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {
        if uiView.url != url {
            let accessURL = url.deletingLastPathComponent()
            uiView.loadFileURL(url, allowingReadAccessTo: accessURL)
        }
    }
}

#Preview {
    ContentView()
}
