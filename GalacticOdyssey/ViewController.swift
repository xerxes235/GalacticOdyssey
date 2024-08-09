//
//  ViewController.swift
//  GalacticOdyssey
//
//  Created by Hamidreza Vakilian on 8/5/24.
//

import UIKit

class ViewController: UIViewController {

    private lazy var scrollView: UIScrollView = {
        let result = UIScrollView()
        result.contentInsetAdjustmentBehavior = .never
        result.isPagingEnabled = true
        result.translatesAutoresizingMaskIntoConstraints = false
        result.showsHorizontalScrollIndicator = false
        result.showsVerticalScrollIndicator = false
        return result
    }()

    private lazy var scrollViewContentView: UIView = {
        let result = UIView()
        result.translatesAutoresizingMaskIntoConstraints = false
        return result
    }()

    private let cursor = Cursor()
    private let road = CAShapeLayer()

    private lazy var label1: UILabel = {
        return createLabel(text: "Our Galactic Odyssey begins! Watch as the circle expands, marking the start of our stellar journey.")
    }()

    private lazy var label2: UILabel = {
        return createLabel(text: "Get ready for a transformation! The circle morphs into a sleek rocket, ready for an adventure.")
    }()

    private lazy var label3: UILabel = {
        return createLabel(text: "Prepare for some stellar moves! The rocket aligns with its path, gracefully weaving through the intricate maze.")
    }()

    private lazy var label4: UILabel = {
        return createLabel(text: "Our epic journey comes to an end! The rocket ascends to infinity and beyond. Thank you for embarking on this Galactic Odyssey with us!", alignment: .left, fontSize: 20)
    }()

    private var galaxy: UIView = {
        let result = UIView()
        result.translatesAutoresizingMaskIntoConstraints = false
        return result
    }()

    private var scene: UIView = {
        let result = UIView()
        result.translatesAutoresizingMaskIntoConstraints = false
        return result
    }()

    var segments: [UIBezierPath] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.

        // layout the views
        //  galaxy on the background
        layout()
        setupStars()

        let segment1 = MyPaths.createSegment1()
        let segment2 = MyPaths.createSegment2(applying: .init(translationX: segment1.bounds.width, y: 0))
        let segment3 = MyPaths.createSegment3(applying: .init(translationX: segment1.bounds.width + segment2.bounds.width, y: 0))

        segments.append(contentsOf: [segment1, segment2, segment3])

        let aggregate_path = segment1.copy() as! UIBezierPath
        aggregate_path.append(segment2)
        aggregate_path.append(segment3)

        setupRoad(path: aggregate_path)

        setupCursor()

        setupLabels()

        updateState(0)

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(appWillEnterForeground),
            name: UIApplication.willEnterForegroundNotification,
            object: nil)
    }

    @objc func appWillEnterForeground() {
        setupAnimations()
    }

    override var prefersHomeIndicatorAutoHidden: Bool {
        return true
    }

    private func setupAnimations() {
        setupRoadAnimation()
    }
}

// MARK: Constants
extension ViewController {
    struct Const {
        static let segments: Int = 3
        static let segmentBounds: CGSize = .init(width: 400, height: 400)
        static let pages: Int = 5
        static let GalaxyToScreenScale: CGFloat = 1.1
    }
}

// MARK: UIScrollViewDelegate
extension ViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let progress = scrollView.contentOffset.x / (scrollView.contentSize.width - scrollView.bounds.width)

        let progress_clamped = progress.clamp(minValue: 0, maxValue: 1)
        updateState(progress_clamped)
    }
}

// MARK: Layout
extension ViewController {
    private func layout() {
        scrollView.delegate = self
        view.addSubview(scene)
        scene.addSubview(galaxy)
        view.addSubview(scrollView)
        scrollView.addSubview(scrollViewContentView)

        NSLayoutConstraint.activate([
            scene.topAnchor.constraint(equalTo: view.topAnchor),
            scene.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scene.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scene.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            galaxy.centerXAnchor.constraint(equalTo: scene.centerXAnchor),
            galaxy.centerYAnchor.constraint(equalTo: scene.centerYAnchor),
            galaxy.widthAnchor.constraint(equalTo: scene.widthAnchor, multiplier: Const.GalaxyToScreenScale),
            galaxy.heightAnchor.constraint(equalTo: scene.heightAnchor),

            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            scrollViewContentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            scrollViewContentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            scrollViewContentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            scrollViewContentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            scrollViewContentView.heightAnchor.constraint(equalTo: scrollView.heightAnchor),
            scrollViewContentView.widthAnchor.constraint(equalToConstant: CGFloat(Const.pages) * view.bounds.width)
        ])
    }
}


