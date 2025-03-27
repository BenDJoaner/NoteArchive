//
//  TitleBarView.swift
//  NoteArchive
//
//  Created by BC on 2025/3/13.
//

import SwiftUICore
import SwiftUI

struct TitleBarView: View {
    @Binding var folderState: FolderView.FolderState
    var isPrivacy: Bool
    @Binding var newTitle: String
    @ObservedObject var note: Note // 将 note 作为 ObservedObject
    var saveTitle: () -> Void

    var body: some View {
        HStack {
            // 添加 ColorPicker
            if folderState == .e_editing && !isPrivacy {
//                Image(systemName: "square.and.pencil")
                ColorPicker("", selection: Binding(
                    get: { Color(hex: note.colorStr ?? "#FFFFFF") },
                    set: { newColor in
                        note.colorStr = newColor.toHex()
                        saveColor() // 保存颜色
                    }
                ))
                .labelsHidden()
                .frame(width: 30, height: 30)
                .padding(.leading)
            }

            if folderState == .e_editing && !isPrivacy {
                HStack(spacing: 10) {
                    TextField("editTitle", text: $newTitle)
                }
                .padding(.vertical, 10)
                .padding(.horizontal, 15)
                .background(.primary.opacity(0.06), in: .rect(cornerRadius: 10))
                
//                TextField("Enter new title", text: $newTitle)
//                    .textFieldStyle(RoundedBorderTextFieldStyle())
//                    .padding(.horizontal)
            } else {
                Text(titleForState())
                    .font(.largeTitle)
                    .bold()
                    .padding(.leading)
            }
            Spacer()
            // 编辑/保存按钮
            if folderState == .e_normal || folderState == .e_privacy {
                Button(action: {
                    folderState = .e_editing
                }) {
                    HStack {
                        Image(systemName: "rectangle.and.pencil.and.ellipsis")
                        Text("Edit")
                    }
                    .font(.headline)
                    .padding(.trailing)
                }
            } else if folderState == .e_editing {
                Button(action: {
                    saveTitle()
                    folderState = .e_normal
                }) {
                    HStack {
                        Image(systemName: "square.and.arrow.down")
                        Text("Save")
                    }
                    .font(.headline)
                    .padding(.trailing)
                }
            }
        }
        .padding(.top)
    }

    private func titleForState() -> String {
        switch folderState {
        case .e_normal:
            return note.title ?? ""
        case .e_editing:
            return isPrivacy ? "Confidential".localized : "Editing".localized
        case .e_trash:
            return "DestructionSite".localized
        case .e_privacy:
            return "Confidential".localized
        }
    }

    // 保存颜色到 note.colorStr
    private func saveColor() {
        do {
            try note.managedObjectContext?.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }
}
