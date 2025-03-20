//
//  CanvasView.swift
//  NoteArchive
//
//  Created by BC on 2025/3/19.
//

import SwiftUI
import PencilKit
import Vision

struct CanvasView: UIViewRepresentable {
    var canvasView: PKCanvasView
    var toolPicker: PKToolPicker
    var onDrawingChange: () -> Void
    var background: BackgroundType
    @Environment(\.colorScheme) var colorScheme

    func makeUIView(context: Context) -> PKCanvasView {
        canvasView.drawingPolicy = .pencilOnly // iPad 仅允许 Apple Pencil
        toolPicker.addObserver(canvasView)
        toolPicker.setVisible(true, forFirstResponder: canvasView)
        canvasView.becomeFirstResponder()
        canvasView.delegate = context.coordinator
//        canvasView.tool = PKInkingTool(.pen, color: .black, width: 5)
        // 添加手势穿透
        canvasView.subviews.forEach {
            $0.isUserInteractionEnabled = false
        }
        updateBackground(uiView: canvasView)
        return canvasView
    }

    func updateUIView(_ uiView: PKCanvasView, context: Context) {
        updateBackground(uiView: uiView)
//        print("updateUIView >>> \(background)")
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(onDrawingChange: onDrawingChange)
    }

    private func updateBackground(uiView: PKCanvasView) {
        // 获取当前 colorScheme
        let currentColorScheme = colorScheme
        // 生成背景图片
        let backgroundImage = background.image(for: uiView.bounds.size, colorScheme: currentColorScheme)
        uiView.backgroundColor = UIColor(patternImage: backgroundImage)
        print("生成背景图片 updateBackground >>> \(background)")
    }

    class Coordinator: NSObject, PKCanvasViewDelegate {
        var onDrawingChange: () -> Void

        init(onDrawingChange: @escaping () -> Void) {
            self.onDrawingChange = onDrawingChange
//            print("onDrawingChange >>> \(background)")
        }

        func canvasViewDrawingDidChange(_ canvasView: PKCanvasView) {
            onDrawingChange()
        }
    }
    
}

