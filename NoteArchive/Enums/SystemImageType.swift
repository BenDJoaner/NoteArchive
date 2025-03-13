//
//  SystemImageType.swift
//  NoteArchive
//
//  Created by BC on 2025/3/12.
//

import SwiftUI

// 定义 SystemImageType 枚举
enum SystemImageType: String, CaseIterable {
    case heartdoc = "heart.text.clipboard.fill"
    case chartdoc = "chart.line.text.clipboard.fill"
    case checkdoc = "checkmark.seal.text.page.fill"
    case badgeclock = "app.badge.clock.fill"
    case capsuleOnRectangle = "capsule.on.rectangle.fill"
    case textBubbleBadgeClock = "text.bubble.badge.clock.fill"
    case envelopeFront = "envelope.front.fill"
    case appleImagePlayground = "apple.image.playground.fill"
    case cartBadgeClock = "cart.badge.clock.fill"
    case walletBifold = "wallet.bifold.fill"
    case powerplugPortrait = "powerplug.portrait.fill"
    case drone = "drone.fill"
    case motorcycle = "motorcycle.fill"
    case suvSideRoofCargoCarrier = "suv.side.roof.cargo.carrier.fill"
    case convertibleSide = "convertible.side.fill"
    case keyCard = "key.card.fill"
    case hatWidebrim = "hat.widebrim.fill"
    case coat = "coat.fill"
    case xmarkTriangleCircleSquare = "xmark.triangle.circle.square.fill"
    case handPalmFacing = "hand.palm.facing.fill"
    case photoOnRectangleAngled = "photo.on.rectangle.angled.fill"
    case formfittingGamecontroller = "formfitting.gamecontroller.fill"
    case cupAndHeatWaves = "cup.and.heat.waves.fill"
    case checkmarkBubble = "checkmark.bubble.fill"
    case exclamationmarkBubble = "exclamationmark.bubble.fill"
    case quoteBubble = "quote.bubble.fill"
    case starBubble = "star.bubble.fill"
    case characterBubble = "character.bubble.fill"
    case textBubble = "text.bubble.fill"
    case infoBubble = "info.bubble.fill"
    case questionmarkBubble = "questionmark.bubble.fill"
    case plusBubble = "plus.bubble.fill"
    case rectangle3GroupBubble = "rectangle.3.group.bubble.fill"
    case ellipsisBubble = "ellipsis.bubble.fill"
    case personBubble = "person.bubble.fill"
    case flagPatternCheckered2Crossed = "flag.pattern.checkered.2.crossed"
    case house = "house.fill"
    
    var description: String {
        switch self {
        case .heartdoc:
            return "Heart"
        case .chartdoc:
            return "Chart"
        case .checkdoc:
            return "Check"
        case .badgeclock:
            return "Badge"
        case .capsuleOnRectangle:
            return "Capsule"
        case .textBubbleBadgeClock:
            return "Text"
        case .envelopeFront:
            return "Envelope"
        case .appleImagePlayground:
            return "Apple"
        case .cartBadgeClock:
            return "Cart"
        case .walletBifold:
            return "Wallet"
        case .powerplugPortrait:
            return "Plug"
        case .drone:
            return "Drone"
        case .motorcycle:
            return "Motorcycle"
        case .suvSideRoofCargoCarrier:
            return "SUV"
        case .convertibleSide:
            return "Convertible"
        case .keyCard:
            return "Key"
        case .hatWidebrim:
            return "Hat"
        case .coat:
            return "Coat"
        case .xmarkTriangleCircleSquare:
            return "Xmark"
        case .handPalmFacing:
            return "Hand"
        case .photoOnRectangleAngled:
            return "Photo"
        case .formfittingGamecontroller:
            return "Controller"
        case .cupAndHeatWaves:
            return "Cup"
        case .checkmarkBubble:
            return "Checkmark"
        case .exclamationmarkBubble:
            return "Exclamation"
        case .quoteBubble:
            return "Quote"
        case .starBubble:
            return "Star"
        case .characterBubble:
            return "Character"
        case .textBubble:
            return "Text"
        case .infoBubble:
            return "Info"
        case .questionmarkBubble:
            return "Question"
        case .plusBubble:
            return "Plus"
        case .rectangle3GroupBubble:
            return "Rectangle"
        case .ellipsisBubble:
            return "Ellipsis"
        case .personBubble:
            return "Person"
        case .flagPatternCheckered2Crossed:
            return "Flag"
        case .house:
            return "House"
        }
    }
}
