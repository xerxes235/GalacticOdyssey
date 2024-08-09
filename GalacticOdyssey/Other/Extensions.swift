//
//  Extensions.swift
//  GalacticOdyssey
//
//  Created by Hamidreza Vakilian on 8/7/24.
//

import Foundation

extension CGPoint {
    static func random(maxX: CGFloat, maxY: CGFloat) -> CGPoint {
        let randomX = CGFloat.random(in: 0...maxX)
        let randomY = CGFloat.random(in: 0...maxY)
        return CGPoint(x: randomX, y: randomY)
    }
}
