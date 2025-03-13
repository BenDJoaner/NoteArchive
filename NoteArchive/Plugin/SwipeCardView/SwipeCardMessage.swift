//
//  Message.swift
//  iMessageCardSwipe1213
//
//  Created by Lurich on 2022/12/13.
//

import SwiftUI

struct SwipeCardMessage: Identifiable, Equatable {
    var id: String = UUID().uuidString
//    var imageFile: String
    var pageData: DrawingPage
}

