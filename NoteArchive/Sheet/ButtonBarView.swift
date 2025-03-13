//
//  ButtonBarView.swift
//  NoteArchive
//
//  Created by BC on 2025/3/12.
//

import SwiftUICore
import SwiftUI

struct ButtonBarView: View {
    var onClear: () -> Void // 清空按钮的回调
    var onBackgroundChange: (BackgroundType) -> Void // 背景选择按钮的回调
    @Binding var selectedBackground: BackgroundType // 当前选中的背景类型
    @Binding var isToggleOn: Bool // Toggle 的状态
    var body: some View {
//        VStack(spacing: 15) {
//            Text("编辑方式")
//                .multilineTextAlignment(.center)
            
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 20) {
                // 清空按钮
                Button(action: onClear) {
                    VStack {
                        Image(systemName: "eraser.line.dashed.fill")
                        Text("清空板块")
                    }
                    .font(.headline)
                    .padding()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(.white)
                    .foregroundColor(.black)
                    .cornerRadius(10)
                    .shadow(radius: 3)
                }
                
                // 选择背景按钮
                Menu {
                    ForEach(BackgroundType.allCases, id: \.self) { background in
                        Button(action: {
                            onBackgroundChange(background)
                        }) {
                            HStack {
                                Text(background.rawValue)
                                if selectedBackground == background {
                                    Image(systemName: "checkmark")
                                }
                            }
                        }
                    }
                } label: {
                    VStack {
                        Image(systemName: "paintbrush")
                        Text("背景样式")
                        Text(selectedBackground.rawValue) // 显示当前选择的背景类型
                            .font(.caption)
                            .foregroundColor(.white)
                    }
                    .font(.headline)
                    .padding()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(.white)
                    .foregroundColor(.black)
                    .cornerRadius(10)
                    .shadow(radius: 3)
                }
                
                // Toggle
                VStack {
                    Toggle(isOn: $isToggleOn) {
                        VStack {
                            Image(systemName: "pencil.and.scribble")
                            Text("Only Pencil")
                        }
                    }
                    .toggleStyle(SwitchToggleStyle(tint: .blue)) // 自定义 Toggle 样式
                    .padding()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(.white)
                    .foregroundColor(.black)
                    .cornerRadius(10)
                    .shadow(radius: 3)
                }

                
                //AI
                VStack {
                    Toggle(isOn: $isToggleOn) {
                        VStack {
                            Image(systemName: "aqi.medium")
                            Text("AI")
                        }
                    }
                    .toggleStyle(SwitchToggleStyle(tint: .blue)) // 自定义 Toggle 样式
                    .padding()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(.white)
                    .foregroundColor(.black)
                    .cornerRadius(10)
                    .shadow(radius: 3)
                }

                
                //photo
                Button(action: onClear) {
                    VStack {
                        Image(systemName: "photo.badge.plus.fill")
                        Text("photo")
                    }
                    .font(.headline)
                    .padding()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(.white)
                    .foregroundColor(.black)
                    .cornerRadius(10)
                    .shadow(radius: 3)
                }
                
                //PDF
                Button(action: onClear) {
                    HStack{
                        Image(systemName: "plus.app.fill")
                        VStack {
                            Image(systemName: "document.badge.plus.fill")
                            Text("PDF")
                        }
                    }
                    .font(.headline)
                    .padding()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(.white)
                    .foregroundColor(.black)
                    .cornerRadius(10)
                    .shadow(radius: 3)
                }
            }
//            .padding(20) // 设置 LazyVGrid 与 view 边框的间距
//            .padding(3)
//            .background(.primary.opacity(0.06), in: .capsule)
//            .padding(.top, 20)
//        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .frame(height: 410)
//        .background(.themeBG)
//        .clipShape(.rect(cornerRadius: 30))
        .padding(.horizontal, 20)
    }
}
