//
//  BackgroundType.swift
//  NoteArchive
//
//  Created by BC on 2025/3/13.
//

import SwiftUICore
import UIKit
enum BackgroundType: String, CaseIterable {
    case blank = "空白"
    case horizontalLines = "横线"
    case verticalLines = "竖线"
    case grid = "方格"
    case dots = "点阵"
    case coordinate2D = "坐标系"
//    case coordinate3D = "3D Coordinate"

    func image(for size: CGSize, colorScheme: ColorScheme) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: size)
        print("BackgroundType.image >>> \(self)")
        return renderer.image { context in
            // 背景颜色为白色（浅色主题）或黑色（深色主题）
            let backgroundColor = colorScheme == .light ? UIColor.white : UIColor.black
            backgroundColor.setFill()
            context.fill(CGRect(origin: .zero, size: size))

            // 线条和点的颜色为灰色（浅色主题）或浅灰色（深色主题）
            let axisColor = colorScheme == .light ? UIColor.darkGray : UIColor.lightGray
            let tickColor = colorScheme == .light ? UIColor.lightGray : UIColor.gray.withAlphaComponent(0.5)
            print("renderer.image >>> \(self)")
            switch self {
            case .blank:
                break
            case .horizontalLines:
                tickColor.setStroke()
                let path = UIBezierPath()
                let spacing: CGFloat = 45
                let offset: CGFloat = 5
                var y = offset
                while y < size.height {
                    path.move(to: CGPoint(x: offset, y: y))
                    path.addLine(to: CGPoint(x: size.width - offset, y: y))
                    y += spacing
                }
                path.stroke()
                print("case .horizontalLines")
            case .verticalLines:
                tickColor.setStroke()
                let path = UIBezierPath()
                let spacing: CGFloat = 45
                let offset: CGFloat = 5
                var x = offset
                while x < size.width {
                    path.move(to: CGPoint(x: x, y: offset))
                    path.addLine(to: CGPoint(x: x, y: size.height - offset))
                    x += spacing
                }
                path.stroke()
                print("case .verticalLines")
            case .grid:
                tickColor.setStroke()
                let path = UIBezierPath()
                let spacing: CGFloat = 45
                let offset: CGFloat = 5
                var x = offset
                while x < size.width {
                    path.move(to: CGPoint(x: x, y: offset))
                    path.addLine(to: CGPoint(x: x, y: size.height - offset))
                    x += spacing
                }
                var y = offset
                while y < size.height {
                    path.move(to: CGPoint(x: offset, y: y))
                    path.addLine(to: CGPoint(x: size.width - offset, y: y))
                    y += spacing
                }
                path.stroke()
                print("case .grid")
            case .dots:
                tickColor.setFill()
                let spacing: CGFloat = 50
                let radius: CGFloat = 2
                var x = spacing / 2
                while x < size.width {
                    var y = spacing / 2
                    while y < size.height {
                        let dotRect = CGRect(x: x - radius, y: y - radius, width: radius * 2, height: radius * 2)
                        let dotPath = UIBezierPath(ovalIn: dotRect)
                        dotPath.fill()
                        y += spacing
                    }
                    x += spacing
                }
                print("case .dots")
            case .coordinate2D:
                // 绘制轴线
                axisColor.setStroke()
                let axisPath = UIBezierPath()
                axisPath.lineWidth = 2.0
                // 绘制X轴
                axisPath.move(to: CGPoint(x: 0, y: size.height / 2))
                axisPath.addLine(to: CGPoint(x: size.width, y: size.height / 2))
                // 绘制Y轴
                axisPath.move(to: CGPoint(x: size.width / 2, y: 0))
                axisPath.addLine(to: CGPoint(x: size.width / 2, y: size.height))
                axisPath.stroke()

                // 绘制刻度线
                tickColor.setStroke()
                let tickPath = UIBezierPath()
                tickPath.lineWidth = 1.0
                let tickSpacing: CGFloat = 45
                let tickLength: CGFloat = 5

                // X轴刻度
                var x = size.width / 2 + tickSpacing
                while x < size.width {
                    tickPath.move(to: CGPoint(x: x, y: size.height / 2 - tickLength))
                    tickPath.addLine(to: CGPoint(x: x, y: size.height / 2 + tickLength))
                    x += tickSpacing
                }
                x = size.width / 2 - tickSpacing
                while x > 0 {
                    tickPath.move(to: CGPoint(x: x, y: size.height / 2 - tickLength))
                    tickPath.addLine(to: CGPoint(x: x, y: size.height / 2 + tickLength))
                    x -= tickSpacing
                }

                // Y轴刻度
                var y = size.height / 2 + tickSpacing
                while y < size.height {
                    tickPath.move(to: CGPoint(x: size.width / 2 - tickLength, y: y))
                    tickPath.addLine(to: CGPoint(x: size.width / 2 + tickLength, y: y))
                    y += tickSpacing
                }
                y = size.height / 2 - tickSpacing
                while y > 0 {
                    tickPath.move(to: CGPoint(x: size.width / 2 - tickLength, y: y))
                    tickPath.addLine(to: CGPoint(x: size.width / 2 + tickLength, y: y))
                    y -= tickSpacing
                }

                tickPath.stroke()
                print("case .coordinate2D")
//            case .coordinate3D:
//                // 绘制轴线
//                axisColor.setStroke()
//                let axisPath = UIBezierPath()
//                axisPath.lineWidth = 2.0
//                // 绘制X轴
//                axisPath.move(to: CGPoint(x: 0, y: size.height / 2))
//                axisPath.addLine(to: CGPoint(x: size.width, y: size.height / 2))
//                // 绘制Y轴
//                axisPath.move(to: CGPoint(x: size.width / 2, y: 0))
//                axisPath.addLine(to: CGPoint(x: size.width / 2, y: size.height))
//                // 绘制Z轴
//                axisPath.move(to: CGPoint(x: size.width / 2, y: size.height / 2))
//                axisPath.addLine(to: CGPoint(x: size.width, y: 0))
//                axisPath.stroke()
//
//                // 绘制刻度线
//                tickColor.setStroke()
//                let tickPath = UIBezierPath()
//                tickPath.lineWidth = 1.0
//                let tickSpacing: CGFloat = 45
//                let tickLength: CGFloat = 5
//
//                // X轴刻度
//                var x = size.width / 2 + tickSpacing
//                while x < size.width {
//                    tickPath.move(to: CGPoint(x: x, y: size.height / 2 - tickLength))
//                    tickPath.addLine(to: CGPoint(x: x, y: size.height / 2 + tickLength))
//                    x += tickSpacing
//                }
//                x = size.width / 2 - tickSpacing
//                while x > 0 {
//                    tickPath.move(to: CGPoint(x: x, y: size.height / 2 - tickLength))
//                    tickPath.addLine(to: CGPoint(x: x, y: size.height / 2 + tickLength))
//                    x -= tickSpacing
//                }
//
//                // Y轴刻度
//                var y = size.height / 2 + tickSpacing
//                while y < size.height {
//                    tickPath.move(to: CGPoint(x: size.width / 2 - tickLength, y: y))
//                    tickPath.addLine(to: CGPoint(x: size.width / 2 + tickLength, y: y))
//                    y += tickSpacing
//                }
//                y = size.height / 2 - tickSpacing
//                while y > 0 {
//                    tickPath.move(to: CGPoint(x: size.width / 2 - tickLength, y: y))
//                    tickPath.addLine(to: CGPoint(x: size.width / 2 + tickLength, y: y))
//                    y -= tickSpacing
//                }
//
//                // Z轴刻度（简单示意）
//                var z = size.width / 2 + tickSpacing
//                while z < size.width {
//                    tickPath.move(to: CGPoint(x: z, y: 0))
//                    tickPath.addLine(to: CGPoint(x: z, y: tickLength))
//                    z += tickSpacing
//                }
//
//                tickPath.stroke()
//                print("case .coordinate3D")
            }
        }
    }
}
