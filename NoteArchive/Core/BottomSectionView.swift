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
            
//            ChipsView(width: viewWidth) {
//                ForEach(mockChips) { chip in
//                    let horizontalSpace: CGFloat = 10
//                    let viewWidth = chip.name.size(.preferredFont(forTextStyle: .body)).width + horizontalSpace * 2
//                    
//                    Text(chip.name)
//                        .font(.body)
//                        .foregroundStyle(.white)
//                        .padding(.vertical, 6)
//                        .padding(.horizontal, horizontalSpace)
//                        .background(.red.gradient, in: .capsule)
//                        .containerValue(\.viewWidth, viewWidth)
//                }
//            }
//            .frame(width: viewWidth)
//            .padding()
//            .background(Color.primary.opacity(0.08), in: .rect(cornerRadius: 10))
            
//            HoldDownButton(
//                text: "Hold To Increase",
//                paddingHorizontal: 25,
//                paddingVertical: 15,
//                duration: CGFloat(0.5),
//                scale: CGFloat(0.8),
//                background: .black,
//                loadingTint: .white.opacity(0.3)
////                shape: shapeStyle.shape
//            ) {
////                count += 1
//            }
//            .foregroundStyle(.white)
//            .padding(.vertical, 60)
            
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
                        Image(systemName: "lock.rectangle.stack.fill")
                        Text("机密档案")
                        Spacer()
                        Text("\(privacyNote.covers?.count ?? 0)")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                    .padding(.horizontal)
                    .padding(.all, 5)
                    .shadow(radius: 5)
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
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                    .padding(.horizontal)
                    .padding(.all, 5)
                    .shadow(radius: 5)
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
//        .alert(isPresented: $showAuthenticationFailedAlert) {
//            Alert(
//                title: Text("权限获取失败"),
//                message: Text("高级档案权限验证失败"),
//                dismissButton: .default(Text("确定"))
//            )
//        }
    }

    private func authenticate(completion: @escaping (Bool) -> Void) {
        let context = LAContext()
        var error: NSError?

        // 检查设备是否支持生物识别或设备密码
        if context.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error) {
            let reason = "档案高级权限验证"

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
