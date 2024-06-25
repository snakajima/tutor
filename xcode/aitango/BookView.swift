//
//  BookView.swift
//  aitango
//
//  Created by SATOSHI NAKAJIMA on 6/24/24.
//

import Foundation
import SwiftUI

struct BookView: View {
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
