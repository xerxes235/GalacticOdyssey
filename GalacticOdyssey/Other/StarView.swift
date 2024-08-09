//
//  StarView.swift
//  GalacticOdyssey
//
//  Created by Hamidreza Vakilian on 8/7/24.
//

import Foundation
import UIKit

class StarView: UIView {

    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    // instruct the View to instantiate a CAShapeLayer for its layer (instead of CALayer)
    override class var layerClass: AnyClass { CAShapeLayer.self }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    init(scale: CGFloat, color: UIColor) {
        super.init(frame: .zero)

        // always true
        if let shapeLayer = self.layer as? CAShapeLayer {

            shapeLayer.path = MyPaths.star.cgPath
            shapeLayer.fillColor = color.cgColor
            shapeLayer.shadowColor = shapeLayer.fillColor
            shapeLayer.shadowOffset = .zero
            shapeLayer.shadowRadius = 5 * scale
            shapeLayer.shadowOpacity = 1
            shapeLayer.bounds = .init(origin: .zero, size: .init(width: 10, height: 10))

            let transformAnim = CABasicAnimation(keyPath: "transform")
            transformAnim.fromValue = CATransform3DMakeScale(scale, scale, 1)
            transformAnim.toValue = CATransform3DMakeScale(scale * 2, scale * 2, 1)
            transformAnim.duration = CGFloat.random(in: 0.5...3)
            transformAnim.repeatCount = .infinity
            transformAnim.autoreverses = true
            shapeLayer.add(transformAnim, forKey: "pulse")

            let blinkAnimation = CABasicAnimation(keyPath: "opacity")
            blinkAnimation.fromValue = 1
            blinkAnimation.toValue = CGFloat.random(in: 0.2...0.9)
            blinkAnimation.duration = CGFloat.random(in: 0.5...1.5)
            blinkAnimation.repeatCount = .infinity
            blinkAnimation.autoreverses = true
            shapeLayer.add(blinkAnimation, forKey: "blink")
        }
    }

}
