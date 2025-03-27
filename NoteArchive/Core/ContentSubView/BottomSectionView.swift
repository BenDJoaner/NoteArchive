//
//  BottomSectionView.swift
//  NoteArchive
//
//  Created by 梁骐显 on 2025/3/9.
//

import SwiftUI
import LocalAuthentication

struct BottomSectionView: View {
    var privacyNote: Note?
    var trashNote: Note?
    @Binding var selectedNote: Note?
    var appConfig: AppConfig? // 添加 appConfig 参数
    @State private var viewWidth: CGFloat = 300
    @State private var showAuthenticationFailedAlert = false
    var body: some View {
        VStack(spacing: 2) {
            Spacer()
            if let privacyNote = privacyNote {
                Button(action: {
                    authenticate { success in
                        if success {
                            selectedNote = privacyNote // 验证成功，设置 selectedNote
                        } else {
                            // 验证失败
                            showAuthenticationFailedAlert = true
                        }
                    }
                }) {
                    VStack {
                        Image(systemName: "lock.rectangle.stack.fill")
//                        Text("Confidential")
//                        Spacer()
//                        Text("\(privacyNote.covers?.count ?? 0)")
//                            .font(.caption)
//                            .foregroundColor(.white)
                    }
                    .padding()
                    .foregroundColor(.white)
                    .background(Color(.systemGray3))
                    .cornerRadius(10)
//                    .padding(.horizontal)
//                    .padding(.all, 5)
//                    .shadow(radius: 5)
                }
                .background(
                    // 使用 NavigationLink 控制跳转
                    NavigationLink(
                        destination: FolderView(note: privacyNote, folderState: FolderView.FolderState.e_privacy),
                        tag: privacyNote,
                        selection: $selectedNote,
                        label: { EmptyView() }
                    )
                )
            }

            if let trashNote = trashNote {
                Button(action: {
                    authenticate { success in
                        if success {
                            selectedNote = trashNote // 验证成功，设置 selectedNote
                        } else {
                            // 验证失败
                            showAuthenticationFailedAlert = true
                        }
                    }
                }) {
                    VStack {
                        Image(systemName: "trash.fill")
//                        Text("DestructionSite")
//                        Text("\(trashNote.covers?.count ?? 0)")
//                            .font(.caption)
//                            .foregroundColor(.gray)
                    }
                    .padding()
                    .foregroundColor(.white)
                    .background(Color(.red))
                    .cornerRadius(10)
//                    .padding(.horizontal)
//                    .padding(.all, 5)
//                    .shadow(radius: 5)
                }
                .background(
                    // 使用 NavigationLink 控制跳转
                    NavigationLink(
                        destination: FolderView(note: trashNote, folderState: FolderView.FolderState.e_trash),
                        tag: trashNote,
                        selection: $selectedNote,
                        label: { EmptyView() }
                    )
                )
            }
        }
    }

    private func authenticate(completion: @escaping (Bool) -> Void) {
        let context = LAContext()
        var error: NSError?

        // 检查设备是否支持生物识别或设备密码
        if context.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error) {
            let reason = "DestructionSite".localized

            // 使用 .deviceOwnerAuthentication 策略
            context.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: reason) { success, authenticationError in
                DispatchQueue.main.async {
                    if success {
                        completion(true)
                    } else {
                        // 验证失败
                        completion(false)
                    }
                }
            }
        } else {
            // 设备不支持任何验证方式
            completion(false)
        }
    }
}
