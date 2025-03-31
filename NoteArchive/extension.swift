//
//  extension.swift
//  NoteArchive
//
//  Created by BC on 2025/3/13.
//

import SwiftUICore
import UIKit
import PencilKit

extension ContainerValues {
    @Entry var viewWidth: CGFloat = 0
}

extension String {
    func size(_ font: UIFont) -> CGSize {
        size(withAttributes: [NSAttributedString.Key.font: font])
    }
    var localized: String {
        NSLocalizedString(self, comment: "")
    }
    func safeFileName() -> String {
        let invalidCharacters = CharacterSet(charactersIn: "/\\?%*|\"<>:")
        return self
            .components(separatedBy: invalidCharacters)
            .joined(separator: "")
            .replacingOccurrences(of: " ", with: "_")
    }
}

// 扩展 Note 以方便访问 covers
extension Note {
    var coversArray: [Cover] {
        return (covers?.allObjects as? [Cover]) ?? []
    }
}


// 扩展 Color 以支持十六进制颜色
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }

    func toHex() -> String {
        let components = UIColor(self).cgColor.components
        let r = Float(components?[0] ?? 0)
        let g = Float(components?[1] ?? 0)
        let b = Float(components?[2] ?? 0)
        return String(format: "#%02lX%02lX%02lX", lroundf(r * 255), lroundf(g * 255), lroundf(b * 255))
    }
}

extension View {
    var noteAnimation: Animation {
        .smooth(duration: 0.3)
    }
}

extension PKCanvasView {
    func toImage() -> UIImage {
        let drawing = self.drawing
        let bounds = self.bounds
        
        let renderer = UIGraphicsImageRenderer(bounds: bounds)
        return renderer.image { ctx in
            UIColor.white.setFill()
            ctx.fill(bounds)
            drawing.image(from: bounds, scale: UIScreen.main.scale).draw(in: bounds)
        }
    }
}
