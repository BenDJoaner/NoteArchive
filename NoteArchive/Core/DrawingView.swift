import SwiftUI
import Vision
import PencilKit
import CoreData


struct DrawingView: View {
    @ObservedObject var cover: Cover
    @Environment(\.managedObjectContext) private var viewContext
    @State private var currentPageIndex = 0
    @State private var bookPages: [BookCanvasView] = []
    @State private var useAI: Bool = false
    @State private var usePencil: Bool = true
    @State private var changeTheme: Bool = false
    @State private var stickImage: UIImage = UIImage()
    // 添加背景样式状态
//    @State private var backgroundStyle: BackgroundStyle = .blank
    @State private var isToolPickerVisible = false // 新增状态
    var namespace: Namespace.ID // 接收命名空间
    

    var body: some View {
        ZStack {
            Color.gray.opacity(0.2) // 灰色背景
                .edgesIgnoringSafeArea(.all)

            if !bookPages.isEmpty { // 确保 pageDatas 被赋值后才渲染 BookPageView
                BookPageView(
                    cover: cover,
                    currentPageIndex: currentPageIndex,
                    bookPages: bookPages ,
                    isToolPickerVisible: $isToolPickerVisible,
//                    backgroundStyle: $backgroundStyle, // 传递绑定
                    saveCurrentPage: saveCurrentPage,
                    addNewPage:addNewPage,// 传递背景样式绑定
                    saveContext: saveContext
                )
            }
        }
        .navigationBarTitle("\(cover.title ?? "空")", displayMode: .inline)
        .onAppear {
            loadPages()
            // 从CoreData加载背景设置
//            let saved = BackgroundStyle.from(string: cover.selectedBackground)
//            print("Loaded background: \(saved.rawValue)") // ✅ 调试输出
//            self.backgroundStyle = saved
        }
        .onDisappear {
            saveCurrentPage()
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    showToolPicker()
                } label: {
                    Image(systemName: "book.and.wrench")
                }
                .tint(.black)
            }
            // 新增工具选择器切换按钮
            ToolbarItem(placement: .navigationBarTrailing) {
                ToggleButton(isOn: $isToolPickerVisible)
            }
        }
        .sheet(isPresented: $changeTheme, content: {
            ButtonBarView(
                onClear: clearCurrentPage,
                onAddPhoto: loadImage,
                onAddPDF: loadPDF,
                onDeletePage: onDeletePage,
                isAIOn: $useAI,
                usePencil: $usePencil,
//                backgroundStyle: $backgroundStyle,
                currentCanvasView: bookPages[currentPageIndex].canvasView
                
                )
                .presentationDetents([.height(650)])
                .presentationBackground(.clear)
        })
//        .onChange(of: backgroundStyle) { newValue in
//            // 当背景变化时保存到CoreData
//            print("Saving background: \(newValue.rawValue)") // ✅ 调试输出
//            cover.selectedBackground = newValue.rawValue
//            saveContext()
//        }
    }
    


    private func showToolPicker() {
        changeTheme = true
    }

    private func onDeletePage() {
        // 边界检查：至少保留1页
        guard bookPages.count > 1 else {
            print("至少需要保留一页")
            return
        }
        
        // 1. 获取当前页并清理画布
        let deletedPage = bookPages[currentPageIndex].pageData
        bookPages[currentPageIndex].canvasView.drawing = PKDrawing()
        
        // 2. 从CoreData中删除
        viewContext.delete(deletedPage)
        
        // 3. 更新数据源
        bookPages.remove(at: currentPageIndex)
        
        // 4. 重新排序剩余页面的page属性
        for (index, page) in bookPages.enumerated() {
            page.pageData.page = Int32(index + 1) // page从1开始计数
        }
        
        // 5. 调整当前页码（优先保持当前索引，删除最后一页时自动前移）
        currentPageIndex = min(currentPageIndex, bookPages.count - 1)
        
        // 6. 同步更新bookPages
        bookPages = bookPages.enumerated().map { index, pageData in
            BookCanvasView(
                pageData: bookPages[currentPageIndex].pageData,
                index: index + 1,
                canvasView: bookPages[currentPageIndex].canvasView
            )
        }
        
        // 7. 保存变更
        saveContext()
        
        // 9. 如果删除的是最后一页且不是唯一页，需要更新封面关联
        cover.removeFromDrawingPages(deletedPage)
    }



    private func loadPages() {
        if let drawingPages = cover.drawingPages?.allObjects as? [DrawingPage] {
            if drawingPages.isEmpty {
                addNewPage()
            } else {
                let pageDatas = drawingPages.sorted { $0.page < $1.page }
                for pageData in pageDatas {
                    loadCanvasData(pageData: pageData)
                }
            }
        } else {
            addNewPage()
        }
        if bookPages.count < 2 {
            addNewPage()
        }
    }
    
    private func addNewPage() {
        if bookPages.count >= 20 {
            return
        }
        let newPage = DrawingPage(context: viewContext)
        newPage.data = PKCanvasView().drawing.dataRepresentation()
        newPage.createdAt = Date()
        newPage.cover = cover
        newPage.page = Int32(bookPages.count + 1)
        
        loadCanvasData(pageData: newPage)
        saveContext()
    }

    private func loadCanvasData(pageData: DrawingPage) {
        // 1. 创建 PKCanvasView 实例
        let canvasView = PKCanvasView()
        
        // 2. 从 CoreData 加载绘图数据
        if let data = pageData.data {
            do {
                let drawing = try PKDrawing(data: data)
                canvasView.drawing = drawing
            } catch {
                print("Error loading drawing: \(error)")
                canvasView.drawing = PKDrawing() // 加载失败时初始化为空白
            }
        } else {
            canvasView.drawing = PKDrawing() // 无数据时初始化为空白
        }
        
        // 3. 将加载后的 canvasView 添加到页面列表
        bookPages.append(
            BookCanvasView(
                pageData: pageData,
                index: Int(pageData.page),
                canvasView: canvasView
            )
        )
    }

    private func saveCurrentPage() {
        for pageData in bookPages {
            pageData.pageData.data = pageData.canvasView.drawing.dataRepresentation()
        }
//        bookPages[currentPageIndex].pageData.data = bookPages[currentPageIndex].canvasView.drawing.dataRepresentation()
//        pageDatas[currentPageIndex].createdAt = Date() // 更新最后编辑日期
        
        print("saveCurrentPage")
        saveContext()
    }

    private func clearCurrentPage() {
        bookPages[currentPageIndex].canvasView.drawing = PKDrawing()
        saveCurrentPage()
    }


    private func loadImage(selectImage: UIImage) {

        saveContext()
    }

    private func saveContext() {
        do {
            try viewContext.save()
        } catch {
            print("保存失败: \(error.localizedDescription)")
        }
    }
    
    private func loadPDF(){
        
    }

    private func updateBackground() {
        // 更新画板背景
        // 背景逻辑在 CanvasView 中实现
        
    }
}
// 独立封装的切换按钮组件
struct ToggleButton: View {
    @Binding var isOn: Bool
    
    var body: some View {
        Button(action: { isOn.toggle() }) {
            Image(systemName: isOn ?
                  "pencil.tip.crop.circle.badge.minus" :
                    "pencil.tip.crop.circle.badge.plus.fill")
                .symbolRenderingMode(.multicolor)
        }
    }
}
