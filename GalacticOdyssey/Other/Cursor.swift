//
//  Cursor.swift
//  GalacticOdyssey
//
//  Created by Hamidreza Vakilian on 8/7/24.
//

import Foundation
import UIKit

class Cursor: CAShapeLayer {

    // reference to the original Cursor layer. If the class is the original layer itself, it points to itself.
    private weak var originalLayer: Cursor?

    // we need to keep the previous and the value before the previous one
    private var rotationTangentPreviousValues: (CGPoint, CGPoint)?

    // current point being traversed on the motion path, we use this to compute the vector angle,
    //  making the cursor tangent to its trajectory.
    @NSManaged var rotationTangentCurrentPoint: CGPoint

    // we break the transform into its crucial elements translation, scale and rotation. (rotation is computed from rotationTangentCurrentPoint)
    //  this allows us to have separate logics for animating rotation/translation and scale of the cursor.
    //  in draw(in:) we combine these properties to form the final transform.
    @NSManaged var translation: CGPoint
    @NSManaged var scale: CGSize

    override init() {
        super.init()

        scale = .init(width: 1, height: 1)
        translation = .zero
        self.originalLayer = self
    }

    // in animation context the layer is copied with this initializer. We need to keep a reference to the original
    // layer so we can apply the transform on it.
    override init(layer: Any) {
        super.init(layer: layer)

        if let layer = layer as? Cursor {
            // for convienice we copy the values we need on the new instance. so we can access them directly.
            self.rotationTangentCurrentPoint = layer.rotationTangentCurrentPoint
            self.rotationTangentPreviousValues = layer.rotationTangentPreviousValues
            self.translation = layer.translation
            self.scale = layer.scale
            self.originalLayer = layer
        }
    }


    override class func needsDisplay(forKey key: String) -> Bool {
        if key == "rotationTangentCurrentPoint" {
            return true
        } else if key == "translation" {
            return true
        } else if key == "scale" {
            return true
        }
        return super.needsDisplay(forKey: key)
    }

    override func draw(in ctx: CGContext) {

        // the finalTransform is a combination of the given translation and scale.
        //  Note: the order of concatenating transforms matters significantly.
        var finalTransform = CATransform3DMakeAffineTransform(.init(translationX: translation.x, y: translation.y).scaledBy(x: scale.width, y: scale.height))

        // we need at least two distinct points to compute the tangent vector.
        if let rotationTangentPreviousValues {

            let vector: CGPoint

            if rotationTangentCurrentPoint.equalTo(rotationTangentPreviousValues.0) {
                // if the new point is equal to the previous one, we should preserve the previous tangent angle, thats why we need previous and the value before the previous point. so we calculate the tangent vector from the previous point to the value before the previous point.
                vector = CGPoint(x: rotationTangentPreviousValues.0.x - rotationTangentPreviousValues.1.x, y: rotationTangentPreviousValues.0.y - rotationTangentPreviousValues.1.y)
            } else {
                // the new point is a distinct one.
                vector = CGPoint(x: rotationTangentCurrentPoint.x - rotationTangentPreviousValues.0.x, y: rotationTangentCurrentPoint.y - rotationTangentPreviousValues.0.y)
            }

            // calculate the tangent angle
            var k: CGFloat = abs(atan2(vector.y, vector.x))

            // fix the tangent angle direction
            if (vector.y < 0) {
                k = k * -1
            }

            // modify the finalTransform by applying the rotation on it.
            finalTransform = CATransform3DRotate(finalTransform, k, 0, 0, 1)

        }

        // disable implicit CALayer animations
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        self.originalLayer?.transform = finalTransform
        CATransaction.commit()

        // keep track of previous values.
        self.originalLayer?.rotationTangentPreviousValues = (rotationTangentCurrentPoint, self.originalLayer?.rotationTangentPreviousValues?.0 ?? .zero)
    }


    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
