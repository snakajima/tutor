//
//  aitangoApp.swift
//  aitango
//
//  Created by SATOSHI NAKAJIMA on 6/15/24.
//

import SwiftUI
import SwiftData
import FirebaseCore
import CloudKit
import CoreData

@main
struct aitangoApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            BookModel.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
#if DEBUG
    // Use an autorelease pool to make sure Swift deallocates the persistent
    // container before setting up tdhe SwiftData stack.
    try autoreleasepool {
        let desc = NSPersistentStoreDescription(url: modelConfiguration.url)
        let opts = NSPersistentCloudKitContainerOptions(containerIdentifier: "iCloud.org.singularitysociety.aitango")
        desc.cloudKitContainerOptions = opts
        // Load the store synchronously so it completes before initializing the
        // CloudKit schema.
        desc.shouldAddStoreAsynchronously = false
        if let mom = NSManagedObjectModel.makeManagedObjectModel(for: [BookModel.self, WordItem.self]) {
            let container = NSPersistentCloudKitContainer(name: "aitango", managedObjectModel: mom)
            container.persistentStoreDescriptions = [desc]
            container.loadPersistentStores {_, err in
                if let err {
                    fatalError(err.localizedDescription)
                }
            }
            // Initialize the CloudKit schema after the store finishes loading.
            try container.initializeCloudKitSchema()
            // Remove and unload the store from the persistent container.
            if let store = container.persistentStoreCoordinator.persistentStores.first {
                try container.persistentStoreCoordinator.remove(store)
            }
        }
    }
#endif             
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()
    // https://peterfriese.dev/blog/2020/swiftui-new-app-lifecycle-firebase/#start-using-the-swiftui-app-life-cycle
    init() {
        FirebaseApp.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .accentColor(Color(red: 0, green: 120/255, blue: 189/255))
        }
        .modelContainer(sharedModelContainer)
    }
}
