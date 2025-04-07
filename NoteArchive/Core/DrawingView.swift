import SwiftUI
import Vision
import PencilKit
import CoreData


struct DrawingView: View {
    @ObservedObject var cover: Cover
    @Environment(\.managedObjectContext) private var viewContext
    @State private var currentPageIndex = 0
    @State private var bookPages: [BookCanvasView] = []
    @State private var isAnalyze: Bool = false
    @State private var usePencil: Bool = true
    @State private var isShowTool: Bool = false
    // 添加背景样式状态
    @State private var backgroundStyle: BackgroundStyle = .blank
    @State private var isToolPickerVisible = true // 新增状态
    var namespace: Namespace.ID // 接收命名空间
    @State private var showImagePicker: Bool = false

    var body: some View {
        ZStack {
//            Color(.systemGray6)// 灰色背景
//                .edgesIgnoringSafeArea(.all)

            if !bookPages.isEmpty { // 确保 pageDatas 被赋值后才渲染 BookPageView
                BookPageView(
                    cover: cover,
                    currentPageIndex: currentPageIndex,
                    bookPages: bookPages ,
                    isToolPickerVisible: $isToolPickerVisible,
                    backgroundStyle: $backgroundStyle, // 传递绑定
                    saveCurrentPage: saveCurrentPage,
                    addNewPage:addNewPage,// 传递背景样式绑定
                    saveContext: saveContext,
                    showImagePicker: $showImagePicker
                )
            }
        }
        .navigationBarTitle("\(cover.title ?? "")", displayMode: .inline)
        .onAppear {
            loadPages()
            // 从CoreData加载背景设置
            let saved = BackgroundStyle.from(string: cover.selectedBackground)
            print("Loaded background: \(saved.rawValue)") // ✅ 调试输出
            self.backgroundStyle = saved
        }
        .onDisappear {
            saveCurrentPage()
        }
        .toolbar {
            // 添加图片
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    showImagePicker = true
                } label: {
                    Image(systemName: "photo.fill")
                        .foregroundColor(Color(.systemBlue))
                }
                .tint(.black)
            }
            // 新增工具选择器切换按钮
            ToolbarItem(placement: .navigationBarTrailing) {
                ToggleButton(
                    isOn: $isToolPickerVisible,
                    onImageString: "pencil.tip.crop.circle.fill",
                    offImageString: "pencil.tip.crop.circle"
                )
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    showToolPicker()
                } label: {
                    Image(systemName: "slider.horizontal.3")
                        .foregroundColor(Color(.systemBlue))
                }
                .tint(.black)
            }
        }
        .sheet(isPresented: $isShowTool, content: {
            ButtonBarView(
                onClear: clearCurrentPage,
                onAddPhoto: loadImage,
                onAddPDF: loadPDF,
                onDeletePage: onDeletePage,
                isAIOn: $isAnalyze,
                usePencil: $usePencil,
                backgroundStyle: $backgroundStyle,
                currentPageIndex: $currentPageIndex,
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
        isShowTool = true
    }

    private func onDeletePage() {
        // 边界检查：至少保留1页
        guard bookPages.count > 1 else {
            print("atLessOnePage")
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
        isAnalyze = cover.isAnalyze
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
            if isAnalyze {
                let image = pageData.canvasView.toImage()
                recognizeText(from: image) { text in
                    pageData.pageData.textData = text
                    print("regonizeText: \(text)")
                }
            }

        }
//        bookPages[currentPageIndex].pageData.data = bookPages[currentPageIndex].canvasView.drawing.dataRepresentation()
//        pageDatas[currentPageIndex].createdAt = Date() // 更新最后编辑日期
        
        print("saveCurrentPage")
        
        print("Saving background: \(backgroundStyle.rawValue)") // ✅ 调试输出
        cover.selectedBackground = backgroundStyle.rawValue
        cover.isAnalyze = isAnalyze
        saveContext()
    }

    private func clearCurrentPage() {
        bookPages[currentPageIndex].canvasView.drawing = PKDrawing()
        saveCurrentPage()
    }


    private func loadImage(selectImage: UIImage, index:Int) {
        // 获取当前页面的pageData
        let currentPageData = bookPages[currentPageIndex].pageData
        
        // 创建新ImageItem
        let newImageItem = ImageItem(context: viewContext)
        newImageItem.imageData = selectImage.pngData()
        
        // 设置默认位置（居中显示）
        let defaultSize = CGSize(width: 200, height: 200)
        newImageItem.x = Double(UIScreen.main.bounds.width/2 - defaultSize.width/2)
        newImageItem.y = Double(UIScreen.main.bounds.height/2 - defaultSize.height/2)
        newImageItem.width = Double(defaultSize.width)
        newImageItem.height = Double(defaultSize.height)
        
        // 关联到当前页面
        currentPageData.addImage(newImageItem)
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
    
    func recognizeText(from image: UIImage, completion: @escaping (String) -> Void) {
        guard let cgImage = image.cgImage else { return }
        
        let request = VNRecognizeTextRequest { (request, error) in
            guard let observations = request.results as? [VNRecognizedTextObservation] else { return }
            
            var recognizedText = ""
            for observation in observations {
                if let topCandidate = observation.topCandidates(1).first {
                    recognizedText += topCandidate.string + "\n"
                }
            }
            
            completion(recognizedText)
        }
        
        request.recognitionLevel = .accurate
        // 2. 多語言識別支持
        request.recognitionLanguages = [Locale.current.identifier, "en-US"]
        
        let requestHandler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        try? requestHandler.perform([request])
    }
}
// 独立封装的切换按钮组件
struct ToggleButton: View {
    @Binding var isOn: Bool
    var onImageString: String
    var offImageString: String
    
    var body: some View {
        Button(action: { isOn.toggle() }) {
            Image(systemName: isOn ? onImageString:offImageString)
                .symbolRenderingMode(.multicolor)
        }
    }
}

extension DrawingPage {
    var imagesArray: [ImageItem] {
        return (images?.allObjects as? [ImageItem]) ?? []
    }
    
    func addImage(_ imageItem: ImageItem) {
        self.addToImages(imageItem)
    }
}
