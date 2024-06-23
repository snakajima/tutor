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
