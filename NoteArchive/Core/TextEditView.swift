//
//  TextEditView.swift
//  NoteArchive
//
//  Created by 梁骐显 on 2025/3/18.
//

import SwiftUI
import CoreData

struct TextEditView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @State private var currentPage: Int = 0
    @State private var textPages: [TextPageData] = []

    var body: some View {
        if !textPages.isEmpty { // 确保 pageDatas 被赋值后才渲染 BookPageView
            ModelPages(
                textPages,
                currentPage: $currentPage,
                navigationOrientation: .horizontal,
                transitionStyle: .scroll,
                bounce: true,
                wrap: false,
                hasControl: true,
                controlAlignment: .bottom,
                currentTintColor: .white,
                tintColor: .gray,
                template: { index, page in
                    VStack(alignment: .leading, spacing: 20) {
                        TextField("Title", text: Binding(
                            get: { page.title ?? "" },
                            set: { page.title = $0 }
                        ))
                        .font(.title)
                        .padding(.horizontal)
                        Divider()
                        TextEditor(text: Binding(
                            get: { page.content ?? "" },
                            set: { page.content = $0 }
                        ))
                        .font(.body)
                        .padding(.horizontal)
                        Divider()
                    }
                    .padding()
                },
                onPageChangeSuccess: { index, isForward in
                    if index == textPages.count - 1 {
                        addNewPage()
                    }
                },
                onPageChangeCancel: { _ in },
                onLastPageReached: { _ in }
            )
            .onAppear {
                if textPages.isEmpty {
                    addNewPage()
                    addNewPage()
                }
            }
            
        }

    }

    private func addNewPage() {
        let newPage = TextPageData(context: viewContext)
        newPage.title = "New Page"
        newPage.content = ""
        newPage.createdAt = Date()
        textPages.append(newPage)
        saveContext()
    }

    private func saveContext() {
        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }
}
