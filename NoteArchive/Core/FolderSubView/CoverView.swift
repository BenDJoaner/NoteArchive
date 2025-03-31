//
//  CoverView.swift
//  NoteArchive
//
//  Created by BC on 2025/3/13.
//

import SwiftUICore
import PencilKit

// 封面视图
struct CoverView: View {
    var cover: Cover
    var isPrivacy: Bool
    var iconStr: String?  // Add this parameter
    var onLongPress: () -> Void // 添加长按回调

    var body: some View {
        ZStack {
            // 背景颜色
            Color(hex: cover.color ?? "#7D177D")
                .cornerRadius(10)
            
            // 显示 systemImage
            if let iconStr = iconStr {
                Image(systemName: iconStr)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 120, height: 120)
                    .offset(x: 20, y: -50)
                    .foregroundColor(.white)
                    .opacity(0.2)
            }
            
            if isPrivacy {
                // 图片
                Image(systemName: "person.badge.shield.checkmark") // 使用图片名称
                    .resizable() // 使图片可调整大小
                    .scaledToFit() // 保持图片比例
                    .frame(width: 180, height: 180) // 设置图片大小
                    .offset(x: -50, y: 80)
                    .opacity(0.5) // 设置透明度为 50%
                    .foregroundColor(.white)
            }

            
            // 标题文本
            VStack {
                Text(cover.title ?? "Untitled")
                    .font(.headline)
                    .foregroundColor(.white)
                    .shadow(color: .black, radius: 1, x: 1, y: 1)
                    .padding(10)
                Spacer()
            }

            // 第一个 page 的缩小版本内容（如果存在）
            if let drawingPages = cover.drawingPages,
               drawingPages.count > 0,
               let minPage = drawingPages.allObjects.min(by: { ($0 as? DrawingPage)?.page ?? 0 < ($1 as? DrawingPage)?.page ?? 0 }),
               let firstPage = minPage as? DrawingPage,
               let pageData = firstPage.data,
               let drawing = try? PKDrawing(data: pageData) {
                let image = drawing.image(from: drawing.bounds, scale: 0.5) // 缩小版本
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding(20)
            }

            // 左下角显示创建时间
            VStack {
                Spacer()
                HStack {
                    if let date = cover.createdAt {
                        Text(formatDate(date))
                            .font(.caption)
                            .foregroundColor(.white)
                            .shadow(color: .black, radius: 2, x: 1, y: 1)
                            .padding(10)
                    }
                    Spacer()
                    Text("\(cover.drawingPages?.count ?? 0)\("Pages".localized)")
                        .font(.caption)
                        .foregroundColor(.white)
                        .shadow(color: .black, radius: 2, x: 1, y:1)
                        .padding(10)
                }
            }
        }
        .cornerRadius(5)
        .shadow(radius: 5)
        .onLongPressGesture {
            onLongPress() // 触发长按回调
        }
        
    }

    // 格式化日期
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }
}
