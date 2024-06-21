//
//  ContentView.swift
//  aitango
//
//  Created by SATOSHI NAKAJIMA on 6/15/24.
//

import SwiftUI
import SwiftData
import FirebaseFirestore
import FirebaseFirestoreSwift

struct Book: Hashable {
    var id: String
    var title: String
    var words: [String]
}

@Observable class StoreBooks {
    public var books: [Book] = []
    private var db = Firestore.firestore()
    
    init() {
        db.collection("books")
            .addSnapshotListener { [weak self] querySnapshot, error in
                guard let self else { return }
                guard let documents = querySnapshot?.documents else {
                    print("No documents found")
                    return
                }
                self.books = documents.compactMap { snapshot -> Book in
                    let document = snapshot.data()
                    print("doc=", document["title"] ?? "N/A", snapshot.documentID)
                    return Book(id: snapshot.documentID, title: document["title"] as! String, words: document["words"] as! [String])
                }
            }
    }
}

@Observable class WordInfo {
    enum State {
        case idle
        case loading
        case failed
        case loaded
    }
    private(set) var state = State.idle
    
    private var db = Firestore.firestore()
    public var word: String
    public var path: String
    init(word: String, path: String) {
        self.word = word
        self.path = path
    }
    
    public func load() {
        let ref = db.document("words/" + word)
        self.state = .loading
        ref.getDocument { [weak self] snapshot, error in
            guard let self else { return }
            if ((error) != nil) {
                self.state = .failed
                print("no document")
            } else {
                self.state = .loaded
                let data = snapshot?.data()
                print(word, data?["nograph"] ?? "N/A")
            }
        }
    }
}

struct DictionaryView: View {
    private var wordInfo: WordInfo
    init(word: String, path: String) {
        self.wordInfo = WordInfo(word: word, path: path)
    }
    var body: some View {
        VStack {
            switch wordInfo.state {
            case .idle:
                Color.clear.onAppear(perform: {
                    wordInfo.load()
                })
            case .loading:
                Text("loading")
            case .loaded:
                Text(self.wordInfo.word)
                Text(self.wordInfo.path)
            default:
                Text("Something else")
            }
        }
    }
}

struct ContentView: View {
    
    @Environment(\.modelContext) private var modelContext
    @Query private var items: [Item]
    private var books = StoreBooks()
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(books.books, id: \.id) { book in
                    NavigationLink {
                        VStack {
                            Text(book.title)
                            List {
                                ForEach(book.words, id: \.self) { word in
                                    NavigationLink {
                                        DictionaryView(word: word, path: "register/" + book.id)
                                    } label: {
                                        Text(word)
                                    }
                                }
                            }
                        }
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
