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
    
    @Binding var backgroundStyle: BackgroundStyle// 添加背景样式绑定
    @Binding var isToolPickerVisible: Bool // 新增绑定
    var onDrawingChange: () -> Void
    @Environment(\.colorScheme) var colorScheme

    func makeUIView(context: Context) -> PKCanvasView {
        // 添加背景
        addBackground(to: canvasView)
        // ✅ 关键配置 1: 只允许笔输入
        canvasView.drawingPolicy = .pencilOnly
        // ✅ 关键配置 2: 使用支持压力感应的画笔
        let inkTool = PKInkingTool(
            .pen,
            color: UIColor.black,
            width: 15 // 基础宽度
        )
        canvasView.tool = inkTool
        canvasView.backgroundColor = .clear
        // 添加手势穿透
        canvasView.subviews.forEach {
            $0.isUserInteractionEnabled = false
        }

        updateToolPickerVisibility()
        return canvasView
    }

    func updateUIView(_ uiView: PKCanvasView, context: Context) {
        // 更新时检查背景视图
        if let background = uiView.subviews.first(where: { $0 is BackgroundView }) as? BackgroundView {
            background.style = backgroundStyle
            background.setNeedsDisplay() // ✅ 主动触发重绘
        } else {
            addBackground(to: uiView)
        }
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
        toolPicker.addObserver(canvasView)
        toolPicker.setVisible(isToolPickerVisible, forFirstResponder: canvasView)
        if isToolPickerVisible {
            canvasView.becomeFirstResponder()
        } else {
            canvasView.resignFirstResponder()
        }
    }
    
    // 在 CanvasView 的 makeUIView 中
    private func addBackground(to canvasView: PKCanvasView) {
        print("addBackground ✅ 在 CanvasView 的 makeUIView 中")
        // 移除旧背景
        canvasView.subviews
            .filter { $0 is BackgroundView }
            .forEach { $0.removeFromSuperview() }
        
        // 添加新背景
        let backgroundView = BackgroundView(style: backgroundStyle)
        backgroundView.isUserInteractionEnabled = false
        backgroundView.backgroundColor = .clear // 确保背景可见
        
        canvasView.insertSubview(backgroundView, at: 0)
        
        // 约束设置
        backgroundView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            backgroundView.leadingAnchor.constraint(equalTo: canvasView.safeAreaLayoutGuide.leadingAnchor),
            backgroundView.trailingAnchor.constraint(equalTo: canvasView.safeAreaLayoutGuide.trailingAnchor),
            backgroundView.topAnchor.constraint(equalTo: canvasView.safeAreaLayoutGuide.topAnchor),
            backgroundView.bottomAnchor.constraint(equalTo: canvasView.safeAreaLayoutGuide.bottomAnchor)
        ])
        
        // ✅ 立即触发布局计算
        canvasView.setNeedsLayout()
        canvasView.layoutIfNeeded()
        
        // 此时 frame 仍可能为0，因为父视图尚未完成布局
        print("⏱️ 立即获取背景视图尺寸:", backgroundView.frame)
        
        // ✅ 延迟获取实际尺寸
        DispatchQueue.main.async {
            print("🕒 延迟获取背景视图尺寸:", backgroundView.frame)
        }
    }
    // 添加背景视图实现
    private class BackgroundView: UIView {
        var style: BackgroundStyle {
            didSet {
                setNeedsDisplay() // ✅ 样式变化时自动重绘
            }
        }
        
        init(style: BackgroundStyle) {
            print("添加背景视图实现 init \(style)")
            self.style = style
            super.init(frame: .zero)
            // 关键配置
            configureView()
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        private func configureView() {
            isOpaque = false
            backgroundColor = .blue
            contentMode = .redraw
        }
        
        override func draw(_ rect: CGRect) {
            print("Drawing rect:", rect) // ✅ 确认绘制区域
            guard !rect.isEmpty else { return } // ✅ 跳过无效绘制
            
            guard let context = UIGraphicsGetCurrentContext() else { return }
            print("Draw background >>>>>>")
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
            let spacing: CGFloat = 36
            for y in stride(from: 0, to: rect.height, by: spacing) {
                context.move(to: CGPoint(x: 0, y: y))
                context.addLine(to: CGPoint(x: rect.width, y: y))
            }
            context.strokePath()
            print("drawHorizontalLines")
        }
        
        private func drawVerticalLines(in context: CGContext, rect: CGRect) {
            let spacing: CGFloat = 36
            for x in stride(from: 0, to: rect.width, by: spacing) {
                context.move(to: CGPoint(x: x, y: 0))
                context.addLine(to: CGPoint(x: x, y: rect.height))
            }
            context.strokePath()
            print("drawVerticalLines")
        }
        
        private func drawDots(in context: CGContext, rect: CGRect) {
            let spacing: CGFloat = 36
            context.setFillColor(UIColor.lightGray.cgColor)
            
            for x in stride(from: 0, to: rect.width, by: spacing) {
                for y in stride(from: 0, to: rect.height, by: spacing) {
                    let dotRect = CGRect(x: x-0.5, y: y-0.5, width: 3, height: 3)
                    context.fillEllipse(in: dotRect)
                }
            }
            print("drawDots")
        }
        
        override func layoutSubviews() {
            super.layoutSubviews()
            print("Layout bounds:", bounds) // ✅ 调试输出
            setNeedsDisplay() // ✅ 确保布局变化后重绘
            print("""
            🟢 布局完成:
            - Frame: \(frame)
            - Bounds: \(bounds)
            - Superview Size: \(superview?.bounds.size ?? .zero)
            """)
            
            // 验证约束是否生效
            if let sv = superview {
                print("约束检查:")
                print("Leading约束:", constraints.first { $0.firstAnchor == leadingAnchor }?.constant ?? "无")
                print("父视图尺寸:", sv.bounds.size)
            }
        }
        
    }
    
}

