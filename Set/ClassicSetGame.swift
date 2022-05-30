//
//  ClassicSetGame.swift
//  Set
//
//  Created by Пермяков Андрей on 25.06.2021.
//

import SwiftUI

class ClassicSetGame: ObservableObject {
    typealias Card = SetGame.Card
    @Published var model = SetGame()
    
    func cheat() {
        model.cheat()
    }
    
    func newGame() {
        model = SetGame()
    }
    
    var deck: [Card] {
        model.deck
    }
    
    var discarded: [Card] {
        model.discarded
    }
    
    var selectedCardsCount: Int {
        model.selectedCardsIndicies.count
    }
    
    func deal3More() {
        model.deal()
    }
    
    func areSelectedCardsSet() -> Bool {
        model.areSelectedCardsSet()
    }
    
    func choose(_ card: Card) {
        model.choose(card)
    }
    
    var cardsInGame: [Card] {
        model.cardsInGame
    }
}
