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
    var canvasView: PKCanvasView
    var selectedImages: [UIImage] = []
    var imageTransforms: [ImageInfo] = []
}

struct BookPageView: View {
    @ObservedObject var cover: Cover
    @State var currentPageIndex: Int

    // 获取当前系统颜色方案
    @Environment(\.colorScheme) var colorScheme
    
    @State var toolPicker = PKToolPicker()
    @State var bookPages:[BookCanvasView]
    // 添加背景样式绑定
    @Binding var isToolPickerVisible: Bool // 新增绑定
    @Binding var backgroundStyle: BackgroundStyle
    var saveCurrentPage: () -> Void
    var addNewPage: () -> Void
    var saveContext: () -> Void
    
    @State var frameCount: Int = 0
    @Binding var showImagePicker: Bool
    @Binding var isEditingImage: Bool
    @Binding var gridSpacing: CGFloat
    var body: some View {
        ModelPages(
            bookPages,
            currentPage: $currentPageIndex,
            transitionStyle: .pageCurl,
            hasControl: false
        ) { i, page in
            GeometryReader { geometry in
                PhotoPanelView(
                    showImagePicker: $showImagePicker // 使用绑定传递
                )
                if !isEditingImage {
                    CanvasView(
                        canvasView: page.canvasView,
                        toolPicker: toolPicker,
                        backgroundStyle: $backgroundStyle,// 传递背景样式
                        isToolPickerVisible: $isToolPickerVisible,
                        gridSpacing: $gridSpacing, // 传递绑定
                        onDrawingChange: saveCurrentPage
                    )
    //                .contentShape(Rectangle()) // ✅ 确保整个区域可触发手势
                    .allowsHitTesting(true)    // ✅ 允许交互穿透
                    // 页码显示 - 添加在底部右侧
                    Text("-\(i+1)-")
                        .font(.system(size: 14, weight: .regular))
                        .foregroundColor(Color(.systemGray3))
                        .padding(10)
    //                    .background(Color.white.opacity(0.8))
    //                    .cornerRadius(5)
                        .frame(
                            maxWidth: .infinity,
                            maxHeight: .infinity,
                            alignment: .bottom // 右下对齐
                        )
                        .padding(.trailing, 20)
                        .padding(.bottom, 5)
                }
            }
            .background(backgroundColors) // 使用动态颜色
        }
        onPageChangeSuccess: { index, isForward in
//            if isForward {
//                print("Page change success: \(index) (forward)")
//            } else {
//                print("Page change success: \(index) (backward)")
//            }
        }
        onPageChangeCancel: { index in
//            print("Page change canceled: \(index)")
        }
        onLastPageReached: { index in
//            print("Last page reached: \(index)")
            addNewPage()
        }
        .padding()
        .shadow(radius: 5)
        .onAppear() {
            for i in 0..<bookPages.count {
                DrawPageCanvas(pageIndex: i)
            }
        }
    }

    private func DrawPageCanvas(pageIndex: Int) {
        guard currentPageIndex >= 0 && currentPageIndex < bookPages.count else {
            print("Error: currentPageIndex is out of bounds")
            return
        }

        if let pageData = bookPages[currentPageIndex].pageData.data {
            do {
                let drawing = try PKDrawing(data: pageData)
                bookPages[currentPageIndex].canvasView.drawing = drawing
            } catch {
                print("Error: PKDrawing initialization failed with error: \(error)")
                bookPages[currentPageIndex].canvasView.drawing = PKDrawing()
            }
        } else {
            print("Error: pageData is nil")
            bookPages[currentPageIndex].canvasView.drawing = PKDrawing()
        }
    }
    
    // 根据颜色方案返回对应颜色
    private var backgroundColors: Color {
        colorScheme == .dark ? .themeBG : .background
    }
}
