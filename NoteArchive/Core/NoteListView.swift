//
//  NoteListView.swift
//  NoteArchive
//
//  Created by 梁骐显 on 2025/3/9.
//

import SwiftUI
import SwiftUICore


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
            .onDelete(perform: deleteNotes)
            
            // 添加档案夹按钮
            AddNoteButtonView(addNote: addNote)
        }
        .listStyle(PlainListStyle())
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

    private func deleteNotes(offsets: IndexSet) {
//        if let allNots = appConfig?.notes?.allObjects, allNots.count <= 1 {
//            return
//        }
        withAnimation {
            for index in offsets {
                let note = notes[index]
                note.managedObjectContext?.delete(note)
            }
            do {
                try notes.first?.managedObjectContext?.save()
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

    var body: some View {
        NavigationLink(destination: FolderView(note: note, folderState: FolderView.FolderState.e_normal), tag: note, selection: $selectedNote) {
            HStack {
                Text(note.title ?? "Untitled")
                Spacer()
                if note.isPinned {
                    Image(systemName: "pin.fill")
                        .foregroundColor(.yellow)
                }
                Text("\(note.covers?.count ?? 0)")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
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
}
