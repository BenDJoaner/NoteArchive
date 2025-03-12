//
//  FolderView.swift
//  NoteArchive
//
//  Created by 梁骐显 on 2025/3/8.
//
import SwiftUI
import CoreData
import PencilKit

struct FolderView: View {
    enum FolderState {
        case e_normal // 默认状态
        case e_editing // 编辑状态
        case e_trash // 回收站状态
        case e_privacy // 隐私状态
    }

    @ObservedObject var note: Note
    @Environment(\.managedObjectContext) private var viewContext
    @State private var newTitle = ""
    @State private var editingCover: Cover? = nil
    @State private var appConfig: AppConfig? = nil
    @State private var editedTitle = ""
    @State private var editedColor = ""
    @State public var folderState: FolderState = .e_normal // 默认状态
    @State private var isPrivacy = false
    @Namespace private var namespace // 命名空间

    var body: some View {
        GeometryReader { geometry in
            VStack {
                // 标题栏
                TitleBarView(
                    folderState: $folderState,
                    isPrivacy: isPrivacy,
                    newTitle: $newTitle,
                    note: note,
                    saveTitle: saveTitle
                )

                // 封面网格
                ScrollView(.horizontal, showsIndicators: false) {
                    LazyHGrid(rows: [GridItem(.adaptive(minimum: 290))], spacing: 20) {
                        ForEach(note.coversArray.sorted { $0.createdAt ?? Date() < $1.createdAt ?? Date() }, id: \.self) { cover in

                            if folderState == .e_editing {
                                CoverEditView(cover: cover, deleteAction: {
                                    moveToTrash(cover: cover)
//                                }, editAction: {
//                                    editingCover = cover
                                })
                                .frame(width: 180, height: 280)
                            } else if folderState == .e_trash {
                                TrashCoverView(cover: cover, restoreAction: {
                                    restoreCover(cover: cover)
                                }, deleteAction: {
                                    deleteCover(cover: cover)
                                })
                                .frame(width: 180, height: 280)
                            } else {
                                // 在 `FolderView` 中添加 `matchedGeometryEffect`
                                NavigationLink(destination: DrawingView(cover: cover, namespace: namespace)) {
                                    CoverView(cover: cover, isPrivacy: isPrivacy, onLongPress: {
                                        folderState = .e_editing // 长按时进入编辑模式
                                    })
//                                    .matchedGeometryEffect(id: cover.id, in: namespace) // 添加 matchedGeometryEffect
                                    .frame(width: 180, height: 280)
                                }
//                                .transition(.scale(scale: 1.5).combined(with: .opacity)) // 添加过渡动画
//                                .zIndex(1) // 确保封面视图在过渡时位于最上层
                            }
                        }
                        if folderState == .e_normal || folderState == .e_privacy {
                            AddCoverButton {
                                addCover()
                            }
                            .frame(width: 180, height: 280)
                        }
                    }
                    .padding()
                }
            }
        }
        .onAppear {
            newTitle = note.title ?? ""
            isPrivacy = folderState == .e_privacy
        }
//        .sheet(item: $editingCover) { cover in
//            EditCoverSheet(cover: cover, editedTitle: $editedTitle, editedColor: $editedColor, onSave: {
//                saveCoverChanges(cover: cover)
//            }, onCancel: {
//                editingCover = nil
//            })
//            .background(BackgroundCleanerView())
//        }
        
    }

    private func titleForState() -> String {
        switch folderState {
        case .e_normal:
            return note.title ?? "空"
        case .e_editing:
            if isPrivacy {
                return "隐私"
            }else{
                return "编辑中"
            }
            
        case .e_trash:
            return "回收站"
        case .e_privacy:
            return "隐私"
        }
    }
    
