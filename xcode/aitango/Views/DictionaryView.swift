//
//  DictionaryView.swift
//  aitango
//
//  Created by SATOSHI NAKAJIMA on 6/22/24.
//

import Foundation
import SwiftUI
import SwiftData
import AVFoundation

struct DictionaryView: View {
    @Environment(\.modelContext) private var modelContext
    
    @State private var isMeaningVisible: Bool = false
    @State private var isMeaningJPVisible: Bool = false
    @State private var isSamplesVisible: Bool = false
    @State private var isSimilarVisible: Bool = false
    @State private var isAntonymVisible: Bool = false
    @State private var isRootVisible: Bool = false
    @State private var isStoryVisible: Bool = false
    @State private var isVocabVisible: Bool = false
    @State private var areTranslationVisible = Dictionary<Int, Bool>()
    
    @State private var store: WordStore
    @State private var wordItem = WordItem(word: "_dummy")
    // @Query(filter: #Predicate<WordItem> { item in item.id == store.word }) var wordItems: [WordItem]
    @State private var opacity = 0.0

    init(word: String, path: String) {
        self.store = WordStore(word: word, path: path)
    }
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 10) {
                Picker("Level", selection: $wordItem.level) {
                    ForEach(Level.allCases) { level in
                        Text(level.rawValue)
                    }
                }.pickerStyle(.segmented)
                    .padding([.leading, .trailing], 10)
                    .colorMultiply(wordItem.level.color())
                    .onAppear(perform: {
                        // Handle the case where the store.state is cached
                        if store.state == .loaded && wordItem.id == "_dummy" {
                            guard let wordItem = WordItem.getItem(modelContext: modelContext, word: store.word) else {
                                print("### DictionaryView: Failed to getItem")
                                return
                            }
                            self.wordItem = wordItem
                            wordItem.recordAccess()
                        }
                    })
                switch store.state {
                case .idle:
                    Color.clear.onAppear(perform: {
                        store.load()
                        guard let wordItem = WordItem.getItem(modelContext: modelContext, word: store.word) else {
                            print("### DictionaryView: Failed to getItem")
                            return
                        }
                        self.wordItem = wordItem
                        wordItem.recordAccess()
                    })
                case .loading:
                    Text("loading")
                case .nodata:
                    Text("No Data").onAppear() {
                        store.generate()
                    }
                case .generating:
                    VStack {
                        Text("AIエージェントが、辞書を作成中...")
                        HStack {
                            Spacer()
                            Image(systemName: "book.and.wrench")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 64, height: 64)
                                .opacity(opacity)
                                .onAppear {
                                    withAnimation(.linear(duration: 0.1)
                                                  .speed(0.1).repeatForever(autoreverses: true)) {
                                                      opacity = 1.0
                                                  }
                                          }
                            Spacer()
                        }
                    }
                    
                case .loaded:
                    if store.samples.count > 0 {
                        HStack {
                            Button("例文") {
                                isSamplesVisible.toggle()
                            }.font(. system(size: 24))
                            if (isSamplesVisible) {
                                Spacer()
                                Text("日本語訳は英文をタップ")
                                    .font(.system(size: 14))
                                    .foregroundColor(.gray)
                            }
                        }
                        if (isSamplesVisible) {
                            ForEach(Array(store.samples.enumerated()), id: \.offset) { index, sample in
                                HStack {
                                    Text(sample.en).onTapGesture {
                                        areTranslationVisible[index] = !(areTranslationVisible[index] ?? false)
                                    }
                                    Spacer()
                                    if let voice = sample.voice {
                                        Button("", systemImage: "speaker.wave.3.fill") {
                                            if let url = URL(string: voice) {
                                                store.player = AVPlayer(url: url)
                                                guard let player = store.player else { return }
                                                player.play()
                                            }
                                        }.font(. system(size: 24))
                                    } else {
                                        Button("", systemImage: "speaker.wave.2.fill") {
                                            store.generateSampleVoice(index: index)
                                        }.font(. system(size: 24))
                                    }
                                }
                                if areTranslationVisible[index] ?? false {
                                    Text(sample.jp)
                                }
                            }
                        }
                    }
                    if let meaning = store.meaning {
                        HStack {
                            Button("意味（英語）") {
                                isMeaningVisible.toggle()
                            }.font(. system(size: 24))
                            Spacer()
                        }
                        if (isMeaningVisible) {
                            Text(meaning)
                        }
                    }
                    if let meaning_jp = store.meaning_jp {
                        Button("意味（日本語）") {
                            isMeaningJPVisible.toggle()
                        }.font(. system(size: 24))
                        if (isMeaningJPVisible) {
                            Text(meaning_jp)
                        }
                    }
                    if store.similar.count > 0 {
                        Button("同義語") {
                            isSimilarVisible.toggle()
                        }.font(. system(size: 24))
                        if (isSimilarVisible) {
                            ForEach(Array(store.similar.enumerated()), id: \.offset) { index, sample in
                                HStack {
                                    Text("**\(sample.en)**").frame(width: 100, alignment: .leading)
                                    Text(sample.jp)
                                }
                            }
                        }
                    }
                    if store.antonym.count > 0 {
                        Button("反対語") {
                            isAntonymVisible.toggle()
                        }.font(. system(size: 24))
                        if (isAntonymVisible) {
                            ForEach(Array(store.antonym.enumerated()), id: \.offset) { index, sample in
                                HStack {
                                    Text("**\(sample.en)**").frame(width: 100, alignment: .leading)
                                    Text(sample.jp)
                                }
                            }
                        }
                    }
                    if let root = store.root {
                        Button("語源") {
                            isRootVisible.toggle()
                        }.font(. system(size: 24))
                        if isRootVisible {
                            Text(root)
                        }
                    }
                    if let story = store.story {
                        Button("ストーリー") {
                            isStoryVisible.toggle()
                        }.font(. system(size: 24))
                        if (isStoryVisible) {
                            Text(story)
                            if store.vocab.count > 0 {
                                Button("ストーリー中の単語") {
                                    isVocabVisible.toggle()
                                }.font(. system(size: 24))
                                if (isVocabVisible) {
                                    ForEach(Array(store.vocab.enumerated()), id: \.offset) { index, sample in
                                        HStack {
                                            Text("**\(sample.en)**").frame(width: 100, alignment: .leading)
                                            Text(sample.jp)
                                        }
                                    }
                                }
                            }
                        }
                    }
                    Spacer()
                }
            }
        }
    }
}
