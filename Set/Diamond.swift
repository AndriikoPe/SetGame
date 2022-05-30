//
//  Diamond.swift
//  Set
//
//  Created by Пермяков Андрей on 24.06.2021.
//

import SwiftUI

struct Diamond: Shape {
    var aspectRatio: CGFloat
    
    func path(in rect: CGRect) -> Path {
        let halfWidth = rect.width / 2.0
        let halfHeight = halfWidth / aspectRatio
        let center = CGPoint(x: rect.midX, y: rect.midY)
        var p = Path()
        p.move(to: CGPoint(x: center.x, y: center.y - halfHeight))
        p.addLine(to: CGPoint(x: center.x - halfWidth, y: center.y))
        p.addLine(to: CGPoint(x: center.x, y: center.y + halfHeight))
        p.addLine(to: CGPoint(x: center.x + halfWidth, y: center.y))
        p.addLine(to: CGPoint(x: center.x, y: center.y - halfHeight))
        return p
    }
}
