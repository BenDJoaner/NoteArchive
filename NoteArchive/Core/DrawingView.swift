import SwiftUI
import PencilKit
import CoreData
import Pages

struct DrawingView: View {
    @ObservedObject var cover: Cover
    @Environment(\.managedObjectContext) private var viewContext
    @State private var canvasView = PKCanvasView()
    @State private var pageDatas: [DrawingPage] = []
    @State private var currentPageIndex = 0
    @State private var toolPicker = PKToolPicker()
    @State private var selectedBackground: BackgroundType = .blank // 当前背景类型
    @State private var isSwiping = false
    @State private var swipeDirection: SwipeDirection = .none
    @State private var bookPages: [BookCanvasView] = []
    @State private var canUseHand: Bool = false
    @State private var changeTheme: Bool = false
    @Environment(\.colorScheme) private var scheme: ColorScheme
    @AppStorage("userScheme") private var userTheme: Theme = .systemDefault
    
    var namespace: Namespace.ID // 接收命名空间
    
    enum SwipeDirection {
        case left
        case right
        case none
    }

    var body: some View {
        ZStack {
            Color.gray.opacity(0.2) // 灰色背景
                .edgesIgnoringSafeArea(.all)
            
            // 画板区域
            ZStack {
                ForEach(0..<pageDatas.count, id: \.self) { index in
                    if index == currentPageIndex {
                        CanvasView(canvasView: $canvasView, toolPicker: toolPicker, onDrawingChange: saveCurrentPage, background: selectedBackground, canUseHand: canUseHand)
//                            .matchedGeometryEffect(id: cover.id, in: namespace) // 添加 matchedGeometryEffect
                            .cornerRadius(8) // 画板圆角
                            .shadow(radius: 5) // 添加阴影
                        
                        
                        }
                }
            }
            .gesture(
                DragGesture()
                .onEnded { gesture in
                    if gesture.translation.width > 50 {
                        previousPage()
                    } else if gesture.translation.width < -50 {
                        nextPage()
                    } else if gesture.translation.height < -50 {
                        showToolPicker()
                    } else if gesture.translation.height > 50 {
                        hideToolPicker()
                    }
                }
            )
            .padding(10)
//            if !pageDatas.isEmpty { // 确保 pageDatas 被赋值后才渲染 BookPageView
//                BookPageView(cover: cover, currentPageIndex: currentPageIndex, bookPages: bookPages , canUseHand: canUseHand, saveCurrentPage: saveCurrentPage)
//            }
        }
        .navigationBarTitle("\(cover.title ?? "空")(\(currentPageIndex + 1)/\(pageDatas.count))", displayMode: .inline)
        .onAppear {
            setupToolPicker()
            loadPages()
            loadCanvasData()
            loadSelectedBackground() // 加载背景类型
        }
        .onDisappear {
            saveCurrentPage()
        }
        .sheet(isPresented: $changeTheme, content: {
//            ThemeChangeView(scheme: scheme)
//                .presentationDetents([.height(410)])
//                .presentationBackground(.clear)
            ButtonBarView(
                onClear: clearCurrentPage,
                onBackgroundChange: { background in
                    selectedBackground = background
                    cover.selectedBackground = background.rawValue
                    updateBackground()
                    saveBackground()
                },
                selectedBackground: $selectedBackground,
                isToggleOn: $canUseHand
                )
                .presentationDetents([.height(410)])
                .presentationBackground(.clear)
        })
    }

    private func nextPage() {
        saveCurrentPage()
//        DispatchQueue.main.async {
            if currentPageIndex < pageDatas.count - 1 {
                swipeDirection = .left
                currentPageIndex += 1
            } else {
                addNewPage()
                swipeDirection = .left
                currentPageIndex += 1
            }
            loadCanvasData()
//        }
    }

    private func previousPage() {
        saveCurrentPage()
//        DispatchQueue.main.async {
            if currentPageIndex > 0 {
                swipeDirection = .right
                currentPageIndex -= 1
            }
            loadCanvasData()
//        }
    }

    private func showToolPicker() {
//        if UIDevice.current.userInterfaceIdiom == .pad {
//            toolPicker.setVisible(true, forFirstResponder: canvasView)
//            canvasView.becomeFirstResponder()
//        }
        changeTheme = true
    }

    private func hideToolPicker() {
//        if UIDevice.current.userInterfaceIdiom == .pad {
//            toolPicker.setVisible(false, forFirstResponder: canvasView)
//            canvasView.resignFirstResponder()
//        }
//        changeTheme = false
        
    }

    private func setupToolPicker() {
        toolPicker.setVisible(true, forFirstResponder: canvasView)
        toolPicker.addObserver(canvasView)
        canvasView.becomeFirstResponder()
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
            addNewPage(isEmpty: true)
        }
        
