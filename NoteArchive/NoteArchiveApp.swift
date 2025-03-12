//
//  NoteArchiveApp.swift
//  NoteArchive
//
//  Created by 梁骐显 on 2025/3/8.
//

import SwiftUI

@main
struct NoteArchiveApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
