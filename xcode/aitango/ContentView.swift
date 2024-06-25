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

struct BookView: View {
    private let book: Book
    
    var body: some View {
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
    
    init(book: Book) {
        self.book = book
    }
}

struct ContentView: View {
    
    @Environment(\.modelContext) private var modelContext
    @Query(filter: #Predicate<WordItem> { $0.accessed }, sort: \WordItem.lastAccess, order: .reverse) var wordItems: [WordItem]
    
    // @Query private var items: [Item]
    @State var session = AudioSession()
    private var books = BooksStore()
    
    init() {
        session.activateSession()
    }
    
    var body: some View {
        VStack {
            NavigationStack {
                List {
                    ForEach(books.books, id: \.id) { book in
                        BookView(book: book)
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
        .modelContainer(for: BookModel.self, inMemory: true)
}
