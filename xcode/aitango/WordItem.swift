//
//  WordItem.swift
//  aitango
//
//  Created by SATOSHI NAKAJIMA on 6/23/24.
//

import Foundation
import SwiftData

enum Level: String, CaseIterable, Identifiable, Codable {
    case none
    case red
    case orange
    case yellow
    case green
    case blue
    var id: Self { self }
}

@Model
class WordItem {
    @Attribute(.unique) var id: String
    var lastAccess: Date
    var level: Level
    
    init(word: String) {
        self.id = word
        self.lastAccess = Date()
        self.level = .none
    }
}
