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
    var namespace: Namespace.ID // 接收命名空间
    
    enum SwipeDirection {
        case left
        case right
        case none
    }

    var body: some View {
        ZStack {
            Color.gray.opacity(0.5) // 灰色背景
                .edgesIgnoringSafeArea(.all)
            
            // 画板区域
//            ZStack {
//                ForEach(0..<pages.count, id: \.self) { index in
//                    if index == currentPageIndex {
//                        CanvasView(canvasView: $canvasView, toolPicker: toolPicker, onDrawingChange: saveCurrentPage, background: selectedBackground)
////                            .matchedGeometryEffect(id: cover.id, in: namespace) // 添加 matchedGeometryEffect
//                            .cornerRadius(20) // 画板圆角
//                            .shadow(radius: 5) // 添加阴影
//                        }
//                }
//
//                            
//                // 按钮区域
//                VStack {
//                    ButtonBarView(
//                        onClear: clearCurrentPage,
//                        onBackgroundChange: { background in
//                            selectedBackground = background
//                            cover.selectedBackground = background.rawValue
//                            updateBackground()
//                            saveBackground()
//                        },
//                        selectedBackground: $selectedBackground
//                    )
//                    Spacer()
//                }
//                .padding(.top)
//            }
//            .gesture(
//                DragGesture()
//                .onEnded { gesture in
//                    if gesture.translation.width > 50 {
//                        previousPage()
//                    } else if gesture.translation.width < -50 {
//                        nextPage()
//                    } else if gesture.translation.height < -50 {
//                        showToolPicker()
//                    } else if gesture.translation.height > 50 {
//                        hideToolPicker()
//                    }
//                }
//            )
//            .padding(10)
            if !pageDatas.isEmpty { // 确保 pageDatas 被赋值后才渲染 BookPageView
                BookPageView(cover: cover, bookPages: bookPages, saveCurrentPage: saveCurrentPage)
            }
        }
        .navigationBarTitle("\(cover.title ?? "空")(\(currentPageIndex + 1)/\(pageDatas.count))", displayMode: .inline)
        .onAppear {
            setupToolPicker()
            loadPages()
            loadSelectedBackground() // 加载背景类型
        }
        .onDisappear {
            saveCurrentPage()
        }
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
        if UIDevice.current.userInterfaceIdiom == .pad {
            toolPicker.setVisible(true, forFirstResponder: canvasView)
            canvasView.becomeFirstResponder()
        }
    }

    private func hideToolPicker() {
        if UIDevice.current.userInterfaceIdiom == .pad {
            toolPicker.setVisible(false, forFirstResponder: canvasView)
            canvasView.resignFirstResponder()
        }
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
                loadCanvasData()
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
        print("生成背景loadCanvasData")
    }

    private func saveCurrentPage() {
        pageDatas[currentPageIndex].data = canvasView.drawing.dataRepresentation()
        pageDatas[currentPageIndex].createdAt = Date() // 更新最后编辑日期
        print("生成背景saveCurrentPage")
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
    @Environment(\.colorScheme) var colorScheme

    func makeUIView(context: Context) -> PKCanvasView {
        // 根据设备类型设置 drawingPolicy
        if UIDevice.current.userInterfaceIdiom == .phone {
            canvasView.drawingPolicy = .anyInput // iPhone 允许任何输入
            toolPicker.setVisible(false, forFirstResponder: canvasView)
        } else {
            canvasView.drawingPolicy = .pencilOnly // iPad 仅允许 Apple Pencil
            toolPicker.addObserver(canvasView)
            toolPicker.setVisible(true, forFirstResponder: canvasView)
        }

        canvasView.becomeFirstResponder()
        canvasView.delegate = context.coordinator
        updateBackground(uiView: canvasView)
        return canvasView
    }

    func updateUIView(_ uiView: PKCanvasView, context: Context) {
        updateBackground(uiView: uiView)
        
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
        print("生成背景样式")
    }

    class Coordinator: NSObject, PKCanvasViewDelegate {
        var onDrawingChange: () -> Void

        init(onDrawingChange: @escaping () -> Void) {
            self.onDrawingChange = onDrawingChange
        }

        func canvasViewDrawingDidChange(_ canvasView: PKCanvasView) {
            onDrawingChange()
        }
    }
}

struct ButtonBarView: View {
    var onClear: () -> Void // 清空按钮的回调
    var onBackgroundChange: (BackgroundType) -> Void // 背景选择按钮的回调
    @Binding var selectedBackground: BackgroundType // 当前选中的背景类型

