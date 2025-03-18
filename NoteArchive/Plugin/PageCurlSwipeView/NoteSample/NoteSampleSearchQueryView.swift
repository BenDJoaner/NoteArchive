//
//  SearchQueryView.swift
//  NotesApp
//
//  Created by Xiaofu666 on 2024/9/26.
//

import SwiftUI
import SwiftData

struct NoteSampleSearchQueryView<Content: View>: View {
    init(searchText: String, @ViewBuilder content: @escaping ([NoteSampleNoteModel]) -> Content) {
        self.content = content
        
        let predicate = #Predicate<NoteSampleNoteModel>{ input in
            return searchText.isEmpty || input.title.localizedStandardContains(searchText)
        }
        _notes = .init(filter: predicate, sort: [.init(\.dateCreated, order: .reverse)], animation: .snappy)
    }
    
    var content: ([NoteSampleNoteModel]) -> Content
    @Query var notes: [NoteSampleNoteModel]
    
    var body: some View {
        content(notes)
    }
}