// MARK: Stars
extension ViewController {
    private func setupStars() {
        createStars(n: 10, scale: 1.2, color: .purple)
        createStars(n: 20, scale: 0.8, color: .init(red: 0.7, green: 0, blue: 0.7, alpha: 1))
        createStars(n: 30, scale: 0.5, color: .init(red: 0.8, green: 0, blue: 0.8, alpha: 1))
        createStars(n: 50, scale: 0.3, color: .init(red: 0.6, green: 0, blue: 0.6, alpha: 1))
        createStars(n: 50, scale: 0.15, color: .init(red: 0.6, green: 0, blue: 0.6, alpha: 1))
    }

    private func createStars(n: Int, scale: CGFloat, color: UIColor) {
        for _ in 0...n {
            let s1 = StarView(scale: scale, color: color)
            let position = CGPoint.random(maxX: view.bounds.width * Const.GalaxyToScreenScale, maxY: view.bounds.height)
            s1.center = position
            galaxy.addSubview(s1)
        }
    }
}

// MARK: Road
extension ViewController {
    private func setupRoad(path: UIBezierPath) {
        road.path = path.cgPath
        road.strokeColor = UIColor.gray.cgColor
        road.lineWidth = 2
        road.lineDashPattern = [2, 10]
        road.lineCap = .round
        road.bounds = .init(origin: .zero, size: .init(width: CGFloat(Const.segments) * Const.segmentBounds.width, height: Const.segmentBounds.height))
        road.position = view.center
        road.fillColor = UIColor.clear.cgColor
        scene.layer.addSublayer(road)

        setupRoadAnimation()
    }

    private func setupRoadAnimation() {
        let linePhaseAnimation = CABasicAnimation(keyPath: "lineDashPhase")
        // the lineDashPhase must be the sum of lineDashPattern elements so it loops correctly.
        linePhaseAnimation.fromValue = (road.lineDashPattern ?? []).reduce(0, { partialResult, value in
            partialResult + value.doubleValue
        })
        linePhaseAnimation.toValue = 0
        linePhaseAnimation.duration = 2
        linePhaseAnimation.repeatCount = .infinity
        road.add(linePhaseAnimation, forKey: "lineMovement")
    }
}

// MARK: Cursor
extension ViewController {
    private func setupCursor() {
        cursor.opacity = 1
        cursor.path = MyPaths.circle.cgPath
        cursor.bounds = .init(origin: .zero, size: .init(width: 50, height: 50))
        cursor.fillColor = UIColor.cyan.cgColor
        cursor.position = view.center
        scene.layer.addSublayer(cursor)
        cursor.speed = 0 // by this property we can manually set progress for the animation.

        setupCursorAnimations()
    }

    private func setupCursorAnimations() {
        // segments for motion path. You might ask why didn't I use a single keyframe animation with aggregate_path and with a duration of 3.0 instead of slicing the whole motion path animation into it's three segments?
        let motionPathSegment1Animation = CAKeyframeAnimation(keyPath: "position")
        motionPathSegment1Animation.path = segments[0].cgPath
        motionPathSegment1Animation.duration = 1
        motionPathSegment1Animation.beginTime = 0

        let motionPathSegment2Animation = CAKeyframeAnimation(keyPath: "position")
        motionPathSegment2Animation.path = segments[1].cgPath
        motionPathSegment2Animation.duration = 1
        motionPathSegment2Animation.beginTime = 1

        let motionPathSegment3Animation = CAKeyframeAnimation(keyPath: "position")
        motionPathSegment3Animation.path = segments[2].cgPath
        motionPathSegment3Animation.duration = 1
        motionPathSegment3Animation.beginTime = 2

        // morph animation which transforms the cursor from circle to rocket
        let morphAnim = CAKeyframeAnimation(keyPath: "path")
        morphAnim.values = [MyPaths.circle.cgPath, MyPaths.rocket.cgPath]
        morphAnim.keyTimes = [0, 1]
        morphAnim.duration = 1
        morphAnim.beginTime = 1
        morphAnim.fillMode = .forwards

        // the scale animation for the cursor, which expands to a bigger circle, while it is transforming to a rocket it expands a bit more, and when its skyrocketting, it expands even more.
        let scaleAnim = CAKeyframeAnimation(keyPath: "scale")
        scaleAnim.values = [ 
            CGSize(width: 0.4, height: 0.4),
            CGSize(width: 1, height: 1),
            CGSize(width: 1.2, height: 1.2),
            CGSize(width: 2.2, height: 2.2)
        ]
        scaleAnim.keyTimes = [0, 0.333333, 0.9, 1]
        scaleAnim.isRemovedOnCompletion = false
        scaleAnim.duration = 3

        // on the second segment we want the cursor to be tangent to a horizontal line.
        let seg2HorizontalTangentAnimation = CAKeyframeAnimation(keyPath: "rotationTangentCurrentPoint")
        seg2HorizontalTangentAnimation.path = MyPaths.horizontalLine.cgPath
        seg2HorizontalTangentAnimation.duration = 1
        seg2HorizontalTangentAnimation.beginTime = 1

        // on the third segment we want the cursor be tangent to the third segment of the road.
        let seg3TangentAnimation = CAKeyframeAnimation(keyPath: "rotationTangentCurrentPoint")
        seg3TangentAnimation.path = segments[2].cgPath
        seg3TangentAnimation.duration = 1
        seg3TangentAnimation.beginTime = 2

        let groupAnimation = CAAnimationGroup()
        groupAnimation.duration = 3
        groupAnimation.animations = [
            motionPathSegment1Animation,
            motionPathSegment2Animation,
            motionPathSegment3Animation,
            morphAnim,
            scaleAnim,
            seg3TangentAnimation,
            seg2HorizontalTangentAnimation
        ]
        groupAnimation.isRemovedOnCompletion = false
        groupAnimation.fillMode = .forwards

        cursor.add(groupAnimation, forKey: "group")

    }
}

