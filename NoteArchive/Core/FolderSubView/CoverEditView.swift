//
//  CoverEditView.swift
//  NoteArchive
//
//  Created by BC on 2025/3/13.
//

import SwiftUICore
import SwiftUI

// 封面编辑视图
struct CoverEditView: View {
    @ObservedObject var cover: Cover
//    var deleteAction: () -> Void
    @State private var editedTitle: String = ""
    @State private var showColorPicker: Bool = false
    @State private var showMoveMenu: Bool = false
    @State private var isPrivacy: Bool = false
    @Environment(\.managedObjectContext) private var viewContext
    @State private var toasts: [Toast] = []
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
            TextField("Edited Title", text: $editedTitle)
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
                        Color.white
                            .frame(width: 50, height: 50) // 设置背景大小为 50x50
                            .cornerRadius(10) // 设置背景的圆角为 10
                            .opacity(0.5)
                        // ColorPicker
                        ColorPicker("ArchiveColor".localized, selection: Binding(
                            get: { Color(hex: cover.color ?? "#7D177D") },
                            set: { newColor in
                                cover.color = newColor.toHex()
                                saveChanges()
                            })
                        )
                        .labelsHidden() // 隐藏标签，使 ColorPicker 更紧凑
                        .frame(width: 30, height: 30) // 设置 ColorPicker 的大小

                    }
                    .frame(width: 50, height: 50) // 确保 ZStack 的大小与背景一致
                    Text("Color")
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
                                    .fill(Color.white) // 灰色背景
                                    .frame(width: 50, height: 50)
                                    .opacity(0.5)
                                Image(systemName: "eye.slash.fill")
                                    .font(.title)
                                    .foregroundColor(.gray)
                            }
                            Text("Confidentiality")
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
                                .fill(Color.white) // 红色背景
                                .frame(width: 50, height: 50)
                                .opacity(0.5)
                            Image(systemName: "trash.fill")
                                .font(.title)
                                .foregroundColor(.red)
                        }
                        Text("Discard")
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
                                .fill(Color.white) // 蓝色背景
                                .frame(width: 50, height: 50)
                                .opacity(0.5)
                            Image(systemName: "arrow.right.circle.fill")
                                .font(.title)
                                .foregroundColor(.blue)
                        }
                        Text("Transfer")
                            .font(.caption)
                            .foregroundColor(.white)
                            .shadow(color: .black, radius: 1, x: 1, y: 1) // 添加阴影
                    }
                }
                .actionSheet(isPresented: $showMoveMenu) {
                    ActionSheet(
                        title: Text("TransferTo"),
                        buttons: notes.filter { $0.isShowen }.map { note in
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
        .background(Color(hex: cover.color ?? "#7D177D"))
        .cornerRadius(5)
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
//            Toast.shared.present(
//                title: "已转移到机密处",
//                symbol: "trash.fill",
//                tint: .red,
//                isUserInteractionEnabled: true,
//                timing: .long
//            )
            showToast()
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
//                    Toast.shared.present(
//                        title: "已转移到销毁处",
//                        symbol: "trash.fill",
//                        tint: .red,
//                        isUserInteractionEnabled: true,
//                        timing: .long
//                    )
                } else {
                    cover.note?.removeFromCovers(cover)
//                    Toast.shared.present(
//                        title: "档案已销毁",
//                        symbol: "trash.fill",
//                        tint: .red,
//                        isUserInteractionEnabled: true,
//                        timing: .long
//                    )
                }
            }
            showToast()

            
            do {
                try viewContext.save()
            } catch {
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
    
    func showToast() {
        withAnimation(.bouncy) {
            let toast = Toast { id in
                ToastView(id)
            }
            toasts.append(toast)
        }
    }
    
    @ViewBuilder
    func ToastView(_ id: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: "square.and.arrow.up.fill")
            
            Text("Hello world")
                .font(.callout)
            
            Spacer(minLength: 0)
            
            Button {
                $toasts.delete(id)
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .font(.title2)
            }
        }
        .foregroundStyle(.primary)
        .padding(.vertical, 12)
        .padding(.horizontal, 15)
        .background {
            Capsule()
                .fill(.background)
                .shadow(color: .black.opacity(0.06), radius: 3, x: -1, y: -3)
                .shadow(color: .black.opacity(0.06), radius: 2, x: 1, y: 4)
        }
        .padding(.horizontal, 15)
    }
}
