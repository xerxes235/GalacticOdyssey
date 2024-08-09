//
//  Clamp.swift
//  GalacticOdyssey
//
//  Created by Hamidreza Vakilian on 8/7/24.
//

import Foundation

protocol Clamp {
    static func clamp(_ value: Self, minValue: Self, maxValue: Self) -> Self
    func clamp(minValue: Self, maxValue: Self) -> Self
}

extension Clamp where Self: Comparable {
    static func clamp(_ value: Self, minValue: Self, maxValue: Self) -> Self {
        return min(max(value, minValue), maxValue)
    }

    func clamp(minValue: Self, maxValue: Self) -> Self {
        return Self.clamp(self, minValue: minValue, maxValue: maxValue)
    }
}

// Conforming various types to the Clamp protocol
extension Double: Clamp {}
extension CGFloat: Clamp {}
extension Float: Clamp {}
extension Int: Clamp {}
extension Int8: Clamp {}
extension Int16: Clamp {}
extension Int32: Clamp {}
extension Int64: Clamp {}
extension UInt: Clamp {}
extension UInt8: Clamp {}
extension UInt16: Clamp {}
extension UInt32: Clamp {}
extension UInt64: Clamp {}
