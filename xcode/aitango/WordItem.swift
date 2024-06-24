//
//  WordItem.swift
//  aitango
//
//  Created by SATOSHI NAKAJIMA on 6/23/24.
//

import Foundation
import SwiftData

enum Level: String, Codable {
    case none = "none"
    case red = "red"
    case orange = "orange"
    case yellow = "yellow"
    case green = "green"
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
