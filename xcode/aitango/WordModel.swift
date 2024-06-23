//
//  WordModel.swift
//  aitango
//
//  Created by SATOSHI NAKAJIMA on 6/22/24.
//

import Foundation
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
    public var similar: [SampleText]?
    public var antonym: [SampleText]?
    public var story: LocalizedStringKey?
    public var vocab: [SampleText]?

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
        similar = (result["similar"] as! [Dictionary<String, String>]).map { sample in
            return SampleText(en: sample["word"]!, jp: sample["jp"]!, voice: sample["voice"])
        }
        antonym = (result["antonym"] as! [Dictionary<String, String>]).map { sample in
            return SampleText(en: sample["word"]!, jp: sample["jp"]!, voice: sample["voice"])
        }
        story = LocalizedStringKey(result["story"] as! String)
        vocab = (result["vocab"] as! [Dictionary<String, String>]).map { sample in
            return SampleText(en: sample["en"]!, jp: sample["jp"]!, voice: sample["voice"])
        }
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
    
    public func generateSampleVoice(index: Int) {
        print("generateSampleVOice", word, index)
        guard let url = URL(string: "https://asia-northeast1-ai-tango.cloudfunctions.net/express_server/api/sample/" + word + "/" + String(index)) else {
            print("Invalid URL")
            return
        }
        print(url)
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("Error: \(error.localizedDescription)")
                return
            }
            if let data {
                do {
                    let json = try JSONSerialization.jsonObject(with: data)
                    print("json", json) // .url
                } catch {
                    print("Error parsing JSON: \(error)")
                }
            }
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
