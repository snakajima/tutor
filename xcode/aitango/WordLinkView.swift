//
//  WordLinkView.swift
//  aitango
//
//  Created by SATOSHI NAKAJIMA on 6/24/24.
//

import Foundation
import SwiftUI

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
                guard let wordItem = WordItem.getItem(modelContext: modelContext, word: word) else { return }
                self.wordItem = wordItem
            }
        }
    }
}
