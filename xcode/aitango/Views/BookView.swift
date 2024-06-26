//
//  BookView.swift
//  aitango
//
//  Created by SATOSHI NAKAJIMA on 6/24/24.
//

import Foundation
import SwiftUI
import SwiftData

struct BookView: View {
    @Environment(\.modelContext) private var modelContext
    
    private let book: Book
    @State var words: [String]
    @State private var filterLevel = Level.none
    
    var body: some View {
        NavigationLink {
            VStack {
                Picker("Level", selection: $filterLevel) {
                    ForEach(Level.allCases) { level in
                        Text(level.rawValue)
                    }
                }.pickerStyle(.segmented)
                    .padding([.leading, .trailing], 10)
                    .colorMultiply(filterLevel.color())
                    .onChange(of: filterLevel) {
                        if filterLevel == .none {
                            words = book.words
                        } else {
                            // let predicate = #Predicate<BookModel> { $0.bookId == book.id && $0.wordItem.level == filterLevel }
                            let bookId = book.id
                            let predicate = #Predicate<BookModel> { $0.bookId == bookId }
                            let descriptor = FetchDescriptor<BookModel>(predicate: predicate)
                            do {
                                let bookModels = try modelContext.fetch(descriptor)
                                words = bookModels.filter({ bookModel in
                                    guard let wordItem = bookModel.wordItem else { return false }
                                    return wordItem.level == filterLevel
                                }).map({ bookModel in
                                    return bookModel.wordItem!.id // safe cast (see the guard above)
                                })
                            } catch {
                                print("BookView.onChange failed \(error)")
                            }
                        }
                    }
                List {
                    ForEach(words, id: \.self) { word in
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
        self.words = book.words
    }
}
