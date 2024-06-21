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

@Observable class BooksModel {
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

@Observable class WordModel {
    enum State {
        case idle
        case loading
        case nodata
        case loaded
    }
    private(set) var state = State.idle
    
    private var db = Firestore.firestore()
    public var word: String
    public var path: String
    
    public var meaning: LocalizedStringKey?
    public var meaning_jp: LocalizedStringKey?
    
    init(word: String, path: String) {
        self.word = word
        self.path = path
    }
    private func populate(data: Dictionary<String, Any>) {
        let nograph = data["nograph"] as! Bool
        if (nograph) {
            return
        }
        guard let result = data["result"] as? Dictionary<String, Any> else {
            return
        }
        meaning = LocalizedStringKey(result["meaning"] as! String)
        meaning_jp = LocalizedStringKey(result["meaning_jp"] as! String)
    }
    
    public func load() {
        let ref = db.document("words/" + word)
        self.state = .loading
        ref.getDocument { [weak self] snapshot, error in
            guard let self else { return }
            let data = snapshot?.data()
            if (data != nil) {
                self.state = .loaded
                populate(data: data!)
                print(word, data?["nograph"] ?? "N/A")
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

    init(word: String, path: String) {
        self.model = WordModel(word: word, path: path)
    }
    var body: some View {
        VStack {
            switch model.state {
            case .idle:
                Color.clear.onAppear(perform: {
                    model.load()
                })
            case .loading:
                Text("loading")
            case .nodata:
                Text("No Data")
            case .loaded:
                if ((model.meaning) != nil) {
                    Button("意味（英語）") {
                        isMeaningVisible.toggle()
                    }
                    if (isMeaningVisible) {
                        Text(model.meaning!)
                    }
                }
                if ((model.meaning_jp) != nil) {
                    Button("意味（日本語）") {
                        isMeaningJPVisible.toggle()
                    }
                    if (isMeaningJPVisible) {
                        Text(model.meaning_jp!)
                    }
                }
            }
        }
    }
}

struct ContentView: View {
    
    @Environment(\.modelContext) private var modelContext
    @Query private var items: [Item]
    private var books = BooksModel()
    
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
