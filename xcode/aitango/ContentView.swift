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

struct WordLinkView: View {
    @Environment(\.modelContext) private var modelContext
    private let word: String
    private let bookId: String
    @State private var wordItem = WordItem(word: "dummy")

    init(word: String, bookId: String) {
        self.word = word
        self.bookId = bookId
    }

    var body: some View {
        NavigationLink {
            DictionaryView(word: word, path: "register/" + bookId + "/" + word)
            .navigationTitle(word)
            .padding([.leading, .trailing], 10)
        } label: {
            HStack {
                Circle().fill(wordItem.level.color()).frame(width:24, height:24)
                Text(word)
            }.onAppear() {
                let predicate = #Predicate<WordItem> { $0.id == word }
                let descriptor = FetchDescriptor<WordItem>(predicate: predicate)
                do {
                    let wordItems = try modelContext.fetch(descriptor)
                    if let item = wordItems.first {
                        wordItem = item
                    }
                } catch {
                    print("WordLinkView:onApper \(error)")
                }

            }
        }
    }
}

struct ContentView: View {
    
    @Environment(\.modelContext) private var modelContext
    @Query(filter: #Predicate<WordItem> { $0.accessed }, sort: \WordItem.lastAccess, order: .reverse) var wordItems: [WordItem]
    
    // @Query private var items: [Item]
    @State var session = AudioSession()
    private var books = BooksModel()
    
    init() {
        session.activateSession()
    }
    
    var body: some View {
        VStack {
            NavigationStack {
                List {
                    ForEach(books.books, id: \.id) { book in
                        NavigationLink {
                            VStack {
                                List {
                                    ForEach(book.words, id: \.self) { word in
                                        WordLinkView(word: word, bookId: book.id)
                                    }
                                }
                            }.navigationTitle(book.title)
                        } label: {
                            Text(book.title)
                        }
                    }
                    Section("History") {
                        ForEach(wordItems) { wordItem in
                            Text(wordItem.id)
                        }
                    }
                }.listStyle(.grouped)
            }/* .onAppear() {
                try! modelContext.delete(model: WordItem.self)
            }*/
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: WordItem.self, inMemory: true)
}
