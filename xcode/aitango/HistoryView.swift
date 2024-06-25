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
    @Query(filter: #Predicate<WordItem> { $0.accessed }, sort: \WordItem.lastAccess, order: .reverse) var wordItems: [WordItem]
    
    var body: some View {
        List {
            ForEach(wordItems) { wordItem in
                WordLinkView(word: wordItem.id, bookId: "_history")
            }
        }
    }
}
