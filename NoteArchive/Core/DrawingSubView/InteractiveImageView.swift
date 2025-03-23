//
//  InteractiveImageView.swift
//  NoteArchive
//
//  Created by BC on 2025/3/20.
//

import SwiftUI

struct InteractiveImageView: UIViewRepresentable {
    let image: UIImage
    @Binding var transform: CGAffineTransform
    let onUpdate: () -> Void
    
    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        view.backgroundColor = .clear
        
        // 添加图片层
        let imageView = UIImageView(image: image)
        imageView.contentMode = .scaleAspectFit
        imageView.frame = view.bounds
        imageView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(imageView)
        
        // 添加手势
        let pinch = UIPinchGestureRecognizer(
            target: context.coordinator,
            action: #selector(Coordinator.handlePinch)
        )
        let pan = UIPanGestureRecognizer(
            target: context.coordinator,
            action: #selector(Coordinator.handlePan)
        )
        view.addGestureRecognizer(pinch)
        view.addGestureRecognizer(pan)
        
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        uiView.transform = transform
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(transform: $transform, onUpdate: onUpdate)
    }
    
    class Coordinator {
        @Binding var transform: CGAffineTransform
        let onUpdate: () -> Void
        private var lastTranslation: CGPoint = .zero
        
        init(transform: Binding<CGAffineTransform>, onUpdate: @escaping () -> Void) {
            _transform = transform
            self.onUpdate = onUpdate
        }
        
        @objc func handlePinch(_ gesture: UIPinchGestureRecognizer) {
            switch gesture.state {
            case .changed:
                transform = transform.scaledBy(
                    x: gesture.scale,
                    y: gesture.scale
                )
                gesture.scale = 1.0
                onUpdate()
            default: break
            }
        }
        
        @objc func handlePan(_ gesture: UIPanGestureRecognizer) {
            let translation = gesture.translation(in: gesture.view)
            switch gesture.state {
            case .changed:
                transform = transform.translatedBy(
                    x: translation.x - lastTranslation.x,
                    y: translation.y - lastTranslation.y
                )
                lastTranslation = translation
                onUpdate()
            case .ended:
                lastTranslation = .zero
            default: break
            }
        }
    }
}

struct DraggableImageView: View {
    @ObservedObject var imageItem: ImageItem
    @State private var currentPosition: CGSize = .zero
    
    var body: some View {
        Image(uiImage: UIImage(data: imageItem.imageData!)!)
            .resizable()
            .frame(width: CGFloat(imageItem.width), height: CGFloat(imageItem.height))
            .offset(currentPosition)
            .gesture(
                DragGesture()
                    .onChanged { value in
                        self.currentPosition = value.translation
                        // 实时更新CoreData
                        imageItem.x = Double(value.location.x)
                        imageItem.y = Double(value.location.y)
                    }
            )
    }
}
