//
//  NoteSelectionView.swift
//  NoteArchive
//
//  Created by BC on 2025/3/31.
//

import SwiftUICore
import SwiftUI

struct NoteSelectionView: View {
    @FetchRequest(
        entity: Note.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \Note.createdAt, ascending: true)]
    ) var notes: FetchedResults<Note>
    
    @Binding var selectedNotes: Set<Note>
    var onConfirm: () -> Void // 新增确认回调
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            List {
                ForEach(notes.filter { $0.isShowen }) { note in
                    HStack {
                        Text(note.title ?? "Untitled")
                        Spacer()
                        if selectedNotes.contains(note) {
                            Image(systemName: "checkmark")
                                .foregroundColor(.blue)
                        }
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        if selectedNotes.contains(note) {
                            selectedNotes.remove(note)
                        } else {
                            selectedNotes.insert(note)
                        }
                    }
                }
            }
            .navigationTitle("选择笔记")
            .navigationBarItems(
                leading: Button("取消") {
                    presentationMode.wrappedValue.dismiss()
                },
                trailing: Button("确认") {
                    onConfirm() // 用户明确点击确认时才调用
                    presentationMode.wrappedValue.dismiss()
                }
                .disabled(selectedNotes.isEmpty)
            )
        }
    }
}
