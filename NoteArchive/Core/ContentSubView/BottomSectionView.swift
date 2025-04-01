//
//  BottomSectionView.swift
//  NoteArchive
//
//  Created by 梁骐显 on 2025/3/9.
//

import SwiftUI
import LocalAuthentication
import CoreData
import UniformTypeIdentifiers

struct BottomSectionView: View {
    var privacyNote: Note?
    var trashNote: Note?
    @Binding var selectedNote: Note?
    @ObservedObject var appConfig: AppConfig // 添加 appConfig 参数
    @State private var viewWidth: CGFloat = 300
    
    @State private var showAuthenticationFailedAlert = false
    
    @State private var showFilePicker = false
    @State private var showExportSuccess = false
    @State private var showImportSuccess = false
    @State private var showImportError = false
    @Environment(\.managedObjectContext) private var viewContext
    
    @State private var isSyncingToiCloud = false
    @State private var showSyncSuccess = false
    @State private var showSyncError = false
    
    @State private var showNoteSelection = false
    @State private var selectedNotes = Set<Note>()
    @State private var showDocumentPicker = false
    @State private var tempFileURLs: [URL] = []
    var body: some View {
        VStack(spacing: 2) {
            Image("MyLogo")
                .resizable()
                .frame(width: 60, height: 60)
                .padding(.vertical)
                
            // 导出按钮
            Button(action: {
                showNoteSelection = true
            }) {
                Image(systemName: "tray.and.arrow.down.fill")
                    .font(.title)
                    .foregroundColor(.white)
                    .frame(maxHeight: 80)
            }
            .sheet(isPresented: $showNoteSelection) {
                NoteSelectionView(
                    selectedNotes: $selectedNotes,
                    onConfirm: { // 新增确认回调
                        prepareExport()
                    }
                )
            }
            .sheet(isPresented: $showDocumentPicker) {
                DocumentExportView(fileURLs: tempFileURLs)
            }
            
            // 新增恢复按钮
            Button(action: {
                showFilePicker = true
            }) {
                Image(systemName: "tray.full.fill")
                    .font(.title)
                    .foregroundColor(.white)
                    .frame(maxHeight: 80)
            }
            .fileImporter(
                isPresented: $showFilePicker,
                allowedContentTypes: [.archivebox],
                allowsMultipleSelection: true
            ) { result in
                handleFileImport(result: result)
            }
            // 新增 iCloud 同步按钮
            Button(action: {
                syncToiCloud()
            }) {
                if isSyncingToiCloud {
                    ProgressView()
                        .frame(width: 24, height: 24)
                } else {
                    Image(systemName: "icloud.and.arrow.up.fill")
                        .font(.title)
                        .foregroundColor(.white)
                }
            }
            .frame(maxHeight: 80)
            .disabled(isSyncingToiCloud)
            
            RequestButton(buttonTint: .clear, foregroundColor: .white) {
                try? await Task.sleep(for: .seconds(2))
                return .failed("failed")
            } content: {
                Image(systemName: "arrow.trianglehead.2.clockwise.rotate.90.icloud.fill")
                    .font(.title)
                    .foregroundColor(.white)
            }
            .frame(maxHeight: 80)
            
            Spacer()
            if let privacyNote = privacyNote {
                Button(action: {
                    authenticate { success in
                        if success {
                            selectedNote = privacyNote // 验证成功，设置 selectedNote
                        } else {
                            // 验证失败
                            showAuthenticationFailedAlert = true
                        }
                    }
                }) {
                    Image(systemName: "lock.rectangle.stack.fill")
                    .font(.title)
                    .foregroundColor(.white)
                    .frame(maxHeight: 80)
                }
                .background(
                    // 使用 NavigationLink 控制跳转
                    NavigationLink(
                        destination: FolderView(note: privacyNote, folderState: FolderView.FolderState.e_privacy),
                        tag: privacyNote,
                        selection: $selectedNote,
                        label: { EmptyView() }
                    )
                )
            }

            if let trashNote = trashNote {
                Button(action: {
                    authenticate { success in
                        if success {
                            selectedNote = trashNote // 验证成功，设置 selectedNote
                        } else {
                            // 验证失败
                            showAuthenticationFailedAlert = true
                        }
                    }
                }) {
                    Image(systemName: "trash.fill")
                        .font(.title)
                        .foregroundColor(.red)
                        .frame(maxHeight: 80)
                }
                .background(
                    // 使用 NavigationLink 控制跳转
                    NavigationLink(
                        destination: FolderView(note: trashNote, folderState: FolderView.FolderState.e_trash),
                        tag: trashNote,
                        selection: $selectedNote,
                        label: { EmptyView() }
                    )
                )
            }
            // 替换 Toggle 为纯图片按钮
            Button(action: toggleTheme) {
                Image(systemName: appConfig.themeScheme ? "moon.fill" : "sun.max.fill")
                    .font(.title)
                    .foregroundColor(.white)
                    .frame(maxHeight: 80)
                    .rotationEffect(.degrees(appConfig.themeScheme ? 180 : 0))  // 旋转效果
                    .animation(.easeInOut, value: appConfig.themeScheme)
            }
        }
        .alert("ExportSuccess", isPresented: $showExportSuccess) {
            Button("OK", role: .cancel) { }
        }
        .alert("ImportSuccess", isPresented: $showImportSuccess) {
            Button("OK", role: .cancel) { }
        }
        .alert("ImportError", isPresented: $showImportError) {
            Button("OK", role: .cancel) { }
        }
        .alert("SyncSuccess", isPresented: $showSyncSuccess) {
            Button("OK", role: .cancel) { }
        }
        .alert("SyncError", isPresented: $showSyncError) {
            Button("OK", role: .cancel) { }
        }
    }

