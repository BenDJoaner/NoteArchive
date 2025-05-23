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
    @State var showSideBar = false
    var body: some View {
        

        NavigationView {
            HStack(spacing: 0) {
                VStack {
                    // 底部区域（隐私书架和回收站）
                    if let appConfig = appConfig {
                        BottomSectionView(
                            privacyNote: appConfig.privacyNote,
                            trashNote: appConfig.trashNote,
                            selectedNote: $selectedNote,
                            appConfig: appConfig
                        )
                    }
                    Spacer(minLength:  getScreenRect().height < 750 ? 30 : 50)
                    Button(action: {
                        withAnimation(.easeIn) {
                            showSideBar.toggle()
                        }
                        
                    }, label: {
                        Image(systemName: "chevron.right")
                            .font(.title2)
                            .foregroundColor(.white)
                            .rotationEffect(.init(degrees:  showSideBar ? -180 : 0))
                            .padding()
                            .background(Color.black)
                            .cornerRadius(10)
                            .shadow(radius: 5)
                        
                    })
                    .padding(.top,  getScreenRect().height < 750 ? 15 : 30)
                    .padding(.bottom, getSafeArea().bottom == 0 ? 15 : 0)
                    .offset(x: showSideBar ? 0 : 100)
                    
                }
                .frame(width: 80)
                .background(Color.black.ignoresSafeArea())
                .offset(x: showSideBar ? 0 : -100)
                .padding(.trailing, showSideBar ? CGFloat(0) : -100)
                .zIndex(1.0)
                VStack(spacing: 0) {
                    // 笔记列表
                    NoteListView(notes: notes, selectedNote: $selectedNote, moveToTrash: moveToTrash, addNote: addNote, parentConfig: appConfig)
                    if let appConfig = appConfig {
                        BottomSectionView(
                            privacyNote: appConfig.privacyNote,
                            trashNote: appConfig.trashNote,
                            selectedNote: $selectedNote,
                            appConfig: appConfig
                        )
                            .hidden()
                            .frame( height: 0)
                    }
                }
//                .navigationTitle("ArchiveBox")
            }

        }
        .navigationViewStyle(StackNavigationViewStyle()) // 设置堆栈样式
        .onAppear {
            setupAppConfig()
        }
    }

    private func setupAppConfig() {
        let fetchRequest: NSFetchRequest<AppConfig> = AppConfig.fetchRequest()
        if let config = try? viewContext.fetch(fetchRequest).first {
            self.appConfig = config
            if let window = UIApplication.shared.windows.first {
                window.overrideUserInterfaceStyle = config.themeScheme ? .dark : .light
            }
        } else {
            // 创建 AppConfig 实例
            let newConfig = AppConfig(context: viewContext)
            
            // 创建隐私书架
            let privacyNote = Note(context: viewContext)
            privacyNote.id = UUID()
            privacyNote.title = "Confidential".localized
            privacyNote.isPinned = false
            privacyNote.isShowen = false
            newConfig.privacyNote = privacyNote

            // 创建回收站书架
            let trashNote = Note(context: viewContext)
            trashNote.id = UUID()
            trashNote.title = "DestructionSite".localized
            trashNote.isPinned = false
            trashNote.isShowen = false
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
            newNote.title = "\("Folder".localized) \(newNote.id?.uuidString.prefix(8) ?? "")" // 使用 id 的前 8 位
            newNote.isPinned = false
            newNote.createdAt = Date()
            newNote.isShowen = true
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
