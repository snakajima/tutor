//
//  ContentView.swift
//  aitango
//
//  Created by SATOSHI NAKAJIMA on 6/15/24.
//

import Foundation
import AVFoundation
import SwiftUI
import SwiftData
import FirebaseFirestore
import FirebaseFirestoreSwift

struct DictionaryView: View {
    private var model: WordModel
    @State private var isMeaningVisible: Bool = false
    @State private var isMeaningJPVisible: Bool = false
    @State private var isSamplesVisible: Bool = false
    @State private var player: AVPlayer?
    
    init(word: String, path: String) {
        self.model = WordModel(word: word, path: path)
    }
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            switch model.state {
            case .idle:
                Color.clear.onAppear(perform: {
                    model.load()
                })
            case .loading:
                Text("loading")
            case .nodata:
                Text("No Data").onAppear() {
                    model.generate()
                }
            case .generating:
                Text("Generating...")
            case .loaded:
                if let samples = model.samples {
                    Button("例文") {
                        isSamplesVisible.toggle()
                    }.font(. system(size: 24))
                    if (isSamplesVisible) {
                        ForEach(samples, id: \.id) { sample in
                            HStack {
                                Text(sample.en)
                                Spacer()
                                Button("", systemImage: "speaker.wave.3.fill") {
                                    if let voice = sample.voice {
                                        print("play", voice)
                                        let url = URL(fileURLWithPath: voice)
                                        player = AVPlayer(url: url)
                                        player?.play()
                                    }
                                }.font(. system(size: 24))
                            }
                        }
                    }
                }
                if ((model.meaning) != nil) {
                    HStack {
                        Button("意味（英語）") {
                            isMeaningVisible.toggle()
                        }.font(. system(size: 24))
                        Spacer()
                    }
                    if (isMeaningVisible) {
                        Text(model.meaning!)
                    }
                }
                if ((model.meaning_jp) != nil) {
                    Button("意味（日本語）") {
                        isMeaningJPVisible.toggle()
                    }.font(. system(size: 24))
                    if (isMeaningJPVisible) {
                        Text(model.meaning_jp!)
                    }
                }
                Spacer()
            }
        }
    }
}

struct ContentView: View {
    
    @Environment(\.modelContext) private var modelContext
    @Query private var items: [Item]
    private var books = BooksModel()
    
    public func activateSession() {
        let session = AVAudioSession.sharedInstance()
        do {
            try session.setCategory(
                .playback,
                mode: .default,
                options: []
            )
        } catch _ {
            print("session.setCategory failed")
        }
        
        do {
            try session.setActive(true, options: .notifyOthersOnDeactivation)
        } catch _ {
            print("session.setActivate failed")
        }
        
        do {
            try session.overrideOutputAudioPort(.speaker)
        } catch _ {
            print("session.overrideOutputaudioPort failed")
        }
    }
    
    init() {
        activateSession()
    }
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(books.books, id: \.id) { book in
                    NavigationLink {
                        VStack {
                            List {
                                ForEach(book.words, id: \.self) { word in
                                    NavigationLink {
                                        DictionaryView(word: word, path: "register/" + book.id + "/" + word)
                                        .navigationTitle(word)
                                        .padding([.leading, .trailing], 10)
                                    } label: {
                                        Text(word)
                                    }
                                }
                            }
                        }.navigationTitle(book.title)
                    } label: {
                        Text(book.title)
                    }
                }
            }
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
