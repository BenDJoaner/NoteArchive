//
//  BlurView.swift
//  NoteArchive
//
//  Created by BC on 2025/3/13.
//

import UIKit
import SwiftUI

// 磨砂玻璃效果的包装器
struct BlurView: UIViewRepresentable {
    var style: UIBlurEffect.Style

    func makeUIView(context: Context) -> UIVisualEffectView {
        let blurEffect = UIBlurEffect(style: style)
        let blurView = UIVisualEffectView(effect: blurEffect)
        return blurView
    }

    func updateUIView(_ uiView: UIVisualEffectView, context: Context) {
        // 更新视图的逻辑（如果需要）
    }
}
