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



@Observable class WordModel {
    enum State {
        case idle
        case loading
        case nodata
        case generating
        case loaded
    }
    private(set) var state = State.idle
    
    private var db = Firestore.firestore()
    public var word: String
    public var path: String

    struct SampleText: Identifiable {
        let en: String
        let jp: String
        let voice: String?
        let id = UUID()
    }

    public var samples: [SampleText]?
    public var meaning: LocalizedStringKey?
    public var meaning_jp: LocalizedStringKey?
    public var listner: ListenerRegistration?
    
    init(word: String, path: String) {
        self.word = word
        self.path = path
    }
    
    deinit {
        if let listner = listner {
            listner.remove()
            print("deinit", self.word)
        }
    }

    
    private func populate(data: Dictionary<String, Any>) {
        let nograph = data["nograph"] as! Bool
        if (nograph) {
            return
        }
        guard let result = data["result"] as? Dictionary<String, Any> else {
            return
        }
        self.state = .loaded
        samples = (result["samples"] as! [Dictionary<String, String>]).map { sample in
            return SampleText(en: sample["en"]!, jp: sample["jp"]!, voice: sample["voice"])
        }
        meaning = LocalizedStringKey(result["meaning"] as! String)
        meaning_jp = LocalizedStringKey(result["meaning_jp"] as! String)
    }
    public func generate() {
        self.state = .generating
        guard let url = URL(string: "https://asia-northeast1-ai-tango.cloudfunctions.net/express_server/api/" + self.path) else {
            print("Invalid URL")
            return
        }
        print(url)
        let task = URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            guard let self else { return }
            if let error = error {
                print("Error: \(error.localizedDescription)")
                return
            }
            self.addListner()
        }
        task.resume()
    }
    
    private func addListner() {
        let ref = db.document("words/" + word)
        listner = ref.addSnapshotListener{ [weak self] snapshot, error in
            guard let self else { return }
            print("updated", word)
            if let data = snapshot?.data() {
                populate(data: data)
            }
        }
    }
    
    public func load() {
        let ref = db.document("words/" + word)
        self.state = .loading
        ref.getDocument { [weak self] snapshot, error in
            guard let self else { return }
            
            if let data = snapshot?.data() {
                populate(data: data)
                addListner()
            } else {
                self.state = .nodata
            }
        }
    }
}

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
