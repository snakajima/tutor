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
    let id = UUID()
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
                    print("doc=", document["title"] ?? "N/A")
                    return Book(title: document["title"] as! String, words: document["words"] as! [String])
                }
            }
    }
}

struct ContentView: View {
    
    @Environment(\.modelContext) private var modelContext
    @Query private var items: [Item]
    private var books = StoreBooks()
    
    var body: some View {
        NavigationSplitView {
            List {
                ForEach(books.books, id: \.id) { book in
                    NavigationLink {
                        Text(book.title)
                    } label: {
                        Text(book.title)
                    }
                }
                .onDelete(perform: deleteItems)
            }
#if os(macOS)
            .navigationSplitViewColumnWidth(min: 180, ideal: 200)
#endif
            .toolbar {
#if os(iOS)
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                }
#endif
                ToolbarItem {
                    Button(action: addItem) {
                        Label("Add Item", systemImage: "plus")
                    }
                }
            }
        } detail: {
            Text("Select an item")
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
