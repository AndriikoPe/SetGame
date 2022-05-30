//
//  ContentView.swift
//  Set
//
//  Created by Пермяков Андрей on 24.06.2021.
//

import SwiftUI

struct SetGameView: View {
    static let symbolAspectRatio: CGFloat = 2.0
    
    @ObservedObject var game = ClassicSetGame()
    
    @Namespace private var dealingNamespace
    
    var body: some View {
        VStack {
            gameBody
            HStack {
                deckBody
                Spacer()
                discardPile
            }
            actions
        }
    }
    
    @ViewBuilder
    var gameBody: some View {
        let selectedSet = game.areSelectedCardsSet()
        if game.cardsInGame.count <= 30 {
            AspectVGrid(items: game.cardsInGame.filter( { !isUndealt($0) } ),
                        aspectRatio: DrawingConstants.aspectRatio) { card in
                draw(card: card, isFaceUp: true, selectedSet: selectedSet)
                    .matchedGeometryEffect(id: card.id, in: dealingNamespace)
                    .onTapGesture {
                        withAnimation {
                            game.choose(card)
                        }
                    }
            }
        } else {
            ScrollView {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 65.0))]) {
                    ForEach(game.cardsInGame.filter( { !isUndealt($0) } )) { card in
                        draw(card: card, isFaceUp: true, selectedSet: selectedSet)
                            .aspectRatio(DrawingConstants.aspectRatio, contentMode: .fit)
                            .matchedGeometryEffect(id: card.id, in: dealingNamespace)
                            .onTapGesture {
                                withAnimation {
                                    game.choose(card)
                                }
                            }
                    }
                }
            }
        }
    }
    
    var actions: some View {
        HStack {
            Button("Restart") {
                withAnimation {
                    dealt = []
                    game.newGame()
                    dealAllCards()
                }
            }
            .disabled(game.deck.isEmpty)
            Spacer(minLength: 0.0)
            Button("Cheat") {
                game.cheat()
            }
        }
        .padding()
    }
    
    @State private var dealt = Set<Int>()
    
    private static var deckSlopiness = [Int:Angle]()
    private static var discardPileSlopiness = [Int:(Angle, CGFloat, CGFloat)]()
    
    private func deal(_ card: ClassicSetGame.Card) {
        dealt.insert(card.id)
    }
    
    private func isUndealt(_ card: ClassicSetGame.Card) -> Bool {
        !dealt.contains(card.id)
    }
    
    private func zIndex(of card: ClassicSetGame.Card) -> Double {
        -Double(game.deck.firstIndex(where: { $0.id == card.id }) ?? 0)
    }
    
    private func dealAnimation(for card: ClassicSetGame.Card) -> Animation {
        var animationDelay = 0.0
        if let index = game.cardsInGame.firstIndex(where: { $0.id == card.id }) {
            animationDelay = Double(index) * DrawingConstants.dealDuration / DrawingConstants.initialDealDuration
        }
        return Animation.easeInOut(duration: DrawingConstants.dealDuration).delay(animationDelay)
    }
    
    var deckBody: some View {
        ZStack {
            let deck = game.deck.filter(isUndealt) + game.cardsInGame.filter(isUndealt)
            if deck.isEmpty {
                Text("Empty")
                    .frame(width: DrawingConstants.deckWidth, height: DrawingConstants.deckHeight)
            } else {
                ForEach(deck) { card in
                    draw(card: card, isFaceUp: false)
                        .matchedGeometryEffect(id: card.id, in: dealingNamespace)
                        .frame(width: DrawingConstants.deckWidth, height: DrawingConstants.deckHeight)
                        .zIndex(zIndex(of: card))
                        .rotationEffect(
                            getDeckRotation(for: card.id)
                        )
                }
                Text("\(deck.count)")
            }
        }
        .padding()
        .onTapGesture {
            withAnimation {
                game.deal3More()
                deal3Cards()
            }
        }
        .onAppear {
            dealAllCards()
        }
    }
    
    private func getDeckRotation(for id: Int) -> Angle {
        if SetGameView.deckSlopiness[id] == nil {
            
            SetGameView.deckSlopiness[id] = Angle.degrees(90 + Double.random(
                                                in: -DrawingConstants.deckSloppinessMaxDegree...DrawingConstants.deckSloppinessMaxDegree))
        }
        return SetGameView.deckSlopiness[id]!
    }
    
    private func deal3Cards() {
        var delay = 0.0
        for card in game.cardsInGame {
            if isUndealt(card) {
                withAnimation(Animation.easeInOut(duration: DrawingConstants.dealDuration).delay(delay)) {
                    deal(card)
                    delay += DrawingConstants.deal3CardsDuration / 3.0
                }
            }
        }
    }
    
    private func dealAllCards() {
        for card in game.cardsInGame {
            if isUndealt(card) {
                withAnimation(dealAnimation(for: card)) {
                    deal(card)
                }
            }
        }
    }
    
    var discardPile: some View {
        ZStack {
            if game.discarded.isEmpty {
                Text("Empty")
                    .frame(width: DrawingConstants.deckWidth, height: DrawingConstants.deckHeight)
            } else {
                ForEach(game.discarded) { card in
                    let slopiness = getDiscardPileRotationAndOffset(for: card.id)
                    draw(card: card, isFaceUp: true)
                        .matchedGeometryEffect(id: card.id, in: dealingNamespace)
                        .frame(width: DrawingConstants.deckWidth, height: DrawingConstants.deckHeight)
                        .zIndex(zIndex(of: card))
                        .rotationEffect(slopiness.0)
                        .offset(x: slopiness.1, y: slopiness.2)
                }
                .padding()
            }
        }
    }
    
    private func getDiscardPileRotationAndOffset(for id: Int) -> (Angle, CGFloat, CGFloat) {
        if SetGameView.discardPileSlopiness[id] == nil {
            SetGameView.discardPileSlopiness[id] = (
                Angle.degrees(90 + Double.random(in: -DrawingConstants.discardPileSloppinessMaxDegree...DrawingConstants.discardPileSloppinessMaxDegree)),
                CGFloat.random(in: -DrawingConstants.discardPileMaxOffset...DrawingConstants.discardPileMaxOffset),
                CGFloat.random(in: -DrawingConstants.discardPileMaxOffset...DrawingConstants.discardPileMaxOffset)
            )
        }
        return SetGameView.discardPileSlopiness[id]!
    }
    
    @ViewBuilder
    private func draw(card: ClassicSetGame.Card, isFaceUp: Bool, selectedSet: Bool = false) -> some View {
        PictureView(card: card)
            .border(borderColor(for: card, selectedSet), width: DrawingConstants.chooseCardOutlineWidth)
            .cardify(isFaceUp: isFaceUp)
            .padding(2.0)
    }
    
    private func borderColor(for card: ClassicSetGame.Card, _ selectedSet: Bool) -> Color {
        if card.isSelected {
            return selectedSet ? Color.yellow : (game.selectedCardsCount == 3 ? Color.red : Color.secondary)
        } else {
            return card.isCheatHighlighted ? .green : .clear
        }
    }
    
    // MARK: - Drawing constants.
    
    private struct DrawingConstants {
        static let cardBackColor: Color = .red
        static let chooseCardOutlineWidth: CGFloat = 2.0
        static let cardCornerRadius: CGFloat = 15
        static let aspectRatio: CGFloat = 5.0 / 8.0
        static let deckHeight: CGFloat = 90
        static let deckWidth: CGFloat = deckHeight * aspectRatio
        static let dealDuration: Double = 0.7
        static let deal3CardsDuration: Double = 0.6
        static let initialDealDuration: Double = 4.0
        static let deckSloppinessMaxDegree: Double = 4.5
        static let discardPileSloppinessMaxDegree: Double = 30.0
        static let discardPileMaxOffset: CGFloat = 25.0
    }
}

extension Shape {
    @ViewBuilder
    func modified(with style: Triple) -> some View {
        switch style {
        case .first:
            self.stroke(lineWidth: 3.0)
        case .second:
            ZStack {
                self.fill().opacity(0.2)
                self.stroke(lineWidth: 3.0)
            }
        case .third:
            self.fill()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        SetGameView()
    }
}
