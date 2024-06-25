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
                .accentColor(Color(red: 0, green: 120/255, blue: 189/255))
        }
        .modelContainer(for: BookModel.self)
    }
}
