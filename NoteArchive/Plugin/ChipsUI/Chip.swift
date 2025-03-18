//
//  Chip.swift
//  ChipsUI
//
//  Created by Xiaofu666 on 2024/9/22.
//

import SwiftUI

struct Chip: Identifiable {
    var id: String = UUID().uuidString
    var name: String
}

var mockChips: [Chip] = [
    .init(name: "电脑"),
    .init(name: "Deepseek"),
    .init(name: "宇宙"),
]


