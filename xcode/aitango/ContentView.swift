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
    // @Query private var items: [Item]
    @State var session = AudioSession()
    private var books = BooksModel()
    
    init() {
        session.activateSession()
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
}

#Preview {
    ContentView()
        .modelContainer(for: Item.self, inMemory: true)
}
