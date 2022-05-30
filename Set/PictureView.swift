//
//  PictureView.swift
//  Set
//
//  Created by Пермяков Андрей on 26.06.2021.
//

import SwiftUI

struct PictureView: View {
    let card: ClassicSetGame.Card
    
    var body: some View {
        picture(for: card)
    }
    
    @ViewBuilder
    private func picture(for pattern: ClassicSetGame.Card) -> some View {
        let color = getColor(for: pattern)
        VStack {
            switch pattern.number {
            case 1:
                Spacer(minLength: 0)
                symbol(for: pattern)
                Spacer(minLength: 0)
            case 2:
                Spacer(minLength: 0)
                symbol(for: pattern)
                Spacer(minLength: 0)
                symbol(for: pattern)
                Spacer(minLength: 0)
            case 3:
                Spacer(minLength: 0)
                symbol(for: pattern)
                Spacer(minLength: 0)
                symbol(for: pattern)
                Spacer(minLength: 0)
                symbol(for: pattern)
                Spacer(minLength: 0)
            default:
                EmptyView()
            }
        }
        .foregroundColor(color)
        .padding()
    }
    
    @ViewBuilder
    private func symbol(for pattern: ClassicSetGame.Card) -> some View {
        switch pattern.shape {
        case .first:
            Diamond(aspectRatio: SetGameView.symbolAspectRatio)
                .modified(with: pattern.style)
        case .second:
            Rectangle()
                .modified(with: pattern.style)
                .aspectRatio(2.0, contentMode: .fit)
                .scaleEffect(0.9)
        case .third:
            RoundedRectangle(cornerRadius: 25.0)
                .modified(with: pattern.style)
                .aspectRatio(2.0, contentMode: .fit)
                .scaleEffect(0.9)
        }
    }
    
    private func getColor(for pattern: ClassicSetGame.Card) -> Color {
        switch pattern.color {
        case .first:
            return .red
        case .second:
            return .green
        case .third:
            return .blue
        }
    }
}

//struct CardView_Previews: PreviewProvider {
//    static var previews: some View {
//        PictureView()
//    }
//}
