//
//  TextEditView.swift
//  NoteArchive
//
//  Created by 梁骐显 on 2025/3/18.
//

import SwiftUI
import CoreData

struct TextEditView: View {
    @ObservedObject var cover: Cover
    @Environment(\.managedObjectContext) private var viewContext
    @State private var currentPage: Int = 0
    @State private var pageDatas: [DrawingPage] = []
    var body: some View {
        if !pageDatas.isEmpty { // 确保 pageDatas 被赋值后才渲染 BookPageView
            ModelPages(
                pageDatas,
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
                            get: { page.textData ?? "" },
                            set: { page.textData = $0 }
                        ))
                        .font(.body)
                        .padding(.horizontal)
                        Divider()
                    }
                    .padding()
                },
                onPageChangeSuccess: { index, isForward in
                    if index == pageDatas.count - 1 {
                        addNewPage()
                    }
                },
                onPageChangeCancel: { _ in },
                onLastPageReached: { _ in }
            )
            .onAppear {
                loadPages()
            }
            .onDisappear {
                saveCurrentPage()
            }
        }

    }
    
    private func loadPages() {
        if let drawingPages = cover.drawingPages?.allObjects as? [DrawingPage] {
            if drawingPages.isEmpty {
                addNewPage()
            } else {
                pageDatas = drawingPages.sorted { $0.page < $1.page }
            }
        } else {
            addNewPage()
        }
        if pageDatas.count < 2 {
            addNewPage()
        }
    }
    
    private func addNewPage() {
        let newPage = DrawingPage(context: viewContext)
        newPage.createdAt = Date()
        newPage.page = Int32(pageDatas.count + 1)
        pageDatas.append(newPage)
        
        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }

    private func loadCanvasData() {
        if let pageData = pageDatas[currentPage].data{

        }
    }

    private func saveCurrentPage() {
        print("saveCurrentPage")
        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }
}
