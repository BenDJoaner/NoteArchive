//
//  BookPage.swift
//  NoteArchive
//
//  Created by 梁骐显 on 2025/3/11.
//

import SwiftUI
import PencilKit
import Pages

struct BookPageView: View {
    @ObservedObject var cover: Cover
    @State private var index: Int = 0
    @State private var canvasView = PKCanvasView()
    @State private var toolPicker = PKToolPicker()
    @State private var selectedBackground: BackgroundType = .blank
    @State private var drawingPages: [DrawingPage] = []

    var body: some View {
        var pages = canvasToPage(cover: cover)
        ModelPages(pages, currentPage: $index, transitionStyle: .scroll) { i, page in
            GeometryReader { geometry in
                            CanvasView(canvasView: $canvasView, toolPicker: toolPicker, onDrawingChange: saveCurrentPage, background: selectedBackground)
            }
        }.onAppear{
            loadPages()
        }
    }

    // MARK: - 画板相关方法

    private func setupToolPicker() {
        toolPicker.setVisible(true, forFirstResponder: canvasView)
        toolPicker.addObserver(canvasView)
        canvasView.becomeFirstResponder()
    }

    private func loadPages() {
        if drawingPages.isEmpty {
            addNewPage()
        } else {
            drawingPages.sort { $0.page < $1.page }
            loadCanvasData()
        }
    }

    private func addNewPage() {
        let newPage = DrawingPage()
        newPage.data = PKCanvasView().drawing.dataRepresentation()
        newPage.page = Int32(drawingPages.count + 1)
        drawingPages.append(newPage)
    }

    private func loadCanvasData() {
        if let pageData = drawingPages[index].data,
           let drawing = try? PKDrawing(data: pageData) {
            canvasView.drawing = drawing
        }
    }

    private func saveCurrentPage() {
        drawingPages[index].data = canvasView.drawing.dataRepresentation()
    }

    private func clearCurrentPage() {
        canvasView.drawing = PKDrawing()
        saveCurrentPage()
    }

    private func saveBackground() {
        // 保存背景逻辑
    }
}

struct BookCanvasView {
    var canvaPage: DrawingPage
}


func canvasToPage(cover: Cover) -> [BookCanvasView] {
    var drawingPages = cover.drawingPages?.allObjects as? [DrawingPage]
    var canvasView = PKCanvasView()
    if ((drawingPages?.isEmpty) != nil) {
        let newPage = DrawingPage()
        newPage.data = PKCanvasView().drawing.dataRepresentation()
        newPage.page = Int32(drawingPages!.count + 1)
//        drawingPages.append(newPage)
    } else {
        drawingPages!.sort { $0.page < $1.page }
        if let pageData = drawingPages![0].data,
           let drawing = try? PKDrawing(data: pageData) {
            canvasView.drawing = drawing
        }
    }
    var pages = [BookCanvasView]()
    print("传入Canvas Page >>> \(drawingPages!.count)")
    for i in 0..<drawingPages!.count {
        print("添加Canvas Page >>> \(i)/\(drawingPages!.count)")
        pages.append(BookCanvasView(canvaPage: drawingPages![i]))
    }

    return pages

}
