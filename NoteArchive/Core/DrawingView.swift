import SwiftUI
import Vision
import PencilKit
import CoreData


struct DrawingView: View {
    @ObservedObject var cover: Cover
    @Environment(\.managedObjectContext) private var viewContext
    @State private var currentCanvasView = PKCanvasView()
    @State private var pageDatas: [DrawingPage] = []
    @State private var currentPageIndex = 0
    @State private var selectedBackground: BackgroundType = .blank // 当前背景类型
    @State private var bookPages: [BookCanvasView] = []
    @State private var useAI: Bool = false
    @State private var usePencil: Bool = true
    @State private var changeTheme: Bool = false
    @State private var stickImage: UIImage = UIImage()
//    @Environment(\.colorScheme) private var scheme: ColorScheme
//    @AppStorage("userScheme") private var userTheme: Theme = .systemDefault
    
    var namespace: Namespace.ID // 接收命名空间
    

    var body: some View {
        ZStack {
            Color.gray.opacity(0.2) // 灰色背景
                .edgesIgnoringSafeArea(.all)

            if !pageDatas.isEmpty { // 确保 pageDatas 被赋值后才渲染 BookPageView
                BookPageView(
                    cover: cover,
                    currentPageIndex: currentPageIndex,
                    currentCanvasView: $currentCanvasView,
                    selectedBackground: selectedBackground,
                    bookPages: bookPages ,
                    pageDatas: pageDatas,
                    saveCurrentPage: saveCurrentPage,
                    addNewPage:addNewPage
                )
            }
        }
        .navigationBarTitle("\(cover.title ?? "空")(\(currentPageIndex + 1)/\(pageDatas.count))", displayMode: .inline)
        .onAppear {
            loadPages()
            loadCanvasData()
//            loadSelectedBackground() // 加载背景类型
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
        }
        .sheet(isPresented: $changeTheme, content: {
            ButtonBarView(
                onClear: clearCurrentPage,
                onAddPhoto: loadImage,
                onAddPDF: loadPDF,
                onBackgroundChange: { background in
                    selectedBackground = background
                    cover.selectedBackground = background.rawValue
                    updateBackground()
                    saveBackground()
                },
                selectedBackground: $selectedBackground,
                isAIOn: $useAI,
                usePencil: $usePencil,
                currentCanvasView: currentCanvasView
                
                )
                .presentationDetents([.height(650)])
                .presentationBackground(.clear)
        })
    }
    


    private func showToolPicker() {
        changeTheme = true
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
        for pageData in pageDatas {
            bookPages.append(BookCanvasView(pageData: pageData, index: Int(pageData.page)))
        }
    }

    private func saveCurrentPage() {
        pageDatas[currentPageIndex].data = currentCanvasView.drawing.dataRepresentation()
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
        currentCanvasView.drawing = PKDrawing()
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
    
    private func loadImage(selectImage: UIImage){
        stickImage = selectImage
    }
    
    private func loadPDF(){
        
    }

    private func updateBackground() {
        // 更新画板背景
        // 背景逻辑在 CanvasView 中实现
        
    }
}
