//
//  Cardify.swift
//  Set
//
//  Created by Пермяков Андрей on 26.08.2021.
//

import SwiftUI

struct Cardify: AnimatableModifier {
    var animatableData: Double {
        get { rotation }
        set { rotation = newValue }
    }
    
    private var rotation: Double

    init(isFaceUp: Bool) {
        rotation = isFaceUp ? 0 : 180
    }

    func body(content: Content) -> some View {
        Group {
            if rotation < 90 {
                ZStack {
                    RoundedRectangle(cornerRadius: DrawingConstants.cardCornerRadius)
                        .foregroundColor(DrawingConstants.cardFaceColor)
                        .overlay(
                            RoundedRectangle(cornerRadius: DrawingConstants.cardCornerRadius)
                                .stroke(DrawingConstants.cardFaceBorderColor, lineWidth: DrawingConstants.cardFaceBorderWidth)
                        )
                    content
                }
            } else {
                RoundedRectangle(cornerRadius: DrawingConstants.cardCornerRadius)
                    .foregroundColor(DrawingConstants.cardBackColor)
                    .overlay(
                        RoundedRectangle(cornerRadius: DrawingConstants.cardCornerRadius)
                            .stroke(DrawingConstants.cardBackBorderColor, lineWidth: DrawingConstants.cardBackBorderWidth)
                    )
                    .rotationEffect(Angle.degrees(rotation / 2.0))
            }
        }
        .rotation3DEffect(Angle.degrees(rotation), axis: (1, 1, 0))
    }
    
    // MARK: - Drawing constants.
    
    private struct DrawingConstants {
        static let cardBackColor: Color = .red
        static let cardFaceColor: Color = .white
        static let cardCornerRadius: CGFloat = 15
        static let cardBackBorderColor: Color = .gray
        static let cardFaceBorderColor: Color = .gray
        static let cardBackBorderWidth: CGFloat = 1.0
        static let cardFaceBorderWidth: CGFloat = 0.5
    }
}

extension View {
    func cardify(isFaceUp: Bool) -> some View {
        self.modifier(Cardify(isFaceUp: isFaceUp))
    }
}
