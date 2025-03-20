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

struct ButtonBarView: View {
    var onClear: () -> Void // 清空按钮的回调
    var onAddPhoto: (UIImage) -> Void
    var onAddPDF: () -> Void
    var onDeletePage: () -> Void
    var onBackgroundChange: (BackgroundType) -> Void // 背景选择按钮的回调
    @Binding var selectedBackground: BackgroundType // 当前选中的背景类型
    @Binding var isAIOn: Bool // Toggle 的状态
    @Binding var usePencil: Bool // Toggle 的状态
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
                        Text("[\(selectedBackground.rawValue)]") // 显示当前选择的背景类型
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
                    Toggle(isOn: $isAIOn) {
                        HStack {
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

                
                HStack{
                    ImagePicker(title: "导入\n图片", systemImage: "photo.badge.plus.fill", tint: .blue) { image in
                        onAddPhoto(image)
                    }
                    Spacer()
                    Button(action: onAddPDF) {
                        HStack{
                            VStack {
                                Image(systemName: "document.badge.plus.fill")
                                Text("导入\nPDF")
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
                                Text("分享档案")
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
                Text(recognizedText)
                    .font(.headline)
                    .padding()
                    .background(.white)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
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