    var body: some View {
        HStack {
            Spacer()
            
            // 清空按钮
            Button(action: onClear) {
                HStack {
                    Image(systemName: "trash")
                    Text("清空板块")
                }
                .font(.headline)
                .padding(8)
                .background(Color.gray.opacity(0.7))
                .foregroundColor(.white)
                .cornerRadius(10)
            }
            
            // 选择背景按钮
            Menu {
                ForEach(BackgroundType.allCases, id: \.self) { background in
                    Button(action: {
                        onBackgroundChange(background)
                    }) {
                        HStack {
                            Text(background.rawValue)
                            if selectedBackground == background {
                                Image(systemName: "checkmark")
                            }
                        }
                    }
                }
            } label: {
                HStack {
                    Image(systemName: "paintbrush")
                    Text("背景样式")
                }
                .font(.headline)
                .padding(8)
                .background(Color.gray.opacity(0.7))
                .foregroundColor(.white)
                .cornerRadius(10)
            }
        }
        .padding(.horizontal)
    }
}


struct BookCanvasView {
//    var canvaPage: DrawingPage
    var index: Int
    var isEmpty: Bool
}

struct BookPageView: View {
    @ObservedObject var cover: Cover
    @State private var index: Int = 0
    @State private var canvasView = PKCanvasView()
    @State private var toolPicker = PKToolPicker()
    @State private var selectedBackground: BackgroundType = .blank
    @State private var drawingPages: [DrawingPage] = []
    @State var bookPages:[BookCanvasView]
    var saveCurrentPage: () -> Void
    var body: some View {
        ModelPages(
            bookPages,
            currentPage: $index,
            navigationOrientation: .horizontal,
            transitionStyle: .pageCurl,
            bounce: false,
            wrap: true,
            controlAlignment: .topLeading
        ) { i, page in
            GeometryReader { geometry in
//                CanvasView(canvasView: $canvasView, toolPicker: toolPicker, onDrawingChange: saveCurrentPage, background: selectedBackground)
                Text("Book Page >>>> \(i) -> \(page) \n hhaosdhoaishjdoajsoi jaoisjdaiosjdaisjda\nhaiosjdoiajsiodasjdaosjdoajsodijaisodjaosjdiasjodaihsdoansdihaosdajsdioajsdiojaosidjaonsobnwoadasdadasdasdasdasdasdadasadasd\n asdasd asdawd awd asd asd \n asda sdwd asd asda sda sd asdawf \nawdawf asfafawdqweadsd asdasdasdasd asda \n asdawdasdasdfawdawdasdasdagsfgasdas \n asdawqweqwr asdasdasdasd ").font(.title)
            }
            .background(Color.white)
        }
    }
}

struct SheetView: View {
    var body: some View {
        Text("这是一个Sheet视图")
            .padding()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.white)
    }
}

enum BackgroundType: String, CaseIterable {
    case blank = "Blank"
    case horizontalLines = "Horizontal Lines"
    case grid = "Grid"
    case dots = "Dots" // 新增点阵背景

    func image(for size: CGSize, colorScheme: ColorScheme) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { context in
            // 背景颜色为白色（浅色主题）或黑色（深色主题）
            let backgroundColor = colorScheme == .light ? UIColor.white : UIColor.black
            backgroundColor.setFill()
            context.fill(CGRect(origin: .zero, size: size))

            // 线条和点的颜色为灰色（浅色主题）或浅灰色（深色主题）
            let lineColor = colorScheme == .light ? UIColor.lightGray : UIColor.lightGray.withAlphaComponent(0.5)
            switch self {
            case .blank:
                lineColor.setStroke()
                let path = UIBezierPath()
                let spacing: CGFloat = 45
                let offset: CGFloat = 5
                var y = offset
                while y < size.height {
                    path.move(to: CGPoint(x: offset, y: y))
                    path.addLine(to: CGPoint(x: size.width - offset, y: y))
                    y += spacing
                }
                path.stroke()
                print("case .blank")
            case .horizontalLines:
                lineColor.setStroke()
                let path = UIBezierPath()
                let spacing: CGFloat = 45
                let offset: CGFloat = 5
                var y = offset
                while y < size.height {
                    path.move(to: CGPoint(x: offset, y: y))
                    path.addLine(to: CGPoint(x: size.width - offset, y: y))
                    y += spacing
                }
                path.stroke()
                print("case .horizontalLines")
            case .grid:
                lineColor.setStroke()
                let path = UIBezierPath()
                let spacing: CGFloat = 45
                let offset: CGFloat = 5
                var x = offset
                while x < size.width {
                    path.move(to: CGPoint(x: x, y: offset))
                    path.addLine(to: CGPoint(x: x, y: size.height - offset))
                    x += spacing
                }
                var y = offset
                while y < size.height {
                    path.move(to: CGPoint(x: offset, y: y))
                    path.addLine(to: CGPoint(x: size.width - offset, y: y))
                    y += spacing
                }
                path.stroke()
                print("case .grid")
            case .dots:
                lineColor.setFill()
                let spacing: CGFloat = 50
                let radius: CGFloat = 2
                var x = spacing / 2
                while x < size.width {
                    var y = spacing / 2
                    while y < size.height {
                        let dotRect = CGRect(x: x - radius, y: y - radius, width: radius * 2, height: radius * 2)
                        let dotPath = UIBezierPath(ovalIn: dotRect)
                        dotPath.fill()
                        y += spacing
                    }
                    x += spacing
                }
                print("case .dots")
            }
        }
    }
}

