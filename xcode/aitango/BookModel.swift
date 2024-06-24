//
//  BookModel.swift
//  aitango
//
//  Created by SATOSHI NAKAJIMA on 6/24/24.
//

import Foundation
import SwiftData

@Model
final class BookModel {
    @Attribute(.unique) var id: String
    var bookId: String
    var wordItem: WordItem
    
    init(bookId:String, wordItem: WordItem) {
        self.id = "\(bookId)/\(wordItem.id)"
        self.bookId = bookId
        self.wordItem = wordItem
    }
}
