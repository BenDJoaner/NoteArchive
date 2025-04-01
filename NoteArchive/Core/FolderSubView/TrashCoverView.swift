//
//  TrashCoverView.swift
//  NoteArchive
//
//  Created by BC on 2025/3/13.
//

import SwiftUICore
import SwiftUI
import CoreData

struct TrashCoverView: View {
    @ObservedObject var cover: Cover
    @ObservedObject var note: Note
    @State private var showDeleteConfirmation = false
    @Environment(\.managedObjectContext) private var viewContext
    var body: some View {
        ZStack {
            // 背景颜色
            Color(hex: cover.color ?? "#7D177D")
                .cornerRadius(10)
                .opacity(0.8)

            // 图片
            Image(systemName: "trash") // 使用图片名称
                .resizable() // 使图片可调整大小
                .scaledToFit() // 保持图片比例
                .frame(width: 180, height: 180) // 设置图片大小
                .offset(x: -50, y: 80)
                .opacity(0.5) // 设置透明度为 50%
                .foregroundColor(.white)
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
                Button(action: {
                    restoreCover(cover: cover)
                }) {
                    HStack {
                        Image(systemName: "arrow.uturn.backward")
                        Text("Restore")
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
                        Image(systemName: "text.page.slash.fill")
                        Text("Delete")
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
                        title: Text("Delete"),
                        message: Text("deleteConfirm"),
                        primaryButton: .destructive(Text("Delete"), action: {
                            // delete action
                            deleteCover(cover: cover)
                        }),
                        secondaryButton: .cancel()
                    )
                }
            }
            .padding(20)
        }
        .cornerRadius(20)
        .shadow(radius: 5)
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
            do {
                try viewContext.save()
            } catch {
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
}
