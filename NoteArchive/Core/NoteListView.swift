//
//  NoteListView.swift
//  NoteArchive
//
//  Created by 梁骐显 on 2025/3/9.
//

import SwiftUI
import SwiftUICore
//import ContributionChart

struct NoteListView: View {
    var notes: FetchedResults<Note>
    @Binding var selectedNote: Note?
    var moveToTrash: (Note) -> Void
    var addNote: () -> Void
    var parentConfig: AppConfig? // 添加 appConfig 参数

    var body: some View {
        List {
            // 过滤掉“隐私”和“回收站”书架
            ForEach(notes.filter { $0.title != "隐私" && $0.title != "回收站" }, id: \.self) { note in
                NoteRowView(note: note, selectedNote: $selectedNote, moveToTrash: moveToTrash)

            }
            // 添加档案夹按钮
            AddNoteButtonView(addNote: addNote)
        }
        .listStyle(DefaultListStyle())

    }

    private func togglePin(note: Note) {
        withAnimation {
            note.isPinned.toggle()
            do {
                try note.managedObjectContext?.save()
            } catch {
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
}

struct AddNoteButtonView: View {
    var addNote: () -> Void

    var body: some View {
        Button(action: addNote) {
            HStack {
                Image(systemName: "plus.circle.fill")
                Text("添加档案夹")
            }
            .foregroundColor(.blue)
        }
    }
}

struct NoteRowView: View {
    var note: Note
    @Binding var selectedNote: Note?
    var moveToTrash: (Note) -> Void
    @State private var data = []
    var body: some View {
        let data = getCoverData(note: selectedNote ?? note)
        NavigationLink(destination: FolderView(note: note, folderState: FolderView.FolderState.e_normal), tag: note, selection: $selectedNote) {
            VStack {
                HStack{
                    if note.isPinned {
                        Image(systemName: "pin.fill")
                            .foregroundColor(.yellow)
                    }
                    Text(note.title ?? "Untitled")
                    Text("\(note.covers?.count ?? 0)")
                        .font(.caption)
                        .foregroundColor(.gray)
                    Spacer()

                }
                .padding(.bottom)
                HStack{
                    ContributionChartView(data: data, rows: 6, columns: 30, targetValue: 1.0,blockColor: .blue)
                        .frame(width: 320, height: 50)
                    Spacer()
                
                }
            }
            .padding()
//            .background(Color(.systemGray5))
//            .cornerRadius(10)
        }
        .swipeActions(edge: .leading, allowsFullSwipe: true) {
            Button {
                togglePin(note: note)
            } label: {
                Label(note.isPinned ? "Unpin" : "Pin", systemImage: note.isPinned ? "pin.slash" : "pin.fill")
            }
            .tint(note.isPinned ? .gray : .yellow)
        }
        // 根据 appConfig 的 notes 数量决定是否启用滑动删除
        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
//            if let appconfig = parentConfig, appconfig.notes?.count ?? 0 > 1 {
                Button(role: .destructive) {
                    moveToTrash(note)
                } label: {
                    Label("删除", systemImage: "trash")
                }
//            }
        }
    }

    private func togglePin(note: Note) {
        withAnimation {
            note.isPinned.toggle()
            do {
                try note.managedObjectContext?.save()
            } catch {
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
    
    private func getCoverData(note: Note) -> [Double] {
        var result: [Double] = []
        for cover in note.coversArray {
            // 使用 nil 合并运算符 (??) 提供默认值，以防 drawingPages 为 nil
            let pageCount = cover.drawingPages?.count ?? 0
            if pageCount > 10 {
                _ = 10
            }
            result.append(Double(pageCount) / 10.0)
        }
        return result
    }
}
