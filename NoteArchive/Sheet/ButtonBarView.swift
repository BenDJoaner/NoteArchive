//
//  ButtonBarView.swift
//  NoteArchive
//
//  Created by BC on 2025/3/12.
//

import SwiftUICore
import SwiftUI
import PencilKit
import Vision

// 在ButtonBarView结构体中添加背景类型枚举和绑定状态
enum BackgroundStyle: String, CaseIterable {
    case blank
    case horizontalLines
    case verticalLines
    case grid
    case dots
    
    static func from(string: String?) -> BackgroundStyle {
        guard let str = string else { return .blank }
        return BackgroundStyle(rawValue: str) ?? .blank
    }
}

struct ButtonBarView: View {
    var onClear: () -> Void // 清空按钮的回调
    var onAddPhoto: (UIImage, Int) -> Void// 修改onAddPhoto类型
    var onAddPDF: () -> Void
    var onDeletePage: () -> Void

    @Binding var isAIOn: Bool // Toggle 的状态
    @Binding var usePencil: Bool // Toggle 的状态
    @Binding var backgroundStyle: BackgroundStyle    // 添加背景样式绑定
    @Binding var currentPageIndex: Int    // 新增当前页面索引绑定
    @State private var selection2: String?
    
    var currentCanvasView: PKCanvasView
    
    @State private var recognizedText: String = ""
    var body: some View {
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 20) {
                // 清空按钮
                HStack{
                    //PDF
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
                    Spacer()
                    Button(action: onDeletePage) {
                        HStack{
                            VStack {
                                Image(systemName: "trash.slash")
                                Text("删除此页")
                            }
                        }
                        .font(.headline)
                        .padding()
                        .frame(maxWidth: 150, maxHeight: 200)
                        .background(.white)
                        .foregroundColor(.black)
                        .cornerRadius(10)
                        .shadow(radius: 3)
                        
                    }
                }
                
                // 选择背景按钮
                Menu {
                    ForEach(BackgroundStyle.allCases, id: \.self) { style in
                        Button {
                            backgroundStyle = style
                        } label: {
                            HStack {
                                Text(style.localizedName)
                                Spacer()
                                if style == backgroundStyle {
                                    Image(systemName: "checkmark")
                                }
                            }
                        }
                    }
                } label: {
                    HStack {
                        Image(systemName: "person.and.background.striped.horizontal")
                        VStack{
                            Text("背景样式")
                            Text("\(backgroundStyle.localizedName)")
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
                
                // Toggle
                VStack {
                    Toggle(isOn: $usePencil) {
                        HStack {
                            Image(systemName: "pencil.and.scribble")
                            Text("画笔工具")
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
                    Toggle(isOn: $isAIOn) {
                        HStack {
                            Image(systemName: "aqi.medium")
                            Text("AI识别")
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

                
                HStack{
                    ImagePicker(title: "图片", systemImage: "photo.badge.plus.fill", tint: .blue) { image in
                        onAddPhoto(image, currentPageIndex)
                    }
                    Spacer()
                    Button(action: onAddPDF) {
                        HStack{
                            VStack {
                                Image(systemName: "document.badge.plus.fill")
                                Text("PDF")
                            }
                        }
                        .font(.headline)
                        .padding()
                        .frame(maxWidth: 150, maxHeight: 200)
                        .background(.white)
                        .foregroundColor(.black)
                        .cornerRadius(10)
                        .shadow(radius: 3)
                        
                    }
                }

                HStack{
                    //PDF
                    Button(action: onAddPDF) {
                        HStack{
                            VStack {
                                Image(systemName: "square.and.arrow.up")
                                Text("分享")
                            }
                        }
                        .font(.headline)
                        .padding()
                        .frame(maxWidth: 150, maxHeight: 200)
                        .background(.white)
                        .foregroundColor(.black)
                        .cornerRadius(10)
                        .shadow(radius: 3)
                        
                    }
                    Spacer()
                    Button(action: onAddPDF) {
                        HStack{
                            VStack {
                                Image(systemName: "arrow.trianglehead.2.clockwise.rotate.90.icloud.fill")
                                Text("iCloud")
                            }
                        }
                        .font(.headline)
                        .padding()
                        .frame(maxWidth: 150, maxHeight: 200)
                        .background(.white)
                        .foregroundColor(.black)
                        .cornerRadius(10)
                        .shadow(radius: 3)
                        
                    }
                }
                
                HStack{
                    // 清空按钮
                    Button("识别文字") {
                        let image = currentCanvasView.toImage()
                        recognizeText(from: image) { text in
                            recognizedText = text
                        }
                    }
                    .font(.headline)
                    .padding()
                    .frame(maxWidth: 150, maxHeight: 200)
                    .background(.white)
                    .foregroundColor(.black)
                    .cornerRadius(10)
                    .shadow(radius: 3)
                    Spacer()
                    Text(recognizedText)
                        .font(.headline)
                        .padding()
                        .background(.white)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }

            }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .frame(height: 650)
        .padding(.horizontal, 20)
    }
    
    func recognizeText(from image: UIImage, completion: @escaping (String) -> Void) {
        guard let cgImage = image.cgImage else { return }
        
        let request = VNRecognizeTextRequest { (request, error) in
            guard let observations = request.results as? [VNRecognizedTextObservation] else { return }
            
            var recognizedText = ""
            for observation in observations {
                if let topCandidate = observation.topCandidates(1).first {
                    recognizedText += topCandidate.string + "\n"
                }
            }
            
            completion(recognizedText)
        }
        
        request.recognitionLevel = .accurate
        
        let requestHandler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        try? requestHandler.perform([request])
    }
    
}

extension BackgroundStyle {
    var localizedName: String {
        switch self {
        case .blank: return "空白"
        case .horizontalLines: return "横线"
        case .verticalLines: return "竖线"
        case .grid: return "网格"
        case .dots: return "点阵"
        }
    }
}
