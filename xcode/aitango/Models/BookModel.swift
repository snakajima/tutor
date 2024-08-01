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
    var id: String = "foo/bar" // random default for CloudKit
    var bookId: String = "foo" // random default for CloudKit
    var wordItem: WordItem? // optional for CloudKit
    
    init(bookId:String, wordItem: WordItem) {
        self.id = "\(bookId)/\(wordItem.id)"
        self.bookId = bookId
        self.wordItem = wordItem
    }
    
    public static func getItem(modelContext: ModelContext, bookId: String, wordItem: WordItem) -> BookModel? {
        let id = "\(bookId)/\(wordItem.id)"
        let predicate = #Predicate<BookModel> { $0.id == id }
        let descriptor = FetchDescriptor<BookModel>(predicate: predicate)
        do {
            let bookModels = try modelContext.fetch(descriptor)
            if let bookModel = bookModels.first {
                return bookModel
            }
            print("BookModel: inserting", id)
            let bookModel = BookModel(bookId: bookId, wordItem: wordItem)
            modelContext.insert(bookModel)
            return bookModel
        } catch {
            print("BookModel.getItem failed \(id)")
            return nil
        }
    }
}
