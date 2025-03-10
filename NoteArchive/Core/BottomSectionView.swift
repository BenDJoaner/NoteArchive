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
    
    @State private var showAuthenticationFailedAlert = false

    var body: some View {
        VStack(spacing: 2) {
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
                    HStack {
                        Image(systemName: "lock.fill")
                        Text("机密档案")
                        Spacer()
                        Text("\(privacyNote.covers?.count ?? 0)")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    .padding()
                    .background(Color(.systemGray5))
                    .cornerRadius(10)
                    .padding(.horizontal)
                    .padding(.all, 10)
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
                    HStack {
                        Image(systemName: "trash.fill")
                        Text("待销毁")
                        Spacer()
                        Text("\(trashNote.covers?.count ?? 0)")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    .padding()
                    .background(Color(.systemGray5))
                    .cornerRadius(10)
                    .padding(.horizontal)
                    .padding(.all, 10)
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
        .alert(isPresented: $showAuthenticationFailedAlert) {
            Alert(
                title: Text("验证失败"),
                message: Text("无法验证您的身份，请检查设备是否支持验证或是否设置了设备密码。"),
                dismissButton: .default(Text("确定"))
            )
        }
    }

    private func authenticate(completion: @escaping (Bool) -> Void) {
        let context = LAContext()
        var error: NSError?

        // 检查设备是否支持生物识别或设备密码
        if context.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error) {
            let reason = "请验证以访问隐私内容"

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
