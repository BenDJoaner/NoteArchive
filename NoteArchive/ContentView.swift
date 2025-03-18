import SwiftUI
import CoreData

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(
        entity: Note.entity(),
        sortDescriptors: [
            NSSortDescriptor(keyPath: \Note.isPinned, ascending: false),
            NSSortDescriptor(keyPath: \Note.createdAt, ascending: true), // 根据 date 升序排序
//            NSSortDescriptor(keyPath: \Note.title, ascending: true)
        ]
    ) var notes: FetchedResults<Note>

    @State private var selectedNote: Note? = nil
    @State private var appConfig: AppConfig? = nil
    @State private var trigger: Bool = false
    var body: some View {
        NavigationView {
            ZStack{
                VStack(spacing: 0) {
                    // 笔记列表
                    NoteListView(notes: notes, selectedNote: $selectedNote, moveToTrash: moveToTrash, addNote: addNote, parentConfig: appConfig)

                    // 底部区域（隐私书架和回收站）
                    if let appConfig = appConfig {
                        BottomSectionView(privacyNote: appConfig.privacyNote, trashNote: appConfig.trashNote, selectedNote: $selectedNote)
                    }
                }
                .navigationTitle("档案柜")
                .onAppear {
                    setupAppConfig()
                }
            }
        }
//        .navigationViewStyle(DoubleColumnNavigationViewStyle()) // 设置双栏样式
        .navigationViewStyle(StackNavigationViewStyle()) // 设置堆栈样式
    }

    private func setupAppConfig() {
        let fetchRequest: NSFetchRequest<AppConfig> = AppConfig.fetchRequest()
        if let config = try? viewContext.fetch(fetchRequest).first {
            self.appConfig = config
        } else {
            // 创建 AppConfig 实例
            let newConfig = AppConfig(context: viewContext)
            
            // 创建隐私书架
            let privacyNote = Note(context: viewContext)
            privacyNote.id = UUID()
            privacyNote.title = "机密档案"
            privacyNote.isPinned = false
            newConfig.privacyNote = privacyNote

            // 创建回收站书架
            let trashNote = Note(context: viewContext)
            trashNote.id = UUID()
            trashNote.title = "销毁处"
            trashNote.isPinned = false
            newConfig.trashNote = trashNote

            // 保存
            do {
                try viewContext.save()
                self.appConfig = newConfig
            } catch {
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }

    private func moveToTrash(note: Note) {
        withAnimation {
            if let covers = note.covers?.allObjects as? [Cover] {
                for cover in covers {
                    if let drawingPages = cover.drawingPages, drawingPages.count > 0{
                        appConfig?.trashNote?.addToCovers(cover)
                    }
                }
            }
            viewContext.delete(note)
            do {
                try viewContext.save()
            } catch {
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
    
    private func addNote() {
        withAnimation {
            let newNote = Note(context: viewContext)
            newNote.id = UUID() // 设置唯一 id
            newNote.title = "档案夹 \(newNote.id?.uuidString.prefix(8) ?? "")" // 使用 id 的前 8 位
            newNote.isPinned = false
            newNote.createdAt = Date()
            
            do {
                try viewContext.save()
            } catch {
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }

    private func deleteNotes(offsets: IndexSet) {
        withAnimation {
            offsets.map { notes[$0] }.forEach(viewContext.delete)
            
            do {
                try viewContext.save()
            } catch {
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }

    private func deleteNote(note: Note) {
        withAnimation {
            if let covers = note.covers?.allObjects as? [Cover] {
                for page in covers {
                    viewContext.delete(page)
                }
            }
            viewContext.delete(note)
            
            do {
                try viewContext.save()
            } catch {
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }

    private func togglePin(note: Note) {
        withAnimation {
            note.isPinned.toggle()
            
            do {
                try viewContext.save()
            } catch {
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
