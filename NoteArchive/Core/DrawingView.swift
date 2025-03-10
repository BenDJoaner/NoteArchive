import SwiftUI
import PencilKit
import CoreData

struct DrawingView: View {
    @ObservedObject var cover: Cover
    @Environment(\.managedObjectContext) private var viewContext
    @State private var canvasView = PKCanvasView()
    @State private var pages: [DrawingPage] = []
    @State private var currentPageIndex = 0
    @State private var toolPicker = PKToolPicker()
    @State private var selectedBackground: BackgroundType = .blank // 当前背景类型
    @State private var isSwiping = false
    @State private var swipeDirection: SwipeDirection = .none

    enum SwipeDirection {
        case left
        case right
        case none
    }

    var body: some View {
        ZStack {
            Color.gray.opacity(0.2) // 灰色背景
                .edgesIgnoringSafeArea(.all)

            VStack {
                // 顶部栏
                HStack {
                    Text("当前页：\(currentPageIndex + 1)/\(pages.count)")
                        .font(.headline)
                    Spacer()
                    // 清空按钮
                    Button(action: {
                        clearCurrentPage()
                    }) {
                        HStack {
                        Image(systemName: "trash")
                            Text("清空板块")
                        }
                            .font(.headline)
                    }
                    // 选择背景按钮
                    Menu {
                        ForEach(BackgroundType.allCases, id: \.self) { background in
                            Button(action: {
                                selectedBackground = background
                                cover.selectedBackground = background.rawValue
                                updateBackground()
                                saveBackground()
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
                    }
                }
                .padding(.horizontal)

                // 画板区域
                ZStack {
                    ForEach(0..<pages.count, id: \.self) { index in
                        if index == currentPageIndex {
                CanvasView(canvasView: $canvasView, toolPicker: toolPicker, onDrawingChange: saveCurrentPage, background: selectedBackground)
                    .padding(5)
                                .transition(.asymmetric(
                                    insertion: .move(edge: swipeDirection == .left ? .trailing : .leading),
                                    removal: .move(edge: swipeDirection == .left ? .leading : .trailing)
                                ))
                                .animation(.easeInOut(duration: 0.3), value: currentPageIndex)
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
            }
        }
        .navigationBarTitle(cover.title ?? "空", displayMode: .inline)
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
        if currentPageIndex < pages.count - 1 {
            swipeDirection = .left
            currentPageIndex += 1
        } else {
            addNewPage()
            swipeDirection = .left
            currentPageIndex += 1
        }
        loadCanvasData()
    }

    private func previousPage() {
        saveCurrentPage()
        if currentPageIndex > 0 {
            swipeDirection = .right
            currentPageIndex -= 1
        }
        loadCanvasData()
    }

    private func showToolPicker() {
        toolPicker.setVisible(true, forFirstResponder: canvasView)
        canvasView.becomeFirstResponder()
    }

    private func hideToolPicker() {
        toolPicker.setVisible(false, forFirstResponder: canvasView)
        canvasView.resignFirstResponder()
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
                pages = drawingPages.sorted { $0.page < $1.page }
                loadCanvasData()
            }
        } else {
            addNewPage()
        }
    }

    private func addNewPage() {
        let newPage = DrawingPage(context: viewContext)
        newPage.data = PKCanvasView().drawing.dataRepresentation()
        newPage.createdAt = Date()
        newPage.cover = cover
        newPage.page = Int32(pages.count + 1)
        pages.append(newPage)
        
        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }

    private func loadCanvasData() {
        if let pageData = pages[currentPageIndex].data,
           let drawing = try? PKDrawing(data: pageData) {
            canvasView.drawing = drawing
        }
    }

    private func saveCurrentPage() {
        pages[currentPageIndex].data = canvasView.drawing.dataRepresentation()
        pages[currentPageIndex].createdAt = Date() // 更新最后编辑日期
        
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
        canvasView.drawingPolicy = .pencilOnly // Only allow Apple Pencil
        toolPicker.addObserver(canvasView)
        toolPicker.setVisible(true, forFirstResponder: canvasView)
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
            }
        }
    }
}
