//
//  BookPageView.swift
//  NoteArchive
//
//  Created by BC on 2025/3/19.
//

import SwiftUICore
import PencilKit


struct BookCanvasView {
    var pageData: DrawingPage
    var index: Int
//    var canvasView: PKCanvasView
}

struct BookPageView: View {
    @ObservedObject var cover: Cover
    @State var currentPageIndex: Int
    
    @Binding var currentCanvasView: PKCanvasView
    @State var nextCanvasView = PKCanvasView()
    
    @State var toolPicker = PKToolPicker()
    @State var selectedBackground: BackgroundType = .blank
    @State var bookPages:[BookCanvasView]
    @State var pageDatas: [DrawingPage]
    
    var saveCurrentPage: () -> Void
    var addNewPage: () -> Void
    @State var frameCount: Int = 0
    var body: some View {
        ModelPages(
            bookPages,
            currentPage: $currentPageIndex,
//            navigationOrientation: .horizontal,
//            currentPage: currentPageIndex,
            transitionStyle: .pageCurl,
//            bounce: false
//            wrap: true
//            controlAlignment: .trailingFirstTextBaseline
            hasControl: false
        ) { i, page in
            GeometryReader { geometry in
                CanvasView(
                    canvasView: $currentCanvasView,
                    toolPicker: toolPicker,
                    onDrawingChange: saveCurrentPage,
                    background: selectedBackground
                )
                let _count = addFrameCount()
                
                Text("Book Page >>>> \(i) -> \n currentPageIndex=\(currentPageIndex)/\(bookPages.count)\nCount=\(_count)")
                    .font(.title)
                    .padding()
                
            }
            .background(Color.white)

        }
        onPageChangeSuccess: { index, isForward in
            if isForward {
                print("Page change success: \(index) (forward)")
                nextPage()
            } else {
                print("Page change success: \(index) (backward)")
                previousPage()
            }
//            DrawPageCanvas(pageIndex: currentPageIndex)
        }
        onPageChangeCancel: { index in
            print("Page change canceled: \(index)")
        }
        onLastPageReached: { index in
            print("Last page reached: \(index)")
            addNewPage()
        }
        .padding()
        .shadow(radius: 5)
        .onAppear() {
            setupToolPicker()
            DrawPageCanvas(pageIndex: currentPageIndex)
        }
    }
    
    private func addFrameCount() -> Int {
        frameCount = frameCount + 1
        return frameCount
    }
    
    private func setupToolPicker() {
        toolPicker.setVisible(true, forFirstResponder: currentCanvasView)
        toolPicker.addObserver(currentCanvasView)
        currentCanvasView.becomeFirstResponder()
    }
    
    private func DrawPageCanvas(pageIndex: Int){
        if let pageData = pageDatas[currentPageIndex].data,
           let drawing = try? PKDrawing(data: pageData) {
            currentCanvasView.drawing = drawing
        }
    }
    
    private func nextPage() {
        saveCurrentPage()
        if currentPageIndex < pageDatas.count - 1 {
            currentPageIndex += 1
        } else {
            addNewPage()
            currentPageIndex += 1
        }
    }

    private func previousPage() {
        if currentPageIndex == 0 {
            return
        }
        saveCurrentPage()
        if currentPageIndex > 0 {
            currentPageIndex -= 1
        }
    }

}
