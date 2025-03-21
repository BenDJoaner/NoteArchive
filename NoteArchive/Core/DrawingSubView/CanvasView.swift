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
    
//    @Binding var backgroundStyle: BackgroundStyle// 添加背景样式绑定
    @Binding var isToolPickerVisible: Bool // 新增绑定
    var onDrawingChange: () -> Void
    @Environment(\.colorScheme) var colorScheme

    func makeUIView(context: Context) -> PKCanvasView {
        // 添加背景
//        addBackground(to: canvasView)

        canvasView.drawingPolicy = .pencilOnly // iPad 仅允许 Apple Pencil
        canvasView.delegate = context.coordinator
//        canvasView.tool = PKInkingTool(.pen, color: .black, width: 5)
        canvasView.backgroundColor = .white
        // 添加手势穿透
//        canvasView.subviews.forEach {
//            $0.isUserInteractionEnabled = false
//        }
        
        updateToolPickerVisibility()
        return canvasView
    }

    func updateUIView(_ uiView: PKCanvasView, context: Context) {
        // 更新时检查背景视图
//        if let background = uiView.subviews.first(where: { $0 is BackgroundView }) as? BackgroundView {
//            background.style = backgroundStyle
//            background.setNeedsDisplay()
//        } else {
//            addBackground(to: uiView)
//        }
        updateToolPickerVisibility()
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(onDrawingChange: onDrawingChange)
    }

    class Coordinator: NSObject, PKCanvasViewDelegate {
        var onDrawingChange: () -> Void

        init(onDrawingChange: @escaping () -> Void) {
            self.onDrawingChange = onDrawingChange
        }

        func canvasViewDrawingDidChange(_ canvasView: PKCanvasView) {
            onDrawingChange()
        }
    }
    
    private func updateToolPickerVisibility() {
        toolPicker.setVisible(isToolPickerVisible, forFirstResponder: canvasView)
        if isToolPickerVisible {
            canvasView.becomeFirstResponder()
        } else {
            canvasView.resignFirstResponder()
        }
    }
    
    // 在 CanvasView 的 makeUIView 中
//    private func addBackground(to canvasView: PKCanvasView) {
//        // 移除旧背景
//        canvasView.subviews
//            .filter { $0 is BackgroundView }
//            .forEach { $0.removeFromSuperview() }
//        
//        // 添加新背景
//        let backgroundView = BackgroundView(style: backgroundStyle)
////        backgroundView.isUserInteractionEnabled = false
//        backgroundView.backgroundColor = .systemGray5 // 确保背景可见
//        canvasView.insertSubview(backgroundView, at: 0)
//        
//        // 约束设置
//        backgroundView.translatesAutoresizingMaskIntoConstraints = false
//        NSLayoutConstraint.activate([
//            backgroundView.leadingAnchor.constraint(equalTo: canvasView.leadingAnchor),
//            backgroundView.trailingAnchor.constraint(equalTo: canvasView.trailingAnchor),
//            backgroundView.topAnchor.constraint(equalTo: canvasView.topAnchor),
//            backgroundView.bottomAnchor.constraint(equalTo: canvasView.bottomAnchor)
//        ])
//    }
    // 添加背景视图实现
    private class BackgroundView: UIView {
        var style: BackgroundStyle
        
        init(style: BackgroundStyle) {
            self.style = style
            super.init(frame: .zero)
            backgroundColor = .white
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        override func draw(_ rect: CGRect) {
            guard let context = UIGraphicsGetCurrentContext() else { return }
            
            context.setStrokeColor(UIColor.lightGray.cgColor)
            context.setLineWidth(0.5)
            
            switch style {
            case .blank:
                break
                
            case .horizontalLines:
                drawHorizontalLines(in: context, rect: rect)
                
            case .verticalLines:
                drawVerticalLines(in: context, rect: rect)
                
            case .grid:
                drawHorizontalLines(in: context, rect: rect)
                drawVerticalLines(in: context, rect: rect)
                
            case .dots:
                drawDots(in: context, rect: rect)
            }
        }
        
        private func drawHorizontalLines(in context: CGContext, rect: CGRect) {
            let spacing: CGFloat = 20
            for y in stride(from: 0, to: rect.height, by: spacing) {
                context.move(to: CGPoint(x: 0, y: y))
                context.addLine(to: CGPoint(x: rect.width, y: y))
            }
            context.strokePath()
        }
        
        private func drawVerticalLines(in context: CGContext, rect: CGRect) {
            let spacing: CGFloat = 20
            for x in stride(from: 0, to: rect.width, by: spacing) {
                context.move(to: CGPoint(x: x, y: 0))
                context.addLine(to: CGPoint(x: x, y: rect.height))
            }
            context.strokePath()
        }
        
        private func drawDots(in context: CGContext, rect: CGRect) {
            let spacing: CGFloat = 10
            context.setFillColor(UIColor.lightGray.cgColor)
            
            for x in stride(from: 0, to: rect.width, by: spacing) {
                for y in stride(from: 0, to: rect.height, by: spacing) {
                    let dotRect = CGRect(x: x-0.5, y: y-0.5, width: 1, height: 1)
                    context.fillEllipse(in: dotRect)
                }
            }
        }
        
    }
    
}

