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
    var systemImageType: SystemImageType? // 接收外部传入的 systemImage 类型
    @Namespace private var namespace // 命名空间
    @State private var showSettingSheet: Bool = false
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background Image (now using note.iconStr)
                BackgroundImageView(
                    folderState: folderState,
                    iconStr: note.iconStr,  // Pass the icon string
                    note: note
                )
                
                // Main Content
                VStack {
                    // Header (now properly bound to note.iconStr)
                    FolderHeaderView(
                        folderState: $folderState,
                        newTitle: $newTitle,
                        note: note,
                        saveTitle: saveTitle,
                        isPrivacy: isPrivacy
                    )
                    
                    // Cover Grid
                    CoverGridView(
                        note: note,
                        folderState: $folderState,
                        isPrivacy: isPrivacy,
                        iconStr: note.iconStr,  // Pass the icon string
                        namespace: namespace,
                        addCoverAction: addCover
                    )
                }
            }
        }
        .onAppear {
            newTitle = note.title ?? ""
            isPrivacy = folderState == .e_privacy
        }
    }

    private func titleForState() -> String {
        switch folderState {
        case .e_normal:
            return note.title ?? ""
        case .e_editing:
            return ""
            
        case .e_trash:
            return "DestructionSite".localized
        case .e_privacy:
            return "Confidential".localized
        }
    }
    
    private func restoreCover(cover: Cover) {
        withAnimation {
            let fetchRequest: NSFetchRequest<Note> = Note.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "title == %@", "Retrieved".localized)
            if let restoredNote = try? viewContext.fetch(fetchRequest).first {
                restoredNote.addToCovers(cover)
            } else {
                let newRestoredNote = Note(context: viewContext)
                newRestoredNote.id = UUID()
                newRestoredNote.title = "Retrieved".localized
                newRestoredNote.isPinned = false
                newRestoredNote.addToCovers(cover)
            }
            note.removeFromCovers(cover)
//            Toast.shared.present(
//                title: "转移到取出档案",
//                symbol: "trash.fill",
//                tint: .red,
//                isUserInteractionEnabled: true,
//                timing: .long
//            )
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
            newCover.title = "\("NewArchive".localized)\(note.coversArray.count+1)"
            newCover.createdAt = Date()
            newCover.color = folderState == .e_privacy ? "#555555" : randomColor() // 隐私状态下为黑色
            newCover.isAnalyze = false
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
            
//            Toast.shared.present(
//                title: "档案已彻底销毁",
//                symbol: "trash.fill",
//                tint: .red,
//                isUserInteractionEnabled: true,
//                timing: .long
//            )
//            
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
        let colors = ["#EB8496", "#BCBAD2", "#D4A5A5", "#C7B8EA", "#A8D8B9", "#F0C9C9", "#B5E1E1", "#E6D3AC", "#D8BFD8", "#A8C6D8"]
        return colors.randomElement() ?? "#7D177D"
    }
}


// 添加封面按钮
struct AddCoverButton: View {
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.white.opacity(0.8))
                    .shadow(radius: 5)
                Image(systemName: "document.badge.plus.fill")
                    .font(.largeTitle)
                    .foregroundColor(Color(.systemBlue))
            }
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