        for pageData in pageDatas {
            bookPages.append(BookCanvasView(index: Int(pageData.page), isEmpty: false))
        }
    }
    
    private func addNewPage(isEmpty: Bool = false) {
        let newPage = DrawingPage(context: viewContext)
        newPage.data = PKCanvasView().drawing.dataRepresentation()
        newPage.createdAt = Date()
        newPage.cover = cover
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
        if let pageData = pageDatas[currentPageIndex].data,
           let drawing = try? PKDrawing(data: pageData) {
            canvasView.drawing = drawing
        }
    }

    private func saveCurrentPage() {
        pageDatas[currentPageIndex].data = canvasView.drawing.dataRepresentation()
        pageDatas[currentPageIndex].createdAt = Date() // 更新最后编辑日期
        
        print("saveCurrentPage")
        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }

    private func clearCurrentPage() {
        canvasView.drawing = PKDrawing()
        saveCurrentPage()
    }

    private func loadSelectedBackground() {
        if let background = BackgroundType(rawValue: cover.selectedBackground ?? "") {
            selectedBackground = background
            print("selectedBackground 加载 >>> \(selectedBackground)")
        }
    }

    private func saveBackground() {
        cover.selectedBackground = selectedBackground.rawValue
        print("selectedBackground 保存 >>> \(selectedBackground)")
        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }

    private func updateBackground() {
        // 更新画板背景
        // 背景逻辑在 CanvasView 中实现
        
    }
}

struct CanvasView: UIViewRepresentable {
    @Binding var canvasView: PKCanvasView
    var toolPicker: PKToolPicker
    var onDrawingChange: () -> Void
    var background: BackgroundType
    var canUseHand: Bool
    @Environment(\.colorScheme) var colorScheme

    func makeUIView(context: Context) -> PKCanvasView {
        // 根据设备类型设置 drawingPolicy
//        if canUseHand {
//            canvasView.drawingPolicy = .anyInput // iPhone 允许任何输入
//        } else {
            canvasView.drawingPolicy = .pencilOnly // iPad 仅允许 Apple Pencil
//        }
        toolPicker.addObserver(canvasView)
//        toolPicker.setVisible(true, forFirstResponder: canvasView)
        canvasView.becomeFirstResponder()
        canvasView.delegate = context.coordinator
        updateBackground(uiView: canvasView)
        return canvasView
    }

    func updateUIView(_ uiView: PKCanvasView, context: Context) {
//        updateBackground(uiView: uiView)
        print("updateUIView >>> \(background)")
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(onDrawingChange: onDrawingChange)
    }

    private func updateBackground(uiView: PKCanvasView) {
        // 获取当前 colorScheme
        let currentColorScheme = colorScheme
        // 生成背景图片
        let backgroundImage = background.image(for: uiView.bounds.size, colorScheme: currentColorScheme)
        uiView.backgroundColor = UIColor(patternImage: backgroundImage)
        print("生成背景图片 updateBackground >>> \(background)")
    }

    class Coordinator: NSObject, PKCanvasViewDelegate {
        var onDrawingChange: () -> Void

        init(onDrawingChange: @escaping () -> Void) {
            self.onDrawingChange = onDrawingChange
            print("onDrawingChange >>> \(background)")
        }

        func canvasViewDrawingDidChange(_ canvasView: PKCanvasView) {
            onDrawingChange()
        }
    }
}


struct BookCanvasView {
//    var canvaPage: DrawingPage
    var index: Int
    var isEmpty: Bool
}

struct BookPageView: View {
    @ObservedObject var cover: Cover
    @State var currentPageIndex: Int
    @State private var index: Int = 0
    @State private var canvasView = PKCanvasView()
    @State private var toolPicker = PKToolPicker()
    @State private var selectedBackground: BackgroundType = .blank
    @State private var drawingPages: [DrawingPage] = []
    @State var bookPages:[BookCanvasView]
    var canUseHand: Bool
    var saveCurrentPage: () -> Void
    var body: some View {
        ModelPages(
            bookPages,
            currentPage: $index,
//            navigationOrientation: .horizontal,
//            currentPage: currentPageIndex,
            transitionStyle: .pageCurl
//            bounce: true
//            wrap: true
//            controlAlignment: .topLeading
        ) { i, page in
            GeometryReader { geometry in
                CanvasView(
                    canvasView: $canvasView,
                    toolPicker: toolPicker,
                    onDrawingChange: saveCurrentPage,
                    background: selectedBackground,
                    canUseHand: canUseHand
                )
//                Text("Book Page >>>> \(i) -> \(page)").font(.title)
                
            }
            .background(Color.white)
        }
    }
}