    private func restoreCover(cover: Cover) {
        withAnimation {
            let fetchRequest: NSFetchRequest<Note> = Note.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "title == %@", "已还原")
            if let restoredNote = try? viewContext.fetch(fetchRequest).first {
                restoredNote.addToCovers(cover)
            } else {
                let newRestoredNote = Note(context: viewContext)
                newRestoredNote.id = UUID()
                newRestoredNote.title = "已还原"
                newRestoredNote.isPinned = false
                newRestoredNote.addToCovers(cover)
            }
            note.removeFromCovers(cover)
            do {
                try viewContext.save()
            } catch {
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
    
    private func addCover() {
        withAnimation {
            let newCover = Cover(context: viewContext)
            newCover.id = UUID()
            newCover.title = "新档案\(note.coversArray.count+1)"
            newCover.createdAt = Date()
            newCover.color = folderState == .e_privacy ? "#555555" : randomColor() // 隐私状态下为黑色
            note.addToCovers(newCover)
            
            do {
                try viewContext.save()
            } catch {
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }

    
    private func moveToTrash(cover: Cover) {
        withAnimation {
            if let drawingPages = cover.drawingPages, drawingPages.count > 0{
                appConfig?.trashNote?.addToCovers(cover)
            }

            deleteCover(cover: cover)
            do {
                try viewContext.save()
            } catch {
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
    
    private func deleteCover(cover: Cover) {
        withAnimation {
            if let drawingPages = cover.drawingPages?.allObjects as? [DrawingPage] {
                for page in drawingPages {
                    viewContext.delete(page)
                }
            }
            viewContext.delete(cover)
            
            do {
                try viewContext.save()
            } catch {
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }

    private func saveTitle() {
        withAnimation {
            note.title = newTitle
            
            do {
                try viewContext.save()
            } catch {
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }

    private func saveCoverChanges(cover: Cover) {
        withAnimation {
            cover.title = editedTitle
            cover.color = editedColor
            
            do {
                try viewContext.save()
            } catch {
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
            editingCover = nil
        }
    }

    private func randomColor() -> String {
        let colors = ["#EB8496", "#BCBAD2", "#F46537", "#7B618B", "#556DEA", "#10C378", "#A4B5D5", "#FFDBCC"]
        return colors.randomElement() ?? "#FF5733"
    }
}

// 封面视图
struct CoverView: View {
    var cover: Cover
    var isPrivacy: Bool
    var onLongPress: () -> Void // 添加长按回调

    var body: some View {
        ZStack {
            // 背景颜色
            Color(hex: cover.color ?? "#FF5733")
                .cornerRadius(10)

            if isPrivacy {
                // 图片
                Image("jimi") // 使用图片名称
                    .frame(width: 100, height: 100) // 设置图片大小
                    .offset(x: 50, y: -80)
                    .opacity(0.5) // 设置透明度为 50%
            }

            
            // 标题文本
            VStack {
                Text(cover.title ?? "Untitled")
                    .font(.headline)
                    .foregroundColor(.white)
                    .shadow(color: .black, radius: 2, x: 1, y: 1)
                    .padding(10)
                Spacer()
            }

            // 第一个 page 的缩小版本内容（如果存在）
            if let drawingPages = cover.drawingPages,
               drawingPages.count > 0, // 使用 count 判断是否为空
               let firstPage = drawingPages.allObjects[0] as? DrawingPage,
               let pageData = firstPage.data,
               let drawing = try? PKDrawing(data: pageData) {
                let image = drawing.image(from: drawing.bounds, scale: 0.5) // 缩小版本
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding(20)
            }

            // 左下角显示创建时间
            VStack {
                Spacer()
                HStack {
                    if let date = cover.createdAt {
                        Text(formatDate(date))
                            .font(.caption)
                            .foregroundColor(.white)
                            .shadow(color: .black, radius: 2, x: 1, y: 1)
                            .padding(10)
                    }
                    Spacer()
                    Text("\(cover.drawingPages?.count ?? 0)页")
                        .font(.caption)
                        .foregroundColor(.white)
                        .shadow(color: .black, radius: 2, x: 1, y:1)
                        .padding(10)
                }
            }
        }
        .cornerRadius(10)
        .shadow(radius: 5)
        .onLongPressGesture {
            onLongPress() // 触发长按回调
        }
    }

    // 格式化日期
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }
}

// 封面编辑视图
struct CoverEditView: View {
    @ObservedObject var cover: Cover
    var deleteAction: () -> Void
    @State private var editedTitle: String = ""
    @State private var showColorPicker: Bool = false
    @State private var showMoveMenu: Bool = false
    @State private var isPrivacy: Bool = false
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        entity: Note.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \Note.createdAt, ascending: true)]
    ) var notes: FetchedResults<Note>

    @FetchRequest(
        entity: AppConfig.entity(),
        sortDescriptors: []
    ) var appConfigs: FetchedResults<AppConfig>

    var body: some View {
        VStack {
            // 顶部标题文本框
            TextField("输入标题", text: $editedTitle)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal)
                .padding(.top, 10)
                .onAppear {
                    editedTitle = cover.title ?? ""
                }
                .onChange(of: editedTitle) { newValue in
                    cover.title = newValue
                    saveChanges()
                }

            Spacer()

            // 按钮区域（2x2 网格布局）
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 20) {
                // 颜色按钮
                VStack {
                    ZStack {
                        // 黑色背景
                        Color.gray
                            .frame(width: 50, height: 50) // 设置背景大小为 50x50
                            .cornerRadius(10) // 设置背景的圆角为 10

                        // ColorPicker
                        ColorPicker("选择颜色", selection: Binding(
                            get: { Color(hex: cover.color ?? "#FF5733") },
                            set: { newColor in
                                cover.color = newColor.toHex()
                                saveChanges()
                            })
                        )
                        .labelsHidden() // 隐藏标签，使 ColorPicker 更紧凑
                        .frame(width: 30, height: 30) // 设置 ColorPicker 的大小

                    }
                    .frame(width: 50, height: 50) // 确保 ZStack 的大小与背景一致
                    Text("颜色")
                        .font(.caption)
                        .foregroundColor(.white)
                        .shadow(color: .black, radius: 1, x: 1, y: 1) // 添加阴影
                }


                // 隐藏按钮（移动到隐私 Note）
                Button(action: {
                    moveCoverToPrivacy()
                }) {
                    if !isPrivacy {
                        VStack {
                            ZStack {
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(Color.gray) // 灰色背景
                                    .frame(width: 50, height: 50)
                                Image(systemName: "eye.slash.fill")
                                    .font(.title)
                                    .foregroundColor(.white)
                            }
                            Text("隐藏")
                                .font(.caption)
                                .foregroundColor(.white)
                                .shadow(color: .black, radius: 1, x: 1, y: 1) // 添加阴影
                        }
                    }
                }

                // 删除按钮（移动到回收站 Note）
                Button(action: {
                    moveCoverToTrash()
                }) {
                    VStack {
                        ZStack {
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color.gray) // 红色背景
                                .frame(width: 50, height: 50)
                            Image(systemName: "trash.fill")
                                .font(.title)
                                .foregroundColor(.white)
                        }
                        Text("删除")
                            .font(.caption)
                            .foregroundColor(.white)
                            .shadow(color: .black, radius: 1, x: 1, y: 1) // 添加阴影
                    }
                }

                // 移动按钮
                Button(action: {
                    showMoveMenu.toggle()
                }) {
                    VStack {
                        ZStack {
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color.gray) // 蓝色背景
                                .frame(width: 50, height: 50)
                            Image(systemName: "arrow.right.circle.fill")
                                .font(.title)
                                .foregroundColor(.white)
                        }
                        Text("移动")
                            .font(.caption)
                            .foregroundColor(.white)
                            .shadow(color: .black, radius: 1, x: 1, y: 1) // 添加阴影
                    }
                }
                .actionSheet(isPresented: $showMoveMenu) {
                    ActionSheet(
                        title: Text("移动到"),
                        buttons: notes.filter { $0.title != "隐私" && $0.title != "回收站" }.map { note in
                            .default(Text(note.title ?? "未命名")) {
                                moveCover(to: note)
                            }
                        } + [.cancel()]
                    )
                }
            }
            .padding(.horizontal)
            .padding(.bottom, 20)
        }
        .background(Color(hex: cover.color ?? "#FF5733"))
        .cornerRadius(10)
        .shadow(radius: 5)
    }

    // 保存更改
    private func saveChanges() {
        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }

    // 移动 Cover 到指定的 Note
    private func moveCover(to note: Note) {
        withAnimation {
            cover.note?.removeFromCovers(cover)
            note.addToCovers(cover)
            saveChanges()
        }
    }

    // 移动 Cover 到隐私 Note
    private func moveCoverToPrivacy() {
        if let privacyNote = appConfigs.first?.privacyNote {
            moveCover(to: privacyNote)
        }
    }

    // 移动 Cover 到回收站 Note
    private func moveCoverToTrash() {
//        if let trashNote = appConfigs.first?.trashNote {
//            if cover.drawingPages!.count > 0 {
//                moveCover(to: trashNote)
//            }else{
//                cover.note?.removeFromCovers(cover)
//            }
//            
//        }
        withAnimation {
            if let trashNote = appConfigs.first?.trashNote {
                if cover.drawingPages!.count > 0 {
                    cover.note?.removeFromCovers(cover)
                    trashNote.addToCovers(cover)
                } else {
                    cover.note?.removeFromCovers(cover)
                }
            }
            
            do {
                try viewContext.save()
            } catch {
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
}

// 添加封面按钮
struct AddCoverButton: View {
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.gray.opacity(0.3))
                Image(systemName: "plus.circle.fill")
                    .font(.largeTitle)
                    .foregroundColor(.blue)
            }
        }
    }
}

struct TrashCoverView: View {
    @ObservedObject var cover: Cover
    var restoreAction: () -> Void
    var deleteAction: () -> Void
    @State private var showDeleteConfirmation = false
    
    var body: some View {
        ZStack {
            // 背景颜色
            Color(hex: cover.color ?? "#FF5733")
                .cornerRadius(10)
                .opacity(0.5)

            // 图片
            Image("xiaohui") // 使用图片名称
                .resizable() // 使图片可调整大小
                .scaledToFit() // 保持图片比例
                .frame(width: 180, height: 180) // 设置图片大小
                .offset(x: -50, y: 80)
                .shadow(radius: 1,x:2,y:2)
                .opacity(0.8) // 设置透明度为 50%
            // 标题文本
            VStack {
                Text(cover.title ?? "Untitled")
                    .font(.headline)
                    .foregroundColor(.white)
                    .shadow(color: .black, radius: 2, x: 1, y: 1)
                    .padding(10)
                Spacer()
            }

            // 右下角显示页数
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Text("\(cover.drawingPages?.count ?? 0) Pages")
                        .font(.caption)
                        .foregroundColor(.white)
                        .shadow(color: .black, radius: 2, x: 1, y: 1)
                        .padding(10)
                }
            }

            // 还原和彻底删除按钮
            VStack(spacing: 10) {
                Button(action: restoreAction) {
                    HStack {
                        Image(systemName: "arrow.uturn.backward")
                        Text("还原")
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.green)
                    .cornerRadius(10)
                    .shadow(radius: 5)
                }

                Button(action: {
                    showDeleteConfirmation = true
                }) {
                    HStack {
                        Image(systemName: "trash")
                        Text("销毁")
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.red)
                    .cornerRadius(10)
                    .shadow(radius: 5)
                }
                .alert(isPresented: $showDeleteConfirmation) {
                    Alert(
                        title: Text("销毁"),
                        message: Text("确定销毁该档案吗？销毁后将无法还原。"),
                        primaryButton: .destructive(Text("销毁"), action: deleteAction),
                        secondaryButton: .cancel()
                    )
                }
            }
            .padding(20)
        }
        .cornerRadius(10)
        .shadow(radius: 5)
    }
}

struct TitleBarView: View {
    @Binding var folderState: FolderView.FolderState
    var isPrivacy: Bool
    @Binding var newTitle: String
    var note: Note
    var saveTitle: () -> Void

