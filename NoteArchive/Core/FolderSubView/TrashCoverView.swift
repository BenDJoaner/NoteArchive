//
//  TrashCoverView.swift
//  NoteArchive
//
//  Created by BC on 2025/3/13.
//

import SwiftUICore
import SwiftUI

struct TrashCoverView: View {
    @ObservedObject var cover: Cover
    var restoreAction: () -> Void
    var deleteAction: () -> Void
    @State private var showDeleteConfirmation = false
    
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
                Button(action: restoreAction) {
                    HStack {
                        Image(systemName: "arrow.uturn.backward")
                        Text("还原")
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
                        Text("销毁")
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
                        title: Text("销毁"),
                        message: Text("确定销毁该档案吗？销毁后将无法还原。"),
                        primaryButton: .destructive(Text("销毁"), action: deleteAction),
                        secondaryButton: .cancel()
                    )
                }
            }
            .padding(20)
        }
        .cornerRadius(20)
        .shadow(radius: 5)
    }
}