// MARK: Labels
extension ViewController {
    private func createLabel(text: String, alignment: NSTextAlignment = .center, fontSize: CGFloat = 18) -> UILabel {
        let result = UILabel()
        result.font = .init(name: "Courier", size: fontSize)
        result.textColor = UIColor.white.withAlphaComponent(0.9)
        result.numberOfLines = 0
        result.textAlignment = alignment
        let ps = NSMutableParagraphStyle()
        ps.lineSpacing = 7
        result.attributedText = .init(string: text, attributes: [
            .paragraphStyle: ps
        ])
        return result
    }

    private func setupLabels() {

        let w = view.bounds.width
        let lw: CGFloat = 240

        scrollViewContentView.addSubview(label1)
        label1.frame = .init(x: (w - lw) / 2, y: 420, width: lw, height: 200)

        scrollViewContentView.addSubview(label2)
        label2.frame = .init(x: w + 70, y: 210, width: lw, height: 200)


        scrollViewContentView.addSubview(label3)
        label3.frame = .init(x: 2 * w + 180, y: 450, width: lw, height: 200)


        scrollViewContentView.addSubview(label4)
        label4.frame = .init(x: 3 * w + 450, y: 40, width: lw * 1.5, height: 300)
    }
}

// MARK: State Management
extension ViewController {
    // the parallax effect for the background
    private func updateGalaxyDisplacement(_ globalProgress: CGFloat) {
        let min = -(Const.GalaxyToScreenScale - 1.0) * view.bounds.width
        let max = -min
        let galaxyDisplacement = CGFloat.lerp(globalProgress, srcLow: 0, srcHigh: 1, dstLow: min, dstHigh: max)
        galaxy.transform = .init(translationX: galaxyDisplacement, y: 0)
    }

    // progress goes from 0 to 1, we update the cursors animation timeoffset and we update the position (translation) of road and cursor.
    // 0 - 0.25: page 1
    // 0.25 - 0.5: page 2
    // 0.5 - 0.75: page 3
    // 0.75 - 1.0: page 4
    private func updateCursorAndRoad(_ globalProgress: CGFloat) {
        let pageFloat = globalProgress * CGFloat(Const.pages - 1)

        let cursorTimeoffset = pageFloat.clamp(minValue: 0, maxValue: 3)
        cursor.timeOffset = cursorTimeoffset

        CATransaction.begin()
        CATransaction.setDisableActions(true)
        let path_displacement = Const.segmentBounds.width * pageFloat.clamp(minValue: 0, maxValue: CGFloat(Const.segments))
        // road's center is aligned to the scene's center
        //  thats why we need to add aggregatePathBoundingBox.width / 2.0 so we keep it horizontally centered.
        let aggregatePathBoundingBoxWidth = CGFloat(Const.segments) * Const.segmentBounds.width
        road.transform = CATransform3DMakeAffineTransform(.init(translationX: -path_displacement + aggregatePathBoundingBoxWidth / 2, y: 0))
        cursor.translation = .init(x: view.center.x - path_displacement, y: view.center.y - 200.0)
        CATransaction.commit()
    }

    // on last page we perform an expand animation on the whole scene while we make the label4 appear as well.
    private func updateScene(_ globalProgress: CGFloat) {
        let pageFloat = globalProgress * CGFloat(Const.pages - 1)
        let page = Int(pageFloat)
        let page_progress = pageFloat - CGFloat(page)

        let progress: CGFloat
        if page == 3 {
            progress = page_progress
        } else if page == 4 {
            progress = 1
        } else {
            progress = 0
        }

        let dy = CGFloat.lerp(progress, srcLow: 0, srcHigh: 1, dstLow: 0, dstHigh: 1380)
        let dx = CGFloat.lerp(progress, srcLow: 0, srcHigh: 1, dstLow: 0, dstHigh: 170)
        let s = CGFloat.lerp(progress, srcLow: 0, srcHigh: 1, dstLow: 1.0, dstHigh: 5)
        scene.transform = .init(translationX: dx, y: dy).scaledBy(x: s, y: s)
        label4.alpha = progress
    }


    private func updateState(_ globalProgress: CGFloat) {
        updateCursorAndRoad(globalProgress)
        updateGalaxyDisplacement(globalProgress)
        updateScene(globalProgress)
    }
}
