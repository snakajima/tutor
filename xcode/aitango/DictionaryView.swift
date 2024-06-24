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
    
    @State private var model: WordModel
    @State private var wordItem = WordItem(word: "dummy")
    // @Query(filter: #Predicate<WordItem> { item in item.id == model.word }) var wordItems: [WordItem]

    init(word: String, path: String) {
        self.model = WordModel(word: word, path: path)
    }
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 10) {
                Picker("Planet", selection: $wordItem.level) {
                    ForEach(Level.allCases) { planet in
                        Text(planet.rawValue.capitalized)
                    }
                }.pickerStyle(.segmented)
                switch model.state {
                case .idle:
                    Color.clear.onAppear(perform: {
                        model.load()
                        
                        let word = model.word
                        let predicate = #Predicate<WordItem> { $0.id == word }
                        let descriptor = FetchDescriptor<WordItem>(predicate: predicate)
                        do {
                            let wordItems = try modelContext.fetch(descriptor)
                            if let item = wordItems.first {
                                item.lastAccess = Date()
                                wordItem = item
                                print("updating last access", word)
                            } else {
                                wordItem = WordItem(word: word)
                                print("inserting", word)
                                modelContext.insert(wordItem)
                            }
                            // Note: No need to call modelContext.save() in SwiftData
                        } catch {
                            print("DictionaryView:onApper \(error)")
                        }
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
                            ForEach(Array(samples.enumerated()), id: \.offset) { index, sample in
                                HStack {
                                    Text(sample.en).onTapGesture {
                                        areTranslationVisible[index] = !(areTranslationVisible[index] ?? false)
                                    }
                                    Spacer()
                                    if let voice = sample.voice {
                                        Button("", systemImage: "speaker.wave.3.fill") {
                                            if let url = URL(string: voice) {
                                                model.player = AVPlayer(url: url)
                                                guard let player = model.player else { return }
                                                player.play()
                                            }
                                        }.font(. system(size: 24))
                                    } else {
                                        Button("", systemImage: "speaker.wave.2.fill") {
                                            model.generateSampleVoice(index: index)
                                        }.font(. system(size: 24))
                                    }
                                }
                                if areTranslationVisible[index] ?? false {
                                    Text(sample.jp)
                                }
                            }
                        }
                    }
                    if let meaning = model.meaning {
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
                    if let meaning_jp = model.meaning_jp {
                        Button("意味（日本語）") {
                            isMeaningJPVisible.toggle()
                        }.font(. system(size: 24))
                        if (isMeaningJPVisible) {
                            Text(meaning_jp)
                        }
                    }
                    if let similar = model.similar {
                        Button("同義語") {
                            isSimilarVisible.toggle()
                        }.font(. system(size: 24))
                        if (isSimilarVisible) {
                            ForEach(Array(similar.enumerated()), id: \.offset) { index, sample in
                                HStack {
                                    Text("**\(sample.en)**").frame(width: 100, alignment: .leading)
                                    Text(sample.jp)
                                }
                            }
                        }
                    }
                    if let antonym = model.antonym {
                        Button("反対語") {
                            isAntonymVisible.toggle()
                        }.font(. system(size: 24))
                        if (isAntonymVisible) {
                            ForEach(Array(antonym.enumerated()), id: \.offset) { index, sample in
                                HStack {
                                    Text("**\(sample.en)**").frame(width: 100, alignment: .leading)
                                    Text(sample.jp)
                                }
                            }
                        }
                    }
                    if let root = model.root {
                        Button("語源") {
                            isRootVisible.toggle()
                        }.font(. system(size: 24))
                        if isRootVisible {
                            Text(root)
                        }
                    }
                    if let story = model.story {
                        Button("ストーリー") {
                            isStoryVisible.toggle()
                        }.font(. system(size: 24))
                        if (isStoryVisible) {
                            Text(story)
                            if let vocab = model.vocab {
                                Button("ストーリー中の単語") {
                                    isVocabVisible.toggle()
                                }.font(. system(size: 24))
                                if (isVocabVisible) {
                                    ForEach(Array(vocab.enumerated()), id: \.offset) { index, sample in
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
