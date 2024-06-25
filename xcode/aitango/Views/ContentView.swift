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

struct ContentView: View {
    
    @Environment(\.modelContext) private var modelContext
    @Query(filter: #Predicate<WordItem> { $0.accessed }, sort: \WordItem.lastAccess, order: .reverse) var wordItems: [WordItem]

    // @Query private var items: [Item]
    @State var session = AudioSession()
    private let books = BooksStore()
    
    init() {
        session.activateSession()
    }
    
    var body: some View {
        VStack {
            NavigationStack {
                Text("英単語エージェント")
                List {
                    Section("単語帳") {
                        ForEach(books.books, id: \.id) { book in
                            BookView(book: book)
                        }
                    }
                    Section("History") {
                        HistoryView(wordItems: wordItems)
                    }
                }.listStyle(.grouped)
                   // .navigationTitle("英単語エージェント")
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
