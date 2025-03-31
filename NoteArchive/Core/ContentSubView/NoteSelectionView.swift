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
    var onConfirm: () -> Void
    @Environment(\.presentationMode) var presentationMode
    
    private let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]
    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVGrid(columns: columns, spacing: 16) {
                    ForEach(notes.filter { $0.isShowen }) { note in
                        NoteGridItem(note: note, isSelected: selectedNotes.contains(note)) {
                            if selectedNotes.contains(note) {
                                selectedNotes.remove(note)
                            } else {
                                selectedNotes.insert(note)
                            }
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("选择笔记")
            .navigationBarItems(
                leading: Button("取消") {
                    presentationMode.wrappedValue.dismiss()
                },
                trailing: Button("确认") {
                    onConfirm()
                    presentationMode.wrappedValue.dismiss()
                }
                .disabled(selectedNotes.isEmpty)
            )
        }
    }
}

struct NoteGridItem: View {
    var note: Note
    var isSelected: Bool
    var action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack {
                ZStack {
                    // Background with note color
                    Color(hex: note.colorStr ?? "#7D177D")
                        .cornerRadius(10)
                    
                    // Checkmark indicator
                    if isSelected {
                        VStack {
                            HStack {
                                Spacer()
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.title)
                                    .foregroundColor(.white)
                                    .padding(8)
                            }
                            Spacer()
                        }
                    }
                    
                    // Note content
                    VStack {
                        Text(note.title ?? "Untitled")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding(.top, 8)
                        
                        Spacer()
                        
                        // Display number of covers if available
                        if let covers = note.covers {
                            Text("\(covers.count) 个档案")
                                .font(.caption)
                                .foregroundColor(.white)
                                .padding(.bottom, 8)
                        }
                    }
                    .padding()
                }
                .frame(height: 120)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(isSelected ? Color.blue : Color.clear, lineWidth: 3)
                )
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
}
