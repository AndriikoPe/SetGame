//
//  SetGame.swift
//  Set
//
//  Created by Пермяков Андрей on 24.06.2021.
//

import Foundation

struct SetGame {
    private(set) var deck: [Card]
    private(set) var cardsInGame: [Card]
    private(set) var discarded: [Card]
    
    var selectedCardsIndicies: [Int] {
        cardsInGame.indices.filter { cardsInGame[$0].isSelected }
    }
    
    init(startingNumberOfCards: Int = 12) {
        deck = [Card]()
        cardsInGame = [Card]()
        discarded = [Card]()
        createDeck()
        deal(12)
    }
    
    mutating func choose(_ card: Card) {
        guard let chosenIndex = cardsInGame.firstIndex(where: { $0.id == card.id }) else { return }
        let indicies = selectedCardsIndicies
        cardsInGame[chosenIndex].isCheatHighlighted = false
        if indicies.count < 3 {
            cardsInGame[chosenIndex].isSelected.toggle()
        } else if areSelectedCardsSet() { // 3 cards, set
            removeSetCards(at: chosenIndex, indicies)
        } else {                          // 3 cards, not set
            for index in cardsInGame.indices {
                cardsInGame[index].isSelected = false
            }
            cardsInGame[chosenIndex].isSelected = true
        }
    }
    
    // MARK: - Cheat button extra credit
    
    mutating func cheat() {
        for outerI in 0 ..< (cardsInGame.count - 1) {
            for innerI in (outerI + 1) ..< cardsInGame.count {
                var sameOrDiff = [Triple?]()
                let symb1 = cardsInGame[outerI].shape,
                symb2 = cardsInGame[innerI].shape,
                num1 =  Triple(rawValue: cardsInGame[innerI].number)!,
                num2 = Triple(rawValue: cardsInGame[outerI].number)!,
                color1 = cardsInGame[innerI].color,
                color2 = cardsInGame[outerI].color,
                style1 = cardsInGame[innerI].style,
                style2 = cardsInGame[outerI].style
                
                sameOrDiff.append(findTheThird(in: [symb1, symb2]))
                sameOrDiff.append(findTheThird(in: [num1, num2]))
                sameOrDiff.append(findTheThird(in: [color1, color2]))
                sameOrDiff.append(findTheThird(in: [style1, style2]))
                for index in cardsInGame.indices {
                    let card = cardsInGame[index]
                    if card.shape == sameOrDiff[0] &&
                        card.number == sameOrDiff[1]?.rawValue &&
                        card.color == sameOrDiff[2] &&
                        card.style == sameOrDiff[3] {
                            highlight(at: [outerI, innerI, index])
                            return
                    }
                }
            }
        }
    }
    
    private mutating func highlight(at indicies: [Int]) {
        for index in indicies {
            cardsInGame[index].isCheatHighlighted = true
        }
    }
    
    private func findTheThird(in arr: [Triple]) -> Triple? {
        guard arr.count == 2 else { return nil }
        if arr[0] == arr[1] {
            return arr[0]
        }
        for number in Triple.allCases {
            if number != arr[0] && number != arr[1] {
                return number
            }
        }
        return nil
    }
    
    private mutating func removeSetCards(at chosenIndex: Int, _ indicies: [Int]) {
        if !selectedCardsIndicies.contains(chosenIndex) {
            cardsInGame[chosenIndex].isSelected = true
        }
        var indiciesToRemove = [Int]()
        for index in indicies {
            cardsInGame[index].isSelected = false
            discarded.append(cardsInGame[index])
            indiciesToRemove.append(index)
        }
        cardsInGame.remove(atOffsets: IndexSet(indiciesToRemove))
    }
    
    func areSelectedCardsSet() -> Bool {
        areCardsSet(cardsInGame.filter({ $0.isSelected }))
    }
    
    private func areCardsSet(_ arr: [Card]) -> Bool {
        guard arr.count == 3 else { return false }
        var symbols = [Triple](), numbers = [Int](), colors = [Triple](), styles = [Triple]()
        for index in arr.indices {
            symbols.append(arr[index].shape)
            colors.append(arr[index].color)
            numbers.append(arr[index].number)
            styles.append(arr[index].style)
        }
        let symbolsSet = symbols.all3Same || symbols.all3Different
        let colorsSet = colors.all3Same || colors.all3Different
        let numbersSet = numbers.all3Same || numbers.all3Different
        let shadesSet = styles.all3Same || styles.all3Different
        return symbolsSet && colorsSet && numbersSet && shadesSet
    }
    
    mutating func deal(_ number: Int = 3) {
        if areSelectedCardsSet() {
            for index in selectedCardsIndicies {
                cardsInGame[index].isSelected = false
                discarded.append(cardsInGame[index])
                if deck.count > 0 {
                    cardsInGame[index] = deck.popLast()!
                }
            }
        } else {
            for _ in 0..<number {
                if deck.count > 0 {
                    cardsInGame.append(deck.popLast()!)
                }
            }
        }
        
    }
    
    private mutating func createDeck() {
        var counter = 0
        for shape in Triple.allCases {
            for style in Triple.allCases {
                for number in 1...3 {
                    for color in Triple.allCases {
                        deck.append(Card(shape: shape, style: style, number: number, color: color, id: counter))
                        counter += 1
                    }
                }
            }
        }
        deck.shuffle()
    }
    
    struct Card: Identifiable, Equatable {
        let shape: Triple
        let style: Triple
        let number: Int
        let color: Triple
        let id: Int
        var isSelected = false
        var isCheatHighlighted = false
    }
}

enum Triple: Int, CaseIterable {
    case first = 1
    case second = 2
    case third = 3
}

extension Array where Element: Equatable {
    var all3Same: Bool {
        count == 3 && first == self[2] && last == self[2]
    }
    
    var all3Different: Bool {
        count == 3 && first != self[1] && self[1] != last && first != last
    }
}
