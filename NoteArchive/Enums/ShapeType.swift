//
//  ShapeType.swift
//  NoteArchive
//
//  Created by BC on 2025/3/13.
//

import SwiftUICore

enum ShapeType: String, CaseIterable {
    case rounded = "Rounded"
    case capsule = "Capsule"
    case ellipse = "Ellipse"
    
    var ShapeType: AnyShape {
        switch self {
        case .rounded:
                .init(.rect(cornerRadius: 10))
        case .capsule:
                .init(.capsule)
        case .ellipse:
                .init(.ellipse)
        }
    }
}
