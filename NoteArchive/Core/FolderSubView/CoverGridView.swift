//
//  CoverGridView.swift
//  NoteArchive
//
//  Created by 梁骐显 on 2025/3/31.
//

import SwiftUICore
import SwiftUI

struct CoverGridView: View {
    @ObservedObject var note: Note
    @Binding var folderState: FolderView.FolderState
    var isPrivacy: Bool
    var iconStr: String?  // Add this parameter
    var namespace: Namespace.ID
    var addCoverAction: () -> Void
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHGrid(rows: [GridItem(.adaptive(minimum: 290))], spacing: 20) {
                ForEach(note.coversArray.sorted { $0.createdAt ?? Date() < $1.createdAt ?? Date() }, id: \.self) { cover in
                    if folderState == .e_editing {
                        CoverEditView(cover: cover)
                            .frame(width: 180, height: 280)
                    } else if folderState == .e_trash {
                        TrashCoverView(cover: cover, restoreAction: {
                            // restore action
                        }, deleteAction: {
                            // delete action
                        })
                        .frame(width: 180, height: 280)
                    } else {
                        NavigationLink(destination: DrawingView(cover: cover, namespace: namespace)) {
                            CoverView(
                                cover: cover,
                                isPrivacy: isPrivacy,
                                iconStr: iconStr,  // Pass the icon string
                                onLongPress: {
                                    folderState = .e_editing
                                }
                            )
                            .frame(width: 180, height: 280)
                        }
                    }
                }
                
                if folderState == .e_normal || folderState == .e_privacy {
                    AddCoverButton {
                        addCoverAction()
                    }
                    .frame(width: 180, height: 280)
                }
            }
            .padding()
        }
    }
}
