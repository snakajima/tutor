//
//  HistoryView.swift
//  aitango
//
//  Created by SATOSHI NAKAJIMA on 6/24/24.
//

import Foundation
import SwiftUI
import SwiftData

struct HistoryView: View {
    
    @Environment(\.modelContext) private var modelContext
    let wordItems: [WordItem] // Note: Using Query here causes inifinit loop
    
    init(wordItems: [WordItem]) {
        self.wordItems = wordItems
    }
    
    var body: some View {
        List {
            ForEach(wordItems) { wordItem in
                WordLinkView(word: wordItem.id, bookId: "_history")
            }
        }
    }
}
