//
//  ContentView.swift
//  Skydoozy
//
//  Created by Thomas Mellor on 20/01/2026.
//

import SwiftUI
import SwiftData
import AVKit

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var items: [Item]

    private let introVideoName = "Firefly Skydoozy animation logo with matrix code and rainbow same vido without word animation 636432"
    @State private var introPlayer: AVPlayer?

    var body: some View {
        NavigationSplitView {
            List {
                Section {
                    introVideoView
                }
                ForEach(items) { item in
                    NavigationLink {
                        Text("Item at \(item.timestamp, format: Date.FormatStyle(date: .numeric, time: .standard))")
                    } label: {
                        Text(item.timestamp, format: Date.FormatStyle(date: .numeric, time: .standard))
                    }
                }
                .onDelete(perform: deleteItems)
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                }
                ToolbarItem {
                    Button(action: addItem) {
                        Label("Add Item", systemImage: "plus")
                    }
                }
            }
        } detail: {
            Text("Select an item")
        }
    }

    @ViewBuilder
    private var introVideoView: some View {
        if let url = Bundle.main.url(forResource: introVideoName, withExtension: "mp4") {
            VideoPlayer(player: introPlayer)
                .aspectRatio(16 / 9, contentMode: .fit)
                .listRowInsets(EdgeInsets())
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
        }
    }

    private func addItem() {
        withAnimation {
            let newItem = Item(timestamp: Date())
            modelContext.insert(newItem)
        }
    }

    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                modelContext.delete(items[index])
            }
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Item.self, inMemory: true)
}
