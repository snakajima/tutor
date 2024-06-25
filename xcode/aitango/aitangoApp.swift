//
//  aitangoApp.swift
//  aitango
//
//  Created by SATOSHI NAKAJIMA on 6/15/24.
//

import SwiftUI
import SwiftData
import FirebaseCore

@main
struct aitangoApp: App {
    // https://peterfriese.dev/blog/2020/swiftui-new-app-lifecycle-firebase/#start-using-the-swiftui-app-life-cycle
    init() {
        FirebaseApp.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: BookModel.self)
    }
}
