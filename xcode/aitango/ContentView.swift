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
    public var word: String
    init(word: String) {
        self.word = word
    }
}

struct DictionaryView: View {
    private var wordInfo: WordInfo
    init(word: String) {
        self.wordInfo = WordInfo(word: word)
    }
    var body: some View {
        VStack {
            Text(self.wordInfo.word)
            Text(self.wordInfo.word)
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
                                        DictionaryView(word: word)
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
