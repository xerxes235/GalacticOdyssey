//
//  Mappable.swift
//  HyperTunnel
//
//  Created by Hamidreza Vakilian on 6/9/24.
//

import Foundation

protocol LinearInterpolation {
    static func lerp(_ value: Self, srcLow: Self, srcHigh: Self, dstLow: Self, dstHigh: Self) -> Self
    func lerp(srcLow: Self, srcHigh: Self, dstLow: Self, dstHigh: Self) -> Self
}

extension LinearInterpolation where Self: FloatingPoint {
    static func lerp(_ value: Self, srcLow: Self, srcHigh: Self, dstLow: Self, dstHigh: Self) -> Self {
        let negate = dstLow > dstHigh
        let low2 = negate ? -dstLow : dstLow
        let high2 = negate ? -dstHigh : dstHigh
        let result = low2 + (value - srcLow) * (high2 - low2) / (srcHigh - srcLow)
        return (negate ? -1 : 1) * min(max(result, low2), high2)
    }
    func lerp(srcLow: Self, srcHigh: Self, dstLow: Self, dstHigh: Self) -> Self {
        return Self.lerp(self, srcLow: srcLow, srcHigh: srcHigh, dstLow: dstLow, dstHigh: dstHigh)
    }
}

extension Double: LinearInterpolation {}
extension CGFloat: LinearInterpolation {}
extension Float: LinearInterpolation {}