    var body: some View {
        HStack {
            if folderState == .e_editing && !isPrivacy {
                TextField("Enter new title", text: $newTitle)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal)
            } else {
                Text(titleForState())
                    .font(.largeTitle)
                    .bold()
                    .padding(.leading)
            }
            Spacer()
            // 编辑/保存按钮
            if folderState == .e_normal || folderState == .e_privacy {
                Button(action: {
                    folderState = .e_editing
                }) {
                    HStack {
                        Image(systemName: "pencil")
                        Text("编辑")
                    }
                    .font(.headline)
                    .padding(.trailing)
                }
            } else if folderState == .e_editing {
                Button(action: {
                    saveTitle()
                    folderState = .e_normal
                }) {
                    HStack {
                        Image(systemName: "square.and.arrow.down")
                        Text("保存")
                    }
                    .font(.headline)
                    .padding(.trailing)
                }
            }
        }
        .padding(.top)
    }

    private func titleForState() -> String {
        switch folderState {
        case .e_normal:
            return note.title ?? "空"
        case .e_editing:
            return isPrivacy ? "隐私" : "编辑中"
        case .e_trash:
            return "回收站"
        case .e_privacy:
            return "隐私"
        }
    }
}

// 移除弹窗背景
struct BackgroundCleanerView: UIViewRepresentable {
    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        DispatchQueue.main.async {
            view.superview?.superview?.backgroundColor = .clear
        }
        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {}
}

// 扩展 Note 以方便访问 covers
extension Note {
    var coversArray: [Cover] {
        return (covers?.allObjects as? [Cover]) ?? []
    }
}

// 扩展 Color 以支持十六进制颜色
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }

    func toHex() -> String {
        let components = UIColor(self).cgColor.components
        let r = Float(components?[0] ?? 0)
        let g = Float(components?[1] ?? 0)
        let b = Float(components?[2] ?? 0)
        return String(format: "#%02lX%02lX%02lX", lroundf(r * 255), lroundf(g * 255), lroundf(b * 255))
    }
}
