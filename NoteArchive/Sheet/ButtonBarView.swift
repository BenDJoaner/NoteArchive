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
    case coordinate  // 新增坐标系
    case staff       // 新增五线谱
    
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
                            Text("EmptyPage")
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
                            Text("backgroundType")
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
                
//                VStack {
//                    HStack {
//                        Image(systemName: "ellipsis.curlybraces")
//                        Text("Coming more ...")
//                    }
//                    .toggleStyle(SwitchToggleStyle(tint: .blue)) // 自定义 Toggle 样式
//                    .padding()
//                    .frame(maxWidth: .infinity, maxHeight: .infinity)
//                    .background(.white)
//                    .foregroundColor(.black)
//                    .cornerRadius(10)
//                    .shadow(radius: 3)
//                }

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
                            Text("识别Text")
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
                    
                    Button(action: onAddPDF) {
                        HStack{
                            VStack {
                                Image(systemName: "document.on.document")
                                Text("CopyText")
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
                    
                    Button(action: {
                        let image = currentCanvasView.toImage()
                        recognizeText(from: image) { text in
                            recognizedText = text
                            UIPasteboard.general.string = text
                        }
                    }) {
                        HStack{
                            VStack {
                                Image(systemName: "document.on.document")
                                Text("CopyText")
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
                    
//                    // 清空按钮
//                    Button("CopyText") {
//                        let image = currentCanvasView.toImage()
//                        recognizeText(from: image) { text in
//                            recognizedText = text
//                        }
//                    }
//                    .font(.headline)
//                    .padding()
//                    .frame(maxWidth: 150, maxHeight: 200)
//                    .background(.white)
//                    .foregroundColor(.black)
//                    .cornerRadius(10)
//                    .shadow(radius: 3)
//                    Spacer()
//                    Text(recognizedText)
//                        .font(.headline)
//                        .padding()
//                        .background(.white)
//                        .frame(maxWidth: .infinity, maxHeight: .infinity)

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
        // 2. 多語言識別支持
        request.recognitionLanguages = ["zh-Hans", "en-US"]
        
        let requestHandler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        try? requestHandler.perform([request])
    }
    
}

extension BackgroundStyle {
    var localizedName: String {
        switch self {
        case .blank: return "blank".localized
        case .horizontalLines: return "horizontalLines".localized
        case .verticalLines: return "verticalLines".localized
        case .grid: return "grid".localized
        case .dots: return "dots".localized
        case .coordinate: return "coordinate".localized
        case .staff: return "staff".localized
        }
    }
}
