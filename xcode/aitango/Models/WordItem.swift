//
//  WordItem.swift
//  aitango
//
//  Created by SATOSHI NAKAJIMA on 6/23/24.
//

import Foundation
import SwiftData
import SwiftUI

enum Level: String, CaseIterable, Identifiable, Codable {
    case none
    case red
    case orange
    case yellow
    case green
    case blue
    var id: Self { self }
    
    public func color() -> Color {
        switch(self) {
        case .none:
            return .gray
        case .red:
            return .red
        case .orange:
            return .orange
        case .yellow:
            return .yellow
        case .green:
            return .green
        case .blue:
            return .blue
        }
    }
}

@Model
final class WordItem {
    var id: String = "foo" // random default for CloudKit
    var lastAccess: Date = Date(timeIntervalSince1970: 0) // random default for CloudKit
    var level: Level = Level.none
    var accessed = false
    @Relationship(inverse:\BookModel.wordItem) var books: [BookModel]?
    
    init(word: String) {
        self.id = word
        self.lastAccess = Date()
        self.level = .none
        self.books = [] // for CloudKit (not sure)
    }
    
    public func recordAccess() {
        accessed = true
        lastAccess = Date()
    }
    
    public static func getItem(modelContext: ModelContext, word: String) -> WordItem? {
        let predicate = #Predicate<WordItem> { $0.id == word }
        let descriptor = FetchDescriptor<WordItem>(predicate: predicate)
        do {
            let wordItems = try modelContext.fetch(descriptor)
            if let wordItem = wordItems.first {
                return wordItem
            }
            print("WordItem: inserting", word)
            let wordItem = WordItem(word: word)
            modelContext.insert(wordItem)
            return wordItem
        } catch {
            print("WordItem.getItem failed \(word), \(error)")
            return nil
        }
    }
}
