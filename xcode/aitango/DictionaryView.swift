//
//  DictionaryView.swift
//  aitango
//
//  Created by SATOSHI NAKAJIMA on 6/22/24.
//

import Foundation
import SwiftUI
import AVFoundation

struct DictionaryView: View {
    private var model: WordModel
    @State private var isMeaningVisible: Bool = false
    @State private var isMeaningJPVisible: Bool = false
    @State private var isSamplesVisible: Bool = false
    @State private var player: AVPlayer?
    @State private var audioPlayer: AVAudioPlayer?
    
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
                        ForEach(Array(samples.enumerated()), id: \.offset) { index, sample in
                            HStack {
                                Text(sample.en)
                                Spacer()
                                if let voice = sample.voice {
                                    Button("", systemImage: "speaker.wave.3.fill") {
                                        if let url = URL(string: voice) {
                                            player = AVPlayer(url: url)
                                            guard let player else { return }
                                            player.play()
                                        }
                                    }.font(. system(size: 24))
                                } else {
                                    Button("", systemImage: "speaker.wave.2.fill") {
                                        model.generateSampleVoice(index: index)
                                    }.font(. system(size: 24))
                                }
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