    private func authenticate(completion: @escaping (Bool) -> Void) {
        let context = LAContext()
        var error: NSError?

        // 检查设备是否支持生物识别或设备密码
        if context.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error) {
            let reason = "DestructionSite".localized

            // 使用 .deviceOwnerAuthentication 策略
            context.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: reason) { success, authenticationError in
                DispatchQueue.main.async {
                    if success {
                        completion(true)
                    } else {
                        // 验证失败
                        completion(false)
                    }
                }
            }
        } else {
            // 设备不支持任何验证方式
            completion(false)
        }
    }
    private func toggleTheme() {
        appConfig.themeScheme.toggle()  // 切换主题状态
        saveThemeScheme()
        
        // 立即应用主题
        if let window = UIApplication.shared.windows.first {
            window.overrideUserInterfaceStyle = appConfig.themeScheme ? .dark : .light
        }
    }

    private func saveThemeScheme() {
        do {
            try appConfig.managedObjectContext?.save()
        } catch {
            print("Failed to save theme: \(error)")
        }
    }
    
    // 导出单个笔记
    private func prepareExport() {
        tempFileURLs.removeAll()
        
        do {
            for note in selectedNotes {
                let data = try createNoteBackupData(note)
                let fileName = getExportFileName(for: note)
                let tempURL = FileManager.default.temporaryDirectory
                    .appendingPathComponent(fileName)
                try data.write(to: tempURL)
                tempFileURLs.append(tempURL)
            }
            
            showDocumentPicker = true
        } catch {
            print("导出失败: \(error)")
        }
    }
    
    // 创建笔记备份数据
    private func createNoteBackupData(_ note: Note) throws -> Data {
        var backup = [String: Any]()
        backup["version"] = "1.1"
        backup["createdAt"] = Date().timeIntervalSince1970
        
        // 序列化笔记
        var noteData = [String: Any]()
        noteData["id"] = note.id?.uuidString
        noteData["title"] = note.title
        noteData["isPinned"] = note.isPinned
        noteData["createdAt"] = note.createdAt?.timeIntervalSince1970
        noteData["colorStr"] = note.colorStr
        noteData["isShowen"] = note.isShowen
        
        // 序列化关联的封面
        var coversData = [[String: Any]]()
        for cover in note.coversArray {
            var coverData = [String: Any]()
            coverData["id"] = cover.id?.uuidString
            coverData["title"] = cover.title
            coverData["color"] = cover.color
            coverData["createdAt"] = cover.createdAt?.timeIntervalSince1970
            coverData["isAnalyze"] = cover.isAnalyze
            
            // 序列化绘图页面
            var pagesData = [[String: Any]]()
            if let drawingPages = cover.drawingPages?.allObjects as? [DrawingPage] {
                for page in drawingPages {
                    var pageData = [String: Any]()
                    pageData["page"] = page.page
                    pageData["createdAt"] = page.createdAt?.timeIntervalSince1970
                    pageData["textData"] = page.textData
                    if let drawingData = page.data {
                        pageData["drawingData"] = drawingData.base64EncodedString()
                    }
                    pagesData.append(pageData)
                }
            }
            
            coverData["drawingPages"] = pagesData
            coversData.append(coverData)
        }
        
        noteData["covers"] = coversData
        backup["note"] = noteData
        return try JSONSerialization.data(withJSONObject: backup, options: .prettyPrinted)
    }
    
    // 处理文件导入
    private func handleFileImport(result: Result<[URL], Error>) {
        do {
            let urls = try result.get()
            for url in urls {
                try importNote(from: url)
            }
            showImportSuccess = true
        } catch {
            print("Import failed: \(error)")
            showImportError = true
        }
    }
    
    // 从文件导入笔记
    private func importNote(from url: URL) throws {
        let data = try Data(contentsOf: url)
        guard let backup = try JSONSerialization.jsonObject(with: data) as? [String: Any],
              let noteData = backup["note"] as? [String: Any] else {
            throw NSError(domain: "Invalid backup format", code: 0)
        }
        
        // 检查ID是否已存在
        if let noteIDString = noteData["id"] as? String,
           let noteID = UUID(uuidString: noteIDString),
           let existingNote = try? findNoteByID(noteID) {
            
            // 更新现有笔记的标题
            if let title = noteData["title"] as? String {
                let timestamp = Date().timeIntervalSince1970
                existingNote.title = "\(title)_\(Int(timestamp))"
            }
            
            try updateNote(existingNote, with: noteData)
        } else {
            // 创建新笔记
            try createNewNote(with: noteData)
        }
        
        try viewContext.save()
    }
    
    // 根据ID查找笔记
    private func findNoteByID(_ id: UUID?) throws -> Note? {
        guard let id = id else { return nil }
        
        let fetchRequest: NSFetchRequest<Note> = Note.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        let results = try viewContext.fetch(fetchRequest)
        return results.first
    }
    
    // 更新现有笔记
    private func updateNote(_ note: Note, with data: [String: Any]) throws {
        note.title = data["title"] as? String ?? note.title
        note.isPinned = data["isPinned"] as? Bool ?? note.isPinned
        note.colorStr = data["colorStr"] as? String ?? note.colorStr
        
        if let coversData = data["covers"] as? [[String: Any]] {
            for coverData in coversData {
                if let coverID = coverData["id"] as? String,
                   let existingCover = try? findCoverByID(UUID(uuidString: coverID)) {
                    try updateCover(existingCover, with: coverData)
                } else {
                    try createNewCover(for: note, with: coverData)
                }
            }
        }
    }
    
    // 创建新笔记
    private func createNewNote(with data: [String: Any]) throws {
        let newNote = Note(context: viewContext)
        newNote.id = UUID(uuidString: data["id"] as? String ?? "") ?? UUID()
        newNote.title = data["title"] as? String ?? "New Note"
        newNote.isPinned = data["isPinned"] as? Bool ?? false
        newNote.createdAt = Date(timeIntervalSince1970: data["createdAt"] as? TimeInterval ?? Date().timeIntervalSince1970)
        newNote.colorStr = data["colorStr"] as? String
        newNote.isShowen = data["isShowen"] as? Bool ?? true
        
        if let coversData = data["covers"] as? [[String: Any]] {
            for coverData in coversData {
                try createNewCover(for: newNote, with: coverData)
            }
        }
    }
    
    // 根据ID查找封面
    private func findCoverByID(_ id: UUID?) throws -> Cover? {
        guard let id = id else { return nil }
        
        let fetchRequest: NSFetchRequest<Cover> = Cover.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        let results = try viewContext.fetch(fetchRequest)
        return results.first
    }
    
    // 更新现有封面
    private func updateCover(_ cover: Cover, with data: [String: Any]) throws {
        cover.title = data["title"] as? String ?? cover.title
        cover.color = data["color"] as? String ?? cover.color
        cover.isAnalyze = data["isAnalyze"] as? Bool ?? cover.isAnalyze
        
        if let pagesData = data["drawingPages"] as? [[String: Any]] {
            for pageData in pagesData {
                if let pageNumber = pageData["page"] as? Int32,
                   let existingPage = try? findDrawingPage(cover: cover, page: pageNumber) {
                    try updateDrawingPage(existingPage, with: pageData)
                } else {
                    try createNewDrawingPage(for: cover, with: pageData)
                }
            }
        }
    }
    
    // 创建新封面
    private func createNewCover(for note: Note, with data: [String: Any]) throws {
        let newCover = Cover(context: viewContext)
        newCover.id = UUID(uuidString: data["id"] as? String ?? "") ?? UUID()
        newCover.title = data["title"] as? String ?? "New Cover"
        newCover.color = data["color"] as? String ?? "#7D177D"
        newCover.createdAt = Date(timeIntervalSince1970: data["createdAt"] as? TimeInterval ?? Date().timeIntervalSince1970)
        newCover.isAnalyze = data["isAnalyze"] as? Bool ?? false
        newCover.note = note
        
        if let pagesData = data["drawingPages"] as? [[String: Any]] {
            for pageData in pagesData {
                try createNewDrawingPage(for: newCover, with: pageData)
            }
        }
    }
    
    // 查找绘图页面
    private func findDrawingPage(cover: Cover, page: Int32) throws -> DrawingPage? {
        let fetchRequest: NSFetchRequest<DrawingPage> = DrawingPage.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "cover == %@ AND page == %d", cover, page)
        let results = try viewContext.fetch(fetchRequest)
        return results.first
    }
    
    // 更新绘图页面
    private func updateDrawingPage(_ page: DrawingPage, with data: [String: Any]) throws {
        if let drawingDataString = data["drawingData"] as? String,
           let drawingData = Data(base64Encoded: drawingDataString) {
            page.data = drawingData
        }
        page.textData = data["textData"] as? String
    }
    
    // 创建新绘图页面
    private func createNewDrawingPage(for cover: Cover, with data: [String: Any]) throws {
        let newPage = DrawingPage(context: viewContext)
        newPage.page = data["page"] as? Int32 ?? Int32(cover.drawingPages?.count ?? 0) + 1
        newPage.createdAt = Date(timeIntervalSince1970: data["createdAt"] as? TimeInterval ?? Date().timeIntervalSince1970)
        newPage.textData = data["textData"] as? String
        
        if let drawingDataString = data["drawingData"] as? String,
           let drawingData = Data(base64Encoded: drawingDataString) {
            newPage.data = drawingData
        }
        
        newPage.cover = cover
    }
    // 同步到 iCloud
    private func syncToiCloud() {
        // 检查 iCloud 可用性
        guard FileManager.default.ubiquityIdentityToken != nil else {
            showSyncError = true
            return
        }
        
        isSyncingToiCloud = true
        
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                // 1. 获取容器URL
                guard let ubiquityContainerURL = FileManager.default.url(
                    forUbiquityContainerIdentifier: nil
                ) else {
                    throw NSError(domain: "iCloud not available", code: 0)
                }
                
                // 2. 准备要同步的文件
                let localDocumentsURL = FileManager.default.urls(
                    for: .documentDirectory,
                    in: .userDomainMask
                ).first!
                
                let fileURLs = try FileManager.default.contentsOfDirectory(
                    at: localDocumentsURL,
                    includingPropertiesForKeys: [.contentTypeKey]
                ).filter { url in
                    let resourceValues = try? url.resourceValues(forKeys: [.contentTypeKey])
                    return resourceValues?.contentType == .archivebox
                }
                
                // 3. 创建 iCloud 目录
                let iCloudDocumentsURL = ubiquityContainerURL.appendingPathComponent("Documents")
                try FileManager.default.createDirectory(
                    at: iCloudDocumentsURL,
                    withIntermediateDirectories: true,
                    attributes: nil
                )
                
                // 4. 上传文件到 iCloud
                for fileURL in fileURLs {
                    var destinationURL = iCloudDocumentsURL.appendingPathComponent(fileURL.lastPathComponent)
                    
                    // 检查文件是否已存在
                    if FileManager.default.fileExists(atPath: destinationURL.path) {
                        try FileManager.default.removeItem(at: destinationURL)
                    }
                    
                    try FileManager.default.copyItem(at: fileURL, to: destinationURL)
                    
                    // 设置文件不备份到iCloud的元数据
                    var resourceValues = URLResourceValues()
                    resourceValues.isExcludedFromBackup = false
                    try destinationURL.setResourceValues(resourceValues)
                }
                
                // 5. 触发同步
                try FileManager.default.startDownloadingUbiquitousItem(at: iCloudDocumentsURL)
                
                DispatchQueue.main.async {
                    isSyncingToiCloud = false
                    showSyncSuccess = true
                }
            } catch {
                DispatchQueue.main.async {
                    isSyncingToiCloud = false
                    showSyncError = true
                    print("iCloud sync failed: \(error.localizedDescription)")
                }
            }
        }
    }
    
    private func getExportFileName(for note: Note) -> String {
        let baseName = note.title ?? "Untitled"
        let timestamp = Date().timeIntervalSince1970
        
        // 清理文件名中的非法字符
        var validFileName = baseName
            .replacingOccurrences(of: "/", with: "-")
            .replacingOccurrences(of: ":", with: "-")
        
        // 如果ID已存在，添加时间戳
        if let existingFiles = try? FileManager.default.contentsOfDirectory(at: FileManager.default.temporaryDirectory,
                                                                           includingPropertiesForKeys: nil),
           existingFiles.contains(where: { $0.lastPathComponent.contains(note.id?.uuidString ?? "") }) {
            validFileName += "_\(Int(timestamp))"
        }
        
        return "\(validFileName).archivebox"
    }
}

// 扩展 UTType 以支持我们的文件类型
extension UTType {
    static let archivebox = UTType(exportedAs: "com.dapanz.notearchive")
}

// 文件导出视图
struct DocumentExportView: UIViewControllerRepresentable {
    var fileURLs: [URL]
    
    func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
        let controller = UIDocumentPickerViewController(forExporting: fileURLs, asCopy: true)
        controller.delegate = context.coordinator
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIDocumentPickerDelegate {
        var parent: DocumentExportView
        
        init(_ parent: DocumentExportView) {
            self.parent = parent
        }
        
        func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
            // 文件保存成功后的处理
            print("文件已保存到: \(urls)")
            
            // 清理临时文件
            for url in parent.fileURLs {
                try? FileManager.default.removeItem(at: url)
            }
        }
        
        func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
            // 用户取消保存，清理临时文件
            for url in parent.fileURLs {
                try? FileManager.default.removeItem(at: url)
            }
        }
    }
}
