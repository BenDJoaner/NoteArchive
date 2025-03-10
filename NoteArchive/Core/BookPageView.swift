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
    let pages = bookToPages(charsInPage: 1400)
    @State private var index: Int = 0
    @State private var canvasView = PKCanvasView()
    @State private var toolPicker = PKToolPicker()
    @State private var selectedBackground: BackgroundType = .blank
    @State private var drawingPages: [DrawingPage] = []

    var body: some View {
        ZStack {
            Color.gray.opacity(0.2) // 灰色背景
                .edgesIgnoringSafeArea(.all)
            
            // 画板区域
            ModelPages(pages, currentPage: $index, transitionStyle: .pageCurl) { i, page in
                GeometryReader { geometry in
                    VStack {
                        if i == 0 {
                            Text("How I Did It")
                                .font(.system(size: 65, weight: .bold))
                                .bold()
                            Text("By Victor Frankenstein")
                                .font(.title)
                                .bold()
                                .padding(.bottom)
                        }
                        
                        // 画板
                        CanvasView(canvasView: $canvasView, toolPicker: toolPicker, onDrawingChange: saveCurrentPage, background: selectedBackground)
                        
                        Spacer()
                        
                        HStack {
                            Spacer()
                            Text("Page \(i + 1)")
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding()
                }
            }
//            .onPageChanged { index in
//                if index == pages.count - 1 {
//                    addNewPage()
//                }
//                loadCanvasData()
//            }
            
            // 按钮区域
//            VStack {
//                ButtonBarView(
//                    onClear: clearCurrentPage,
//                    onBackgroundChange: { background in
//                        selectedBackground = background
//                        saveBackground()
//                    },
//                    selectedBackground: $selectedBackground
//                )
//                Spacer()
//            }
//            .padding(.top)
        }
        .onAppear {
            setupToolPicker()
            loadPages()
        }
        .onDisappear {
            saveCurrentPage()
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
