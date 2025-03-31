//
//  BackgroundImageView.swift
//  NoteArchive
//
//  Created by 梁骐显 on 2025/3/31.
//

import SwiftUICore

struct BackgroundImageView: View {
    var folderState: FolderView.FolderState
    var iconStr: String?  // Add this parameter
    var note: Note
    
    var body: some View {
        if folderState == .e_privacy {
            Image(systemName: "lock.open.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 300, height: 300)
                .offset(x: 100, y: 300)
                .foregroundColor(Color(.systemGreen))
                .opacity(0.2)
        } else if folderState == .e_trash {
            Image(systemName: "trash")
                .resizable()
                .scaledToFit()
                .frame(width: 300, height: 300)
                .offset(x: 100, y: 300)
                .foregroundColor(Color(.systemRed))
                .opacity(0.2)
        } else if let iconStr = iconStr {
            // Use the selected icon from note.iconStr
            Image(systemName: iconStr)
                .resizable()
                .scaledToFit()
                .frame(width: 300, height: 300)
                .offset(x: 100, y: 300)
                .foregroundColor(Color(hex: note.colorStr ?? "#7D177D"))
                .opacity(0.5)
        }
    }
}
