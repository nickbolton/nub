//
//  Animator.swift
//  Bedrock
//
//  Created by Nick Bolton on 3/30/18.
//  Copyright © 2018 Bedrock. All rights reserved.
//

import UIKit

@available(iOS 10.0, *)
public enum AnimatorType {
    case propertyAnimator
    case displayLink
}

public struct AnimationDirection: OptionSet {
    public var rawValue: Int
    public typealias RawValue = Int
    
    public init(rawValue: Int) {
        self.rawValue = rawValue
    }
    
    public static let forward = AnimationDirection(rawValue: 1 << 0)
    public static let reverse = AnimationDirection(rawValue: 1 << 1)
    public static let both = AnimationDirection.forward.union(.reverse)
}

@available(iOS 10.0, *)
public protocol Animator {
    var tag: Int { get set }
    var type: AnimatorType { get set }
    var isReverse: Bool { get set }
    var isDisabled: Bool { get set }
    var useNativeViews: Bool { get set }
    var easing: Easing { get set }
    var startingAt: TimeInterval { get set }
    var endingAt: TimeInterval { get set }
    var duration: TimeInterval { get set }
    var delay: TimeInterval { get set }
    var reverseStartingAt: TimeInterval { get }
    var reverseEndingAt: TimeInterval { get }
    var directionMask: AnimationDirection { get }
    func setupAnimation(context: AnimationContext)
    func performAnimations(context: AnimationContext)
    func performAnimations(at: TimeInterval, context: AnimationContext)
    func completeAnimation(context: AnimationContext)
    func cancelAnimation(context: AnimationContext)
    func enumerateViews(_ handler: (UIView, Int)->Void)
    func set(direction: AnimationDirection) -> Animator
}

@available(iOS 10.0, *)
public class AnimationContext: NSObject {
    public var containerView: UIView
    public var isCompleted = false
    public var isReversed = false
    public var animationDuration: TimeInterval = 0.3
    public var processedSetupViews = [String: Set<UIView>]()

    required public init(containerView: UIView) {
        self.containerView = containerView
        super.init()
    }
    
    private func processedKey(_ animator: Animator) -> String {
        return NSStringFromClass(type(of: animator) as! AnyClass)
    }
    
    public func markViewProcessed(_ view: UIView, animator: Animator) {
        let key = processedKey(animator)
        var set = processedSetupViews[key] ?? Set<UIView>()
        set.insert(view)
        processedSetupViews[key] = set
    }
    
    public func isViewProcessed(_ view: UIView, animator: Animator) -> Bool {
        return processedSetupViews[processedKey(animator)]?.contains(view) ?? false
    }
}

@available(iOS 10.0, *)
extension UIView {
    
    private struct AssociatedKey {
        static var animationContext = "wd_UIView.animationContext"
    }
    
    // MARK: - Properties
    
    private var br_displayLinkAnimator: DisplayLinkAnimator? {
        get { return objc_getAssociatedObject(self, &AssociatedKey.animationContext) as? DisplayLinkAnimator }
        set { objc_setAssociatedObject(self, &AssociatedKey.animationContext, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }

    func animate(withDuration duration: TimeInterval, delay: TimeInterval = 0.0, animators: [Animator], completion: BooleanResultHandler? = nil) {
        
        let animationContext = AnimationContext(containerView: self)
        
        let displayLinkAnimator = DisplayLinkAnimator()
        
        for anim in animators {
            anim.setupAnimation(context: animationContext)
        }
        
        displayLinkAnimator.totalDuration = duration
        
        for animator in animators {
            displayLinkAnimator.registerAnimation(startingAt: animator.startingAt, endingAt: animator.endingAt, easing: animator.easing) { t in
                animator.performAnimations(at: t, context: animationContext)
            }
        }
        
        displayLinkAnimator.completion = { [weak self] isCompleted in
            _ = animators.map { isCompleted ? $0.completeAnimation(context: animationContext) : $0.cancelAnimation(context: animationContext) }
            self?.br_displayLinkAnimator = nil
        }
        
        displayLinkAnimator.start()
        br_displayLinkAnimator = displayLinkAnimator
    }

    static public let unscaled = CGPoint(x: 1.0, y: 1.0)

    static public func morphingLabelAnimation(_ from: UILabel?, to: UILabel?, crossFade: Bool, startingAt: TimeInterval = 0.0, endingAt: TimeInterval = 1.0, easing: Easing = Easing(.quadInOut)) -> Animator {
        assert(startingAt >= 0.0 && startingAt <= 1.0, "startingAt (\(startingAt)) is out of range")
        assert(endingAt >= 0.0 && endingAt <= 1.0, "endingAt (\(endingAt)) is out of range")
        assert(startingAt <= endingAt, "startingAt \(startingAt) > endingAt \(endingAt)")
        let result = MorphingLabelAnimator(from: from, to: to, isCrossFading: crossFade, easing: easing)
        result.startingAt = startingAt
        result.endingAt = endingAt
        return result
    }
    static public func morphingLabelAnimation(_ from: UILabel?, to: UILabel?, crossFade: Bool, delay: TimeInterval = 0.0, duration: TimeInterval, easing: Easing = Easing(.quadInOut)) -> Animator {
        let result = MorphingLabelAnimator(from: from, to: to, isCrossFading: crossFade, easing: easing)
        result.delay = delay
        result.duration = duration
        return result
    }

    static public func animateFrame(_ view: UIView, start: CGRect, end: CGRect, startingAt: TimeInterval = 0.0, endingAt: TimeInterval = 1.0, easing: Easing = Easing(.quadInOut)) -> Animator {
        assert(startingAt >= 0.0 && startingAt <= 1.0, "startingAt (\(startingAt)) is out of range")
        assert(endingAt >= 0.0 && endingAt <= 1.0, "endingAt (\(endingAt)) is out of range")
        assert(startingAt <= endingAt, "startingAt \(startingAt) > endingAt \(endingAt)")
        let result = FrameAnimator(view: view, startFrame: start, endFrame: end, easing: easing)
        result.startingAt = startingAt
        result.endingAt = endingAt
        return result
    }
    static public func animateFrame(_ view: UIView, start: CGRect, end: CGRect, delay: TimeInterval = 0.0, duration: TimeInterval, easing: Easing = Easing(.quadInOut)) -> Animator {
        let result = FrameAnimator(view: view, startFrame: start, endFrame: end, easing: easing)
        result.delay = delay
        result.duration = duration
        return result
    }
    
    static public func animateCornerRadius(_ view: UIView, start: CGFloat, end: CGFloat, startingAt: TimeInterval = 0.0, endingAt: TimeInterval = 1.0, easing: Easing = Easing(.quadInOut)) -> Animator {
        assert(startingAt >= 0.0 && startingAt <= 1.0, "startingAt (\(startingAt)) is out of range")
        assert(endingAt >= 0.0 && endingAt <= 1.0, "endingAt (\(endingAt)) is out of range")
        assert(startingAt <= endingAt, "startingAt \(startingAt) > endingAt \(endingAt)")
        let result = CornerRadiusAnimator(view: view, start: start, end: end, easing: easing)
        result.startingAt = startingAt
        result.endingAt = endingAt
        return result
    }
    static public func animateCornerRadius(_ view: UIView, start: CGFloat, end: CGFloat, delay: TimeInterval = 0.0, duration: TimeInterval, easing: Easing = Easing(.quadInOut)) -> Animator {
        let result = CornerRadiusAnimator(view: view, start: start, end: end, easing: easing)
        result.delay = delay
        result.duration = duration
        return result
    }
    
    static public func translate(_ views: [UIView?], to: UIView?, startingAt: TimeInterval = 0.0, endingAt: TimeInterval = 1.0, easing: Easing = Easing(.quadInOut)) -> Animator {
        assert(startingAt >= 0.0 && startingAt <= 1.0, "startingAt (\(startingAt)) is out of range")
        assert(endingAt >= 0.0 && endingAt <= 1.0, "endingAt (\(endingAt)) is out of range")
        assert(startingAt <= endingAt, "startingAt \(startingAt) > endingAt \(endingAt)")
        let result = TranslateCenterToAnimator(views: views, targetView: to, easing: easing)
        result.startingAt = startingAt
        result.endingAt = endingAt
        return result
    }
    static public func translate(_ views: [UIView?], to: UIView?, delay: TimeInterval = 0.0, duration: TimeInterval, easing: Easing = Easing(.quadInOut)) -> Animator {
        let result = TranslateCenterToAnimator(views: views, targetView: to, easing: easing)
        result.delay = delay
        result.duration = duration
        return result
    }

    static public func transformAnimation(_ views: [UIView?], applyToInitialTransforms: Bool = false, startScale: CGPoint = UIView.unscaled, endScale: CGPoint = UIView.unscaled, startAngle: CGFloat = 0, endAngle: CGFloat = 0, startTranslation: CGVector = .zero, endTranslation: CGVector = .zero, startingAt: TimeInterval = 0.0, endingAt: TimeInterval = 1.0, easing: Easing = Easing(.quadInOut)) -> Animator {
        assert(startingAt >= 0.0 && startingAt <= 1.0, "startingAt (\(startingAt)) is out of range")
        assert(endingAt >= 0.0 && endingAt <= 1.0, "endingAt (\(endingAt)) is out of range")
        assert(startingAt <= endingAt, "startingAt \(startingAt) > endingAt \(endingAt)")
        let result = TransformAnimator(views: views, startScale: startScale, startAngle: startAngle, startTranslation: startTranslation, endScale: endScale, endAngle: endAngle, endTranslation: endTranslation, easing: easing)
        result.startingAt = startingAt
        result.endingAt = endingAt
        return result
    }
    static public func transformAnimation(_ views: [UIView?], applyToInitialTransforms: Bool = false, startScale: CGPoint = UIView.unscaled, endScale: CGPoint = UIView.unscaled, startAngle: CGFloat = 0, endAngle: CGFloat = 0, startTranslation: CGVector = .zero, endTranslation: CGVector = .zero, delay: TimeInterval = 0.0, duration: TimeInterval, easing: Easing = Easing(.quadInOut)) -> Animator {
        let result = TransformAnimator(views: views, startScale: startScale, startAngle: startAngle, startTranslation: startTranslation, endScale: endScale, endAngle: endAngle, endTranslation: endTranslation, easing: easing)
        result.delay = delay
        result.duration = duration
        return result
    }

    static public func scalingAnimation(_ from: UIView?, to: UIView?, startingAt: TimeInterval = 0.0, endingAt: TimeInterval = 1.0, easing: Easing = Easing(.quadInOut)) -> Animator {
        assert(startingAt >= 0.0 && startingAt <= 1.0, "startingAt (\(startingAt)) is out of range")
        assert(endingAt >= 0.0 && endingAt <= 1.0, "endingAt (\(endingAt)) is out of range")
        assert(startingAt <= endingAt, "startingAt \(startingAt) > endingAt \(endingAt)")
        let result = ScalingFromToAnimator(from: from, to: to, easing: easing)
        result.startingAt = startingAt
        result.endingAt = endingAt
        return result
    }
    static public func scalingAnimation(_ from: UIView?, to: UIView?, delay: TimeInterval = 0.0, duration: TimeInterval, easing: Easing = Easing(.quadInOut)) -> Animator {
        let result = ScalingFromToAnimator(from: from, to: to, easing: easing)
        result.delay = delay
        result.duration = duration
        return result
    }

    static public func fadeOutAnimator(_ views: [UIView?], startingAt: TimeInterval = 0.0, endingAt: TimeInterval = 1.0, easing: Easing = Easing(.quadInOut)) -> Animator {
        assert(startingAt >= 0.0 && startingAt <= 1.0, "startingAt (\(startingAt)) is out of range")
        assert(endingAt >= 0.0 && endingAt <= 1.0, "endingAt (\(endingAt)) is out of range")
        assert(startingAt <= endingAt, "startingAt \(startingAt) > endingAt \(endingAt)")
        let result = FadeOutAnimator(views: views, easing: easing)
        result.startingAt = startingAt
        result.endingAt = endingAt
        return result
    }
    static public func fadeOutAnimator(_ views: [UIView?], delay: TimeInterval = 0.0, duration: TimeInterval, easing: Easing = Easing(.quadInOut)) -> Animator {
        let result = FadeOutAnimator(views: views, easing: easing)
        result.delay = delay
        result.duration = duration
        return result
    }

    static public func fadeInAnimator(_ views: [UIView?], startingAt: TimeInterval = 0.0, endingAt: TimeInterval = 1.0, easing: Easing = Easing(.quadInOut)) -> Animator {
        assert(startingAt >= 0.0 && startingAt <= 1.0, "startingAt (\(startingAt)) is out of range")
        assert(endingAt >= 0.0 && endingAt <= 1.0, "endingAt (\(endingAt)) is out of range")
        assert(startingAt <= endingAt, "startingAt \(startingAt) > endingAt \(endingAt)")
        let result = FadeInAnimator(views: views, easing: easing)
        result.startingAt = startingAt
        result.endingAt = endingAt
        return result
    }
    static public func fadeInAnimator(_ views: [UIView?], delay: TimeInterval = 0.0, duration: TimeInterval, easing: Easing = Easing(.quadInOut)) -> Animator {
        let result = FadeInAnimator(views: views, easing: easing)
        result.delay = delay
        result.duration = duration
        return result
    }

    static public func initiallyTranslatedAnimator(_ views: [UIView?], translations: [CGVector], startingAt: TimeInterval = 0.0, endingAt: TimeInterval = 1.0, easing: Easing = Easing(.quadInOut)) -> Animator {
        assert(views.count == translations.count, "views.count != translations.count")
        assert(startingAt >= 0.0 && startingAt <= 1.0, "startingAt (\(startingAt)) is out of range")
        assert(endingAt >= 0.0 && endingAt <= 1.0, "endingAt (\(endingAt)) is out of range")
        assert(startingAt <= endingAt, "startingAt \(startingAt) > endingAt \(endingAt)")
        let result = InitiallyTranslatedAnimator(views: views, translations: translations, easing: easing)
        result.startingAt = startingAt
        result.endingAt = endingAt
        return result
    }
    static public func presentFromAboveAnimator(_ views: [UIView?], translations: [CGVector], delay: TimeInterval = 0.0, duration: TimeInterval, easing: Easing = Easing(.quadInOut)) -> Animator {
        assert(views.count == translations.count, "views.count != translations.count")
        let result = InitiallyTranslatedAnimator(views: views, translations: translations, easing: easing)
        result.delay = delay
        result.duration = duration
        return result
    }

    static public func presentFromAboveAnimator(_ views: [UIView?], startingAt: TimeInterval = 0.0, endingAt: TimeInterval = 1.0, easing: Easing = Easing(.quadInOut)) -> Animator {
        assert(startingAt >= 0.0 && startingAt <= 1.0, "startingAt (\(startingAt)) is out of range")
        assert(endingAt >= 0.0 && endingAt <= 1.0, "endingAt (\(endingAt)) is out of range")
        assert(startingAt <= endingAt, "startingAt \(startingAt) > endingAt \(endingAt)")
        let result = PresentFromAboveAnimator(views: views, easing: easing)
        result.startingAt = startingAt
        result.endingAt = endingAt
        return result
    }
    static public func presentFromAboveAnimator(_ views: [UIView?], delay: TimeInterval = 0.0, duration: TimeInterval, easing: Easing = Easing(.quadInOut)) -> Animator {
        let result = PresentFromAboveAnimator(views: views, easing: easing)
        result.delay = delay
        result.duration = duration
        return result
    }

    static public func presentFromBelowAnimator(_ views: [UIView?], startingAt: TimeInterval = 0.0, endingAt: TimeInterval = 1.0, easing: Easing = Easing(.quadInOut)) -> Animator {
        assert(startingAt >= 0.0 && startingAt <= 1.0, "startingAt (\(startingAt)) is out of range")
        assert(endingAt >= 0.0 && endingAt <= 1.0, "endingAt (\(endingAt)) is out of range")
        assert(startingAt <= endingAt, "startingAt \(startingAt) > endingAt \(endingAt)")
        let result = PresentFromBelowAnimator(views: views, easing: easing)
        result.startingAt = startingAt
        result.endingAt = endingAt
        return result
    }
    static public func presentFromBelowAnimator(_ views: [UIView?], delay: TimeInterval = 0.0, duration: TimeInterval, easing: Easing = Easing(.quadInOut)) -> Animator {
        let result = PresentFromBelowAnimator(views: views, easing: easing)
        result.delay = delay
        result.duration = duration
        return result
    }

    static public func presentFromLeftAnimator(_ views: [UIView?], startingAt: TimeInterval = 0.0, endingAt: TimeInterval = 1.0, easing: Easing = Easing(.quadInOut)) -> Animator {
        assert(startingAt >= 0.0 && startingAt <= 1.0, "startingAt (\(startingAt)) is out of range")
        assert(endingAt >= 0.0 && endingAt <= 1.0, "endingAt (\(endingAt)) is out of range")
        assert(startingAt <= endingAt, "startingAt \(startingAt) > endingAt \(endingAt)")
        let result = PresentFromLeftAnimator(views: views, easing: easing)
        result.startingAt = startingAt
        result.endingAt = endingAt
        return result
    }
    static public func presentFromLeftAnimator(_ views: [UIView?], delay: TimeInterval = 0.0, duration: TimeInterval, easing: Easing = Easing(.quadInOut)) -> Animator {
        let result = PresentFromLeftAnimator(views: views, easing: easing)
        result.delay = delay
        result.duration = duration
        return result
    }

    static public func presentFromRightAnimator(_ views: [UIView?], startingAt: TimeInterval = 0.0, endingAt: TimeInterval = 1.0, easing: Easing = Easing(.quadInOut)) -> Animator {
        assert(startingAt >= 0.0 && startingAt <= 1.0, "startingAt (\(startingAt)) is out of range")
        assert(endingAt >= 0.0 && endingAt <= 1.0, "endingAt (\(endingAt)) is out of range")
        assert(startingAt <= endingAt, "startingAt \(startingAt) > endingAt \(endingAt)")
        let result = PresentFromRightAnimator(views: views, easing: easing)
        result.startingAt = startingAt
        result.endingAt = endingAt
        return result
    }
    static public func presentFromRightAnimator(_ views: [UIView?], delay: TimeInterval = 0.0, duration: TimeInterval, easing: Easing = Easing(.quadInOut)) -> Animator {
        let result = PresentFromRightAnimator(views: views, easing: easing)
        result.delay = delay
        result.duration = duration
        return result
    }

    static public func dismissToAboveAnimator(_ views: [UIView?], containerView: UIView, startingAt: TimeInterval = 0.0, endingAt: TimeInterval = 1.0, easing: Easing = Easing(.quadInOut)) -> Animator {
        assert(startingAt >= 0.0 && startingAt <= 1.0, "startingAt (\(startingAt)) is out of range")
        assert(endingAt >= 0.0 && endingAt <= 1.0, "endingAt (\(endingAt)) is out of range")
        assert(startingAt <= endingAt, "startingAt \(startingAt) > endingAt \(endingAt)")
        let dy: CGFloat = views.reduce(0.0) { (result, v) -> CGFloat in
            guard let v = v else { return result }
            let frame = v.convert(v.bounds, to: containerView)
            return max(result, frame.maxY)
        }
        var result = transformAnimation(views, endTranslation: CGVector(dx: 0.0, dy: -dy), easing: easing)
        result.startingAt = startingAt
        result.endingAt = endingAt
        return result
    }
    static public func dismissToAboveAnimator(_ views: [UIView?], containerView: UIView, delay: TimeInterval = 0.0, duration: TimeInterval, easing: Easing = Easing(.quadInOut)) -> Animator {
        let dy: CGFloat = views.reduce(0.0) { (result, v) -> CGFloat in
            guard let v = v else { return result }
            let frame = v.convert(v.bounds, to: containerView)
            return max(result, frame.maxY)
        }
        var result = transformAnimation(views, endTranslation: CGVector(dx: 0.0, dy: -dy), easing: easing)
        result.delay = delay
        result.duration = duration
        return result
    }
    
    static public func dismissToBelowAnimator(_ views: [UIView?], containerView: UIView, startingAt: TimeInterval = 0.0, endingAt: TimeInterval = 1.0, easing: Easing = Easing(.quadInOut)) -> Animator {
        assert(startingAt >= 0.0 && startingAt <= 1.0, "startingAt (\(startingAt)) is out of range")
        assert(endingAt >= 0.0 && endingAt <= 1.0, "endingAt (\(endingAt)) is out of range")
        assert(startingAt <= endingAt, "startingAt \(startingAt) > endingAt \(endingAt)")
        let dy: CGFloat = views.reduce(0.0) { (result, v) -> CGFloat in
            guard let v = v else { return result }
            let frame = v.convert(v.bounds, to: containerView)
            return max(result, containerView.frame.height - frame.minY)
        }
        var result = transformAnimation(views, endTranslation: CGVector(dx: 0.0, dy: dy), easing: easing)
        result.startingAt = startingAt
        result.endingAt = endingAt
        return result
    }
    static public func dismissToBelowAnimator(_ views: [UIView?], containerView: UIView, delay: TimeInterval = 0.0, duration: TimeInterval, easing: Easing = Easing(.quadInOut)) -> Animator {
        let dy: CGFloat = views.reduce(0.0) { (result, v) -> CGFloat in
            guard let v = v else { return result }
            let frame = v.convert(v.bounds, to: containerView)
            return max(result, containerView.frame.height - frame.minY)
        }
        var result = transformAnimation(views, endTranslation: CGVector(dx: 0.0, dy: dy), easing: easing)
        result.delay = delay
        result.duration = duration
        return result
    }
    
    static public func dismissToLeftAnimator(_ views: [UIView?], containerView: UIView, startingAt: TimeInterval = 0.0, endingAt: TimeInterval = 1.0, easing: Easing = Easing(.quadInOut)) -> Animator {
        assert(startingAt >= 0.0 && startingAt <= 1.0, "startingAt (\(startingAt)) is out of range")
        assert(endingAt >= 0.0 && endingAt <= 1.0, "endingAt (\(endingAt)) is out of range")
        assert(startingAt <= endingAt, "startingAt \(startingAt) > endingAt \(endingAt)")
        let dx: CGFloat = views.reduce(0.0) { (result, v) -> CGFloat in
            guard let v = v else { return result }
            let frame = v.convert(v.bounds, to: containerView)
            return max(result, frame.maxX)
        }
        var result = transformAnimation(views, endTranslation: CGVector(dx: -dx, dy: 0.0), easing: easing)
        result.startingAt = startingAt
        result.endingAt = endingAt
        return result
    }
    static public func dismissToLeftAnimator(_ views: [UIView?], containerView: UIView, delay: TimeInterval = 0.0, duration: TimeInterval, easing: Easing = Easing(.quadInOut)) -> Animator {
        let dx: CGFloat = views.reduce(0.0) { (result, v) -> CGFloat in
            guard let v = v else { return result }
            let frame = v.convert(v.bounds, to: containerView)
            return max(result, frame.maxX)
        }
        var result = transformAnimation(views, endTranslation: CGVector(dx: -dx, dy: 0.0), easing: easing)
        result.delay = delay
        result.duration = duration
        return result
    }
    
    static public func dismissToRightAnimator(_ views: [UIView?], containerView: UIView, startingAt: TimeInterval = 0.0, endingAt: TimeInterval = 1.0, easing: Easing = Easing(.quadInOut)) -> Animator {
        assert(startingAt >= 0.0 && startingAt <= 1.0, "startingAt (\(startingAt)) is out of range")
        assert(endingAt >= 0.0 && endingAt <= 1.0, "endingAt (\(endingAt)) is out of range")
        assert(startingAt <= endingAt, "startingAt \(startingAt) > endingAt \(endingAt)")
        let dx: CGFloat = views.reduce(0.0) { (result, v) -> CGFloat in
            guard let v = v else { return result }
            let frame = v.convert(v.bounds, to: containerView)
            return max(result, containerView.frame.width - frame.minX)
        }
        var result = transformAnimation(views, endTranslation: CGVector(dx: dx, dy: 0.0), easing: easing)
        result.startingAt = startingAt
        result.endingAt = endingAt
        return result
    }
    static public func dismissToRightAnimator(_ views: [UIView?], containerView: UIView, delay: TimeInterval = 0.0, duration: TimeInterval, easing: Easing = Easing(.quadInOut)) -> Animator {
        let dx: CGFloat = views.reduce(0.0) { (result, v) -> CGFloat in
            guard let v = v else { return result }
            let frame = v.convert(v.bounds, to: containerView)
            return max(result, containerView.frame.width - frame.minX)
        }
        var result = transformAnimation(views, endTranslation: CGVector(dx: dx, dy: 0.0), easing: easing)
        result.delay = delay
        result.duration = duration
        return result
    }

    static public func presentFromSourceAnimator(_ views: [UIView?], source: UIView, startingAt: TimeInterval = 0.0, endingAt: TimeInterval = 1.0, easing: Easing = Easing(.quadInOut)) -> Animator {
        assert(startingAt >= 0.0 && startingAt <= 1.0, "startingAt (\(startingAt)) is out of range")
        assert(endingAt >= 0.0 && endingAt <= 1.0, "endingAt (\(endingAt)) is out of range")
        assert(startingAt <= endingAt, "startingAt \(startingAt) > endingAt \(endingAt)")
        let result = PresentFromSourceAnimator(views: views, source: source, easing: easing)
        result.startingAt = startingAt
        result.endingAt = endingAt
        return result
    }
    static public func presentFromSourceAnimator(_ views: [UIView?], source: UIView, delay: TimeInterval = 0.0, duration: TimeInterval, easing: Easing = Easing(.quadInOut)) -> Animator {
        let result = PresentFromSourceAnimator(views: views, source: source, easing: easing)
        result.delay = delay
        result.duration = duration
        return result
    }

    static public func hideUntilAnimationCompleted(_ views: [UIView?]) -> Animator {
        return HideUntilAnimationCompletedAnimator(views: views)
    }
    static public func hideUntilFullAnimationCompleted(_ views: [UIView?]) -> Animator {
        return HideUntilFullAnimationCompletedAnimator(views: views)
    }
    
    static public func presentStaggered(_ views: [[UIView?]], horizontalTranslation: CGFloat = 0, verticalTranslation: CGFloat = 0, isPartitioned: Bool = true, startingAt: TimeInterval = 0.0, endingAt: TimeInterval = 1.0, easing: Easing = Easing(.quadInOut)) -> [Animator] {
        assert(startingAt >= 0.0 && startingAt <= 1.0, "startingAt (\(startingAt)) is out of range")
        assert(endingAt >= 0.0 && endingAt <= 1.0, "endingAt (\(endingAt)) is out of range")
        assert(startingAt <= endingAt, "startingAt \(startingAt) > endingAt \(endingAt)")
        guard views.count > 0 else { return [] }

        var animators = [Animator]()
        
        // for partitioned staggering
        let timeSpacing = (endingAt - startingAt) / TimeInterval(views.count + 1)
        
        // for non-partitioned
        let delayIncrement: TimeInterval = (endingAt - startingAt) / TimeInterval(views.count + 2)
        var delay: TimeInterval = 0.0
        
        for i in 0..<views.count {
            let starting = isPartitioned ? startingAt + (TimeInterval(i) * timeSpacing) : startingAt + delay
            let ending = isPartitioned ? startingAt + (TimeInterval(i+2) * timeSpacing) : endingAt
            for view in views[i] {
                guard let view = view else { continue }
                animators.append(UIView.fadeInAnimator([view], startingAt: starting, endingAt: ending, easing: easing))
                animators.append(UIView.transformAnimation([view], startTranslation: CGVector(dx: horizontalTranslation, dy: verticalTranslation), startingAt: starting, endingAt: ending, easing: easing))
            }
            delay += delayIncrement
        }
        
        return animators
    }

    static public func dismissStaggered(_ views: [[UIView?]], horizontalTranslation: CGFloat = 0, verticalTranslation: CGFloat = 0, isPartitioned: Bool = true, startingAt: TimeInterval = 0.0, endingAt: TimeInterval = 1.0, easing: Easing = Easing(.quadInOut)) -> [Animator] {
        assert(startingAt >= 0.0 && startingAt <= 1.0, "startingAt (\(startingAt)) is out of range")
        assert(endingAt >= 0.0 && endingAt <= 1.0, "endingAt (\(endingAt)) is out of range")
        assert(startingAt <= endingAt, "startingAt \(startingAt) > endingAt \(endingAt)")
        guard views.count > 0 else { return [] }
        
        var animators = [Animator]()
        
        // for partitioned staggering
        let timeSpacing = (endingAt - startingAt) / TimeInterval(views.count + 1)
        
        // for non-partitioned
        let delayIncrement: TimeInterval = (endingAt - startingAt) / TimeInterval(views.count + 2)
        var delay: TimeInterval = 0.0
        
        for i in 0..<views.count {
            let starting = isPartitioned ? startingAt + (TimeInterval(i) * timeSpacing) : startingAt + delay
            let ending = isPartitioned ? startingAt + (TimeInterval(i+2) * timeSpacing) : endingAt
            for view in views[i] {
                guard let view = view else { continue }
                animators.append(UIView.fadeOutAnimator([view], startingAt: starting, endingAt: ending, easing: easing))
                animators.append(UIView.transformAnimation([view], endTranslation: CGVector(dx: horizontalTranslation, dy: verticalTranslation), startingAt: starting, endingAt: ending, easing: easing))
            }
            delay += delayIncrement
        }
        
        return animators
    }

    static public func evenlyStaggerAnimators(_ animators: inout [[Animator]], startingAt: TimeInterval = 0.0, endingAt: TimeInterval = 1.0) {
        assert(startingAt >= 0.0 && startingAt <= 1.0, "startingAt (\(startingAt)) is out of range")
        assert(endingAt >= 0.0 && endingAt <= 1.0, "endingAt (\(endingAt)) is out of range")
        assert(startingAt <= endingAt, "startingAt \(startingAt) > endingAt \(endingAt)")
        let timeSpacing = (endingAt - startingAt) / TimeInterval(animators.count + 1)
        for i in 0..<animators.count {
            let start = startingAt + (TimeInterval(i) * timeSpacing)
            let end = startingAt + (TimeInterval(i+2) * timeSpacing)
            for var animator in animators[i] {
                animator.startingAt = clamp(start, min: startingAt, max: endingAt)
                animator.endingAt = clamp(end, min: startingAt, max: endingAt)
            }
        }
    }
}

@available(iOS 10.0, *)
open class BaseAnimator: NSObject, Animator {
    
    let views: [UIView?]
    var snapshots = [UIView: UIView?]()
    var hiddenViews = Set<UIView>()
    public var directionMask = AnimationDirection.both
    public var isReverse = false
    public var isDisabled = false
    public var duration: TimeInterval = 0.0 { didSet { if duration < 0.0 { duration = 0.0 } } }
    public var delay: TimeInterval = 0.0 { didSet { if delay < 0.0 { delay = 0.0 } } }
    public var startingAt: TimeInterval = 0.0 { didSet { reverseEndingAt = 1.0 - startingAt } }
    public var endingAt: TimeInterval = 1.0 { didSet { reverseStartingAt = 1.0 - endingAt } }
    public var easing: Easing
    public var useNativeViews: Bool = true
    public var reverseStartingAt: TimeInterval = 1.0
    public var reverseEndingAt: TimeInterval = 0.0
    public var tag: Int = 0
    public var type: AnimatorType = .displayLink

    required public init(views: [UIView?] = [], easing: Easing = Easing(.quadInOut)) {
        self.views = views
        self.easing = easing
        super.init()
    }
    
    public func copy() -> Animator {
        return self
    }
    
    public func set(direction: AnimationDirection) -> Animator {
        directionMask = direction
        return self
    }
    
    open func setupAnimation(context: AnimationContext) {
        if !useNativeViews {
            enumerateViews { (v, _) in
                if let snapshot = v.snapshotView(afterScreenUpdates: true) {
                    snapshots[v] = snapshot
                    context.containerView.addSubview(snapshot)
                    snapshot.frame = v.convert(v.bounds, to: context.containerView)
                    if v.isHidden {
                        hiddenViews.insert(v)
                    }
                    v.isHidden = true
                }
            }
        }
    }
    
    open func performAnimations(context: AnimationContext) {
    }
    
    open func performAnimations(at: TimeInterval, context: AnimationContext) {
    }
    
    open func completeAnimation(context: AnimationContext) {
        cleanUpSnapshots()
    }
    
    open func cancelAnimation(context: AnimationContext) {
        cleanUpSnapshots()
    }
    
    private func cleanUpSnapshots() {
        if !useNativeViews {
            for (v, snapshot) in snapshots {
                snapshot?.removeFromSuperview()
                v.isHidden = hiddenViews.contains(v)
            }
        }
    }
    
    func activeView(for view: UIView) -> UIView {
        return (snapshots[view] ?? view)!
    }
    
    public func enumerateViews(_ handler: (UIView, Int)->Void) {
        for idx in 0..<views.count {
            if let v = views[idx] {
                handler(activeView(for: v), idx)
            }
        }
    }
    
    internal func determineNatualCenter(for view: UIView?, to target: UIView?) -> CGPoint {
        guard let view = view, let target = target else { return .zero }
        let transform = view.transform
        view.transform = .identity
        let result = view.convertCenter(to: target)
        view.transform = transform
        return result
    }
}

@available(iOS 10.0, *)
public typealias BlockAnimatorHandler = (UIView, Int, AnimationContext)->Void
@available(iOS 10.0, *)
public typealias BlockAnimatorAtTimeHandler = (TimeInterval, UIView, Int, AnimationContext)->Void

@available(iOS 10.0, *)
public class BlockAnimator: BaseAnimator {
    public let setupHandler: BlockAnimatorHandler?
    public let performHandler: BlockAnimatorHandler?
    public let performAtTimeHandler: BlockAnimatorAtTimeHandler?
    public let cancelHandler: BlockAnimatorHandler?
    public let completionHandler: BlockAnimatorHandler?

    required public init(views: [UIView?], setupHandler: BlockAnimatorHandler? = nil, performHandler: BlockAnimatorHandler? = nil, performAtTimeHandler: BlockAnimatorAtTimeHandler? = nil, cancelHandler: BlockAnimatorHandler? = nil, completionHandler: BlockAnimatorHandler? = nil, startingAt: TimeInterval = 0.0, endingAt: TimeInterval = 1.0, easing: Easing = Easing(.quadInOut)) {
        self.setupHandler = setupHandler
        self.performHandler = performHandler
        self.performAtTimeHandler = performAtTimeHandler
        self.cancelHandler = cancelHandler
        self.completionHandler = completionHandler
        super.init(views: views, easing: easing)
        self.startingAt = startingAt
        self.endingAt = endingAt
    }
    
    required public init(views: [UIView?], easing: Easing) {
        fatalError("init(views:easingFunction:) has not been implemented")
    }
    
    open override func setupAnimation(context: AnimationContext) {
        super.setupAnimation(context: context)
        enumerateViews { (v, idx) in setupHandler?(v, idx, context) }
    }
    
    open override func performAnimations(context: AnimationContext) {
        super.performAnimations(context: context)
        enumerateViews { (v, idx) in performHandler?(v, idx, context) }
    }
    
    open override func performAnimations(at time: TimeInterval, context: AnimationContext) {
        super.performAnimations(at: time, context: context)
        enumerateViews { (v, idx) in performAtTimeHandler?(time, v, idx, context) }
    }
    
    open override func cancelAnimation(context: AnimationContext) {
        super.cancelAnimation(context: context)
        enumerateViews { (v, idx) in cancelHandler?(v, idx, context) }
    }
    
    open override func completeAnimation(context: AnimationContext) {
        enumerateViews { (v, idx) in completionHandler?(v, idx, context) }
        super.completeAnimation(context: context)
    }
}

@available(iOS 10.0, *)
class HideUntilAnimationCompletedAnimator: BaseAnimator {
    
    override var useNativeViews: Bool { get { return true } set {} }

    required init(views: [UIView?]) {
        super.init(views: views)
    }
    
    required public init(views: [UIView?], easing: Easing) {
        fatalError("init(views:easingFunction:) has not been implemented")
    }
    
    open override func setupAnimation(context: AnimationContext) {
        super.setupAnimation(context: context)
        enumerateViews { (v, _) in v.isHidden = true }
    }
    
    open override func completeAnimation(context: AnimationContext) {
        enumerateViews { (v, _) in v.isHidden = false }
        super.completeAnimation(context: context)
    }
    
    open override func cancelAnimation(context: AnimationContext) {
        enumerateViews { (v, _) in v.isHidden = false }
        super.cancelAnimation(context: context)
    }
}

@available(iOS 10.0, *)
class HideUntilFullAnimationCompletedAnimator: BaseAnimator {
    
    override var useNativeViews: Bool { get { return true } set {} }

    required init(views: [UIView?]) {
        super.init(views: views)
    }
    
    required public init(views: [UIView?], easing: Easing) {
        fatalError("init(views:easingFunction:) has not been implemented")
    }
    
    open override func setupAnimation(context: AnimationContext) {
        super.setupAnimation(context: context)
        enumerateViews { (v, _) in v.isHidden = true }
    }
    
    open override func completeAnimation(context: AnimationContext) {
        if isReverse {
            enumerateViews { (v, _) in v.isHidden = false }
        }
        super.completeAnimation(context: context)
    }
    
    open override func cancelAnimation(context: AnimationContext) {
        enumerateViews { (v, _) in v.isHidden = false }
        super.cancelAnimation(context: context)
    }
}

@available(iOS 10.0, *)
open class InitiallyTranslatedAnimator: BaseAnimator {
    var initialTransforms = [UIView: CGAffineTransform]()
    var initialTranslations = [UIView: CGVector]()

    required public init(views: [UIView?], translations: [CGVector], easing: Easing = Easing(.quadInOut)) {
        for idx in 0..<translations.count {
            guard idx < views.count, let v = views[idx] else { continue }
            initialTranslations[v] = translations[idx]
        }
        super.init(views: views, easing: easing)
    }
    
    required public init(views: [UIView?], easing: Easing) {
        super.init(views: views, easing: easing)
    }
    
    open override func setupAnimation(context: AnimationContext) {
        super.setupAnimation(context: context)
        enumerateViews { (v, _) in
            if !isReverse {
                initialTransforms[v] = v.transform
                let translation = resolveInitialTranslation(view: v, container: context.containerView)
                v.transform = v.transform.translatedBy(x: translation.dx, y: translation.dy)
            }
        }
    }
    
    private func resolveInitialTranslation(view: UIView, container: UIView) -> CGVector {
        if let translation = initialTranslations[view] {
            return translation
        }
        let translation = initialTranslation(for: view, container: container)
        initialTranslations[view] = translation
        return translation
    }
    
    func initialTranslation(for view: UIView, container: UIView) -> CGVector {
        // subclass
        return CGVector(dx: 0.0, dy: 0.0)
    }
    
    open override func performAnimations(context: AnimationContext) {
        super.performAnimations(context: context)
        enumerateViews { (v, _) in
            var transform = initialTransforms[v] ?? .identity
            if isReverse {
                let translation = resolveInitialTranslation(view: v, container: context.containerView)
                transform = transform.translatedBy(x: translation.dx, y: translation.dy)
            }
            v.transform = transform
        }
    }
    
    func translation(at time: TimeInterval, for view: UIView, container: UIView, isReversed: Bool) -> CGVector {
        let initialTranslation = resolveInitialTranslation(view: view, container: container)
        let start: CGVector = isReversed ? .zero : initialTranslation
        let end: CGVector = isReversed ? initialTranslation : .zero
        let result = Interpolate.value(start: start, end: end, progress: time)
        return result
    }
    
    open override func performAnimations(at time: TimeInterval, context: AnimationContext) {
        super.performAnimations(at: time, context: context)
        enumerateViews { (v, _) in
            var transform = initialTransforms[v] ?? .identity
            let translation = self.translation(at: time, for: v, container: context.containerView, isReversed: isReverse)
            transform = transform.translatedBy(x: translation.dx, y: translation.dy)
            v.transform = transform
        }
    }
    
    open override func cancelAnimation(context: AnimationContext) {
        enumerateViews { (v, _) in v.transform = initialTransforms[v] ?? .identity }
        super.cancelAnimation(context: context)
    }
}

@available(iOS 10.0, *)
class PresentFromAboveAnimator: InitiallyTranslatedAnimator {
    override func initialTranslation(for view: UIView, container: UIView) -> CGVector {
        let result = CGVector(dx: 0.0, dy: -(view.convert(view.bounds, to: container).maxY))
        return result
    }
}

@available(iOS 10.0, *)
class PresentFromLeftAnimator: InitiallyTranslatedAnimator {
    override func initialTranslation(for view: UIView, container: UIView) -> CGVector {
        return CGVector(dx: -(view.convert(view.bounds, to: container).maxX), dy: 0.0)
    }
}

@available(iOS 10.0, *)
class PresentFromBelowAnimator: InitiallyTranslatedAnimator {
    override func initialTranslation(for view: UIView, container: UIView) -> CGVector {
        return CGVector(dx: 0.0, dy: container.bounds.height - (view.convert(view.bounds, to: container).minY))
    }
}

@available(iOS 10.0, *)
class PresentFromRightAnimator: InitiallyTranslatedAnimator {
    override func initialTranslation(for view: UIView, container: UIView) -> CGVector {
        let result = CGVector(dx: container.bounds.width - (view.convert(view.bounds, to: container).minX), dy: 0.0)
        return result
    }
}

@available(iOS 10.0, *)
class FrameAnimator: BaseAnimator {
    var startFrame = CGRect.zero
    var endFrame = CGRect.zero

    required init(view: UIView, startFrame: CGRect, endFrame: CGRect, easing: Easing = Easing(.quadInOut)) {
        super.init(views: [view], easing: easing)
        self.startFrame = startFrame
        self.endFrame = endFrame
    }
    
    required public init(views: [UIView?], easing: Easing) {
        fatalError("init(views:easing:) has not been implemented")
    }
    
    open override func setupAnimation(context: AnimationContext) {
        super.setupAnimation(context: context)
        enumerateViews { (v, idx) in v.frame = isReverse ? endFrame : startFrame }
    }
    
    open override func performAnimations(context: AnimationContext) {
        super.performAnimations(context: context)
        enumerateViews { (v, idx) in v.frame = isReverse ? startFrame : endFrame }
    }
    
    open override func cancelAnimation(context: AnimationContext) {
        enumerateViews { (v, idx) in v.frame = isReverse ? endFrame : startFrame }
        super.cancelAnimation(context: context)
    }
    
    open override func performAnimations(at time: TimeInterval, context: AnimationContext) {
        super.performAnimations(at: time, context: context)
        enumerateViews { (v, idx) in
            let startFrame = isReverse ? self.endFrame : self.startFrame
            let endFrame = isReverse ? self.startFrame : self.endFrame
            v.frame = Interpolate.value(start: startFrame, end: endFrame, progress: time)
        }
    }
}

@available(iOS 10.0, *)
class CornerRadiusAnimator: BaseAnimator {
    var start: CGFloat = 0.0
    var end: CGFloat = 0.0
    
    required init(view: UIView, start: CGFloat, end: CGFloat, easing: Easing = Easing(.quadInOut)) {
        super.init(views: [view], easing: easing)
        self.start = start
        self.end = end
    }
    
    required public init(views: [UIView?], easing: Easing) {
        fatalError("init(views:easing:) has not been implemented")
    }
    
    open override func setupAnimation(context: AnimationContext) {
        super.setupAnimation(context: context)
        enumerateViews { (v, idx) in v.layer.cornerRadius = isReverse ? end : start }
    }
    
    open override func performAnimations(context: AnimationContext) {
        super.performAnimations(context: context)
        enumerateViews { (v, idx) in v.layer.cornerRadius = isReverse ? start : end }
    }
    
    open override func cancelAnimation(context: AnimationContext) {
        enumerateViews { (v, idx) in v.layer.cornerRadius = isReverse ? end : start }
        super.cancelAnimation(context: context)
    }
    
    open override func performAnimations(at time: TimeInterval, context: AnimationContext) {
        super.performAnimations(at: time, context: context)
        enumerateViews { (v, idx) in
            let startFrame = isReverse ? self.end : self.start
            let endFrame = isReverse ? self.start : self.end
            v.layer.cornerRadius = Interpolate.value(start: start, end: end, progress: time)
        }
    }
}

@available(iOS 10.0, *)
class FadeOutAnimator: BaseAnimator {
    var initialAlphas = [CGFloat]()

    required init(views: [UIView?], easing: Easing = Easing(.quadInOut)) {
        super.init(views: views, easing: easing)
        for v in views {
            initialAlphas.append(v?.alpha ?? 0.0)
        }
    }
    
    open override func setupAnimation(context: AnimationContext) {
        super.setupAnimation(context: context)
        enumerateViews { (v, idx) in v.alpha = isReverse ? 0.0 : initialAlphas[idx] }
    }
    
    open override func performAnimations(context: AnimationContext) {
        super.performAnimations(context: context)
        enumerateViews { (v, idx) in v.alpha = isReverse ? initialAlphas[idx] : 0.0 }
    }
    
    open override func cancelAnimation(context: AnimationContext) {
        enumerateViews { (v, idx) in v.alpha = initialAlphas[idx] }
        super.cancelAnimation(context: context)
    }
    
    open override func performAnimations(at time: TimeInterval, context: AnimationContext) {
        super.performAnimations(at: time, context: context)
        enumerateViews { (v, idx) in
            let startAlpha = isReverse ? 0.0 : initialAlphas[idx]
            let endAlpha = isReverse ? initialAlphas[idx] : 0.0
            v.alpha = Interpolate.value(start: startAlpha, end: endAlpha, progress: time)
        }
    }
}

@available(iOS 10.0, *)
class FadeInAnimator: BaseAnimator {
    var startAlphas = [UIView: CGFloat]()
    var endAlphas = [UIView: CGFloat]()
    
    open override func setupAnimation(context: AnimationContext) {
        super.setupAnimation(context: context)
        enumerateViews { (v, _) in
            if isReverse {
                startAlphas[v] = v.alpha
                endAlphas[v] = 0.0
            } else {
                assert(!context.isViewProcessed(v, animator: self), "view included in multiple fadeIn animations: \(v)")
                startAlphas[v] = 0.0
                endAlphas[v] = v.alpha
            }
            context.markViewProcessed(v, animator: self)
        }
        if !isReverse {
            enumerateViews { (v, _) in v.alpha = 0.0 }
        }
    }
    
    open override func performAnimations(context: AnimationContext) {
        super.performAnimations(context: context)
        enumerateViews { (v, _) in v.alpha = endAlphas[v]! }
    }
    
    open override func cancelAnimation(context: AnimationContext) {
        enumerateViews { (v, _) in v.alpha = 0.0 }
        super.cancelAnimation(context: context)
    }
    
    open override func performAnimations(at time: TimeInterval, context: AnimationContext) {
        super.performAnimations(at: time, context: context)
        enumerateViews { (v, idx) in v.alpha = Interpolate.value(start: startAlphas[v]!, end: endAlphas[v]!, progress: time) }
    }
}

@available(iOS 10.0, *)
class TransformAnimator: BaseAnimator {
    var initialTransforms = [UIView: CGAffineTransform]()
    let startAngle: CGFloat
    let startScale: CGPoint
    let startTranslation: CGVector
    let endAngle: CGFloat
    let endScale: CGPoint
    let endTranslation: CGVector
    let applyToInitialTransforms: Bool

    required init(views: [UIView?], applyToInitialTransforms: Bool = false, startScale: CGPoint = UIView.unscaled, startAngle: CGFloat = 0.0, startTranslation: CGVector = .zero, endScale: CGPoint = UIView.unscaled, endAngle: CGFloat = 0.0, endTranslation: CGVector = .zero, easing: Easing = Easing(.quadInOut)) {
        self.startAngle = startAngle
        self.startScale = startScale
        self.startTranslation = startTranslation
        self.endAngle = endAngle
        self.endScale = endScale
        self.endTranslation = endTranslation
        self.applyToInitialTransforms = applyToInitialTransforms
        super.init(views: views, easing: easing)
        enumerateViews { (v, idx) in initialTransforms[v] = v.transform }
    }
    
    required public init(views: [UIView?], easing: Easing) {
        fatalError("init(views:easingFunction:) has not been implemented")
    }
    
    open override func setupAnimation(context: AnimationContext) {
        super.setupAnimation(context: context)
        enumerateViews { (v, _) in
            let transform = applyToInitialTransforms ? initialTransforms[v] ?? .identity : .identity
            let angle = isReverse ? endAngle : startAngle
            let scale = isReverse ? endScale : startScale
            let translation = isReverse ? endTranslation : startTranslation
            v.transform = transform.scaledBy(x: scale.x, y: scale.y).rotated(by: angle).translatedBy(x: translation.dx, y: translation.dy)
        }
    }
    
    open override func cancelAnimation(context: AnimationContext) {
        enumerateViews { (v, _) in v.transform = initialTransforms[v] ?? .identity }
        super.cancelAnimation(context: context)
    }
    
    open override func performAnimations(context: AnimationContext) {
        super.performAnimations(context: context)
        enumerateViews { (v, _) in
            let transform = applyToInitialTransforms ? initialTransforms[v] ?? .identity : .identity
            let angle = isReverse ? startAngle : endAngle
            let scale = isReverse ? startScale : endScale
            let translation = isReverse ? startTranslation : endTranslation
            v.transform = transform.scaledBy(x: scale.x, y: scale.y).rotated(by: angle).translatedBy(x: translation.dx, y: translation.dy)
        }
    }
    
    open override func performAnimations(at time: TimeInterval, context: AnimationContext) {
        super.performAnimations(at: time, context: context)
        enumerateViews { (v, _) in
            let transform = applyToInitialTransforms ? initialTransforms[v] ?? .identity : .identity
            let startAngle = isReverse ? self.endAngle : self.startAngle
            let endAngle = isReverse ? self.startAngle : self.endAngle
            let angle = Interpolate.value(start: startAngle, end: endAngle, progress: time).truncatedSmallValue
            let startScale = isReverse ? self.endScale : self.startScale
            let endScale = isReverse ? self.startScale : self.endScale
            let scale = Interpolate.value(start: startScale, end: endScale, progress: time).truncatedSmallValue
            let startTranslation = isReverse ? self.endTranslation : self.startTranslation
            let endTranslation = isReverse ? self.startTranslation : self.endTranslation
            let translation = Interpolate.value(start: startTranslation, end: endTranslation, progress: time).truncatedSmallValue
            v.transform = transform.scaledBy(x: scale.x, y: scale.y).rotated(by: angle).translatedBy(x: translation.dx, y: translation.dy)
        }
    }
}

@available(iOS 10.0, *)
class ScalingFromToAnimator: BaseAnimator {
    let from: UIView?
    let to: UIView?
    var initialTranslations = (CGVector.zero, CGVector.zero)

    required init(from: UIView?, to: UIView?, easing: Easing = Easing(.quadInOut)) {
        self.from = from
        self.to = to
        super.init(easing: easing)
    }
    
    required public init(views: [UIView?], easing: Easing) {
        fatalError("init(views:easingFunction:) has not been implemented")
    }
    
    func _initialTranslations(context: AnimationContext) -> (CGVector, CGVector) {
        guard let from = from, let to = to else { return (CGVector.zero, CGVector.zero) }

        let scaleX = to.bounds.width / from.bounds.width
        let scaleY = to.bounds.height / from.bounds.height
        let sourceCenter = determineNatualCenter(for: from, to: context.containerView)
        let targetCenter = determineNatualCenter(for: to, to: context.containerView)
        let dx = targetCenter.x - sourceCenter.x
        let dy = targetCenter.y - sourceCenter.y

        let translation = CGVector(dx: dx, dy: dy)
        let scale = CGVector(dx: scaleX, dy: scaleY)
        return (translation, scale)
    }
    
    open override func setupAnimation(context: AnimationContext) {
        super.setupAnimation(context: context)
        if !isReverse {
            initialTranslations = _initialTranslations(context: context)
        }
    }
    
    open override func cancelAnimation(context: AnimationContext) {
        guard let from = from else {
            super.cancelAnimation(context: context)
            return
        }
        from.transform = .identity
        super.cancelAnimation(context: context)
    }

    open override func performAnimations(context: AnimationContext) {
        super.performAnimations(context: context)
        guard let from = from else { return }
        if isReverse {
            from.transform = .identity
        } else {
            let (translation, scale) = initialTranslations
            from.transform = from.transform.translatedBy(x: translation.dx, y: translation.dy).scaledBy(x: scale.dx, y: scale.dy)
        }        
    }
}

@available(iOS 10.0, *)
class TranslateCenterToAnimator: BaseAnimator {
    let targetView: UIView?
    
    private var targetCenter = CGPoint.zero
    private var sourceCenters = [UIView: CGPoint]()
    private var toTransforms = [UIView: CGAffineTransform]()

    required init(views: [UIView?], targetView: UIView?, easing: Easing = Easing(.quadInOut)) {
        self.targetView = targetView
        super.init(views: views, easing: easing)
    }
    
    required public init(views: [UIView?], easing: Easing) {
        fatalError("init(views:easingFunction:) has not been implemented")
    }

    open override func setupAnimation(context: AnimationContext) {
        super.setupAnimation(context: context)
        if !isReverse {
            targetCenter = determineNatualCenter(for: targetView, to: context.containerView)
            enumerateViews { (v, _) in
                self.sourceCenters[v] = determineNatualCenter(for: v, to: context.containerView)
            }
        }
    }
    
    open override func performAnimations(at time: TimeInterval, context: AnimationContext) {
        super.performAnimations(at: time, context: context)
        guard let _ = targetView else { return }
        enumerateViews { (v, _) in
            guard let sourceCenter = sourceCenters[v] else { return }
            let dx = targetCenter.x - sourceCenter.x
            let dy = targetCenter.y - sourceCenter.y
            if self.isReverse {
                let start = CGAffineTransform(translationX: dx, y: dy)
                v.transform = Interpolate.value(start: start, end: .identity, progress: time)
            } else {
                let end = CGAffineTransform(translationX: dx, y: dy)
                v.transform = Interpolate.value(start: .identity, end: end, progress: time)
            }
        }
    }
    
    open override func performAnimations(context: AnimationContext) {
        super.performAnimations(context: context)
        performAnimations(at: 1.0, context: context)
    }
    
    open override func cancelAnimation(context: AnimationContext) {
        enumerateViews { (v, _) in v.transform = .identity }
        super.cancelAnimation(context: context)
    }
}

@available(iOS 10.0, *)
class MorphingLabelAnimator: BaseAnimator {
    let from: UILabel?
    let to: UILabel?
    let isCrossFading: Bool

    private var fromSourceCenter = CGPoint.zero
    private var fromTargetCenter = CGPoint.zero
    private var scale: CGFloat = 1.0
    private var toTransform = CGAffineTransform.identity

    required init(from: UILabel?, to: UILabel?, isCrossFading: Bool, easing: Easing = Easing(.quadInOut)) {
        self.from = from
        self.to = to
        self.isCrossFading = isCrossFading
        super.init(easing: easing)
        determineScaleChange()
    }
    
    required public init(views: [UIView?], easing: Easing) {
        fatalError("init(views:easingFunction:) has not been implemented")
    }
    
    private func determineScaleChange() {
        guard let s1 = from?.attributedText, let s2 = to?.attributedText else { return }
        
        let fonts1 = s1.allFonts()
        let fonts2 = s2.allFonts()
        guard fonts1.count > 0, fonts2.count > 0 else { return }
        
        let font1 = fonts1.reduce(fonts1.first!) { (result, f) -> UIFont in return f.pointSize > result.pointSize ? f : result }
        let font2 = fonts2.reduce(fonts2.first!) { (result, f) -> UIFont in return f.pointSize > result.pointSize ? f : result }
        scale = font2.pointSize / font1.pointSize
    }
    
    open override func setupAnimation(context: AnimationContext) {
        super.setupAnimation(context: context)
        if isReverse {
            setupReverseFromAnimation()
            setupReverseToAnimation()
        } else {
            setupForwardFromAnimation(context: context)
            setupForwardToAnimation(context: context)
        }
    }
    
    open override func performAnimations(at time: TimeInterval, context: AnimationContext) {
        super.performAnimations(at: time, context: context)
        if isReverse {
            performFromReverseAnimations(at: time)
            performToReverseAnimations(at: time)
        } else {
            performFromForwardAnimations(at: time)
            performToForwardAnimations(at: time)
        }
    }

    open override func performAnimations(context: AnimationContext) {
        super.performAnimations(context: context)
        performAnimations(at: 1.0, context: context)
    }
    
    open override func cancelAnimation(context: AnimationContext) {
        guard let from = from, let to = to else {
            super.cancelAnimation(context: context)
            return
        }
        from.transform = .identity
        to.transform = .identity
        if isCrossFading {
            from.alpha = 1.0
            to.alpha = 0.0
        }
        super.cancelAnimation(context: context)
    }
    
    // MARK: From Label Animations
    
    private func setupForwardFromAnimation(context: AnimationContext) {
        guard let from = from, let to = to else { return }
        fromSourceCenter = determineNatualCenter(for: from, to: context.containerView)
        fromTargetCenter = determineNatualCenter(for: to, to: context.containerView)
    }
    
    private func setupReverseFromAnimation() {
    }
    
    private func performFromForwardAnimations(at time: TimeInterval) {
        let dx = fromTargetCenter.x - fromSourceCenter.x
        let dy = fromTargetCenter.y - fromSourceCenter.y
        let end = CGAffineTransform(translationX: dx, y: dy).scaledBy(x: scale, y: scale)
        from?.transform = Interpolate.value(start: .identity, end: end, progress: time)
    }
    
    private func performFromReverseAnimations(at time: TimeInterval) {
        let dx = fromTargetCenter.x - fromSourceCenter.x
        let dy = fromTargetCenter.y - fromSourceCenter.y
        let start = CGAffineTransform(translationX: dx, y: dy).scaledBy(x: scale, y: scale)
        from?.transform = Interpolate.value(start: start, end: .identity, progress: time)
    }
    
    // MARK: To Label Animations
    
    private func setupForwardToAnimation(context: AnimationContext) {
        guard let from = from, let to = to else { return }
        let initialCenter = determineNatualCenter(for: from, to: context.containerView)
        let finalCenter = determineNatualCenter(for: to, to: context.containerView)
        
        let dx = initialCenter.x - finalCenter.x
        let dy = initialCenter.y - finalCenter.y
        toTransform = CGAffineTransform(translationX: dx, y: dy).scaledBy(x: 1.0/scale, y: 1.0/scale)
        to.transform = toTransform
        
        if isCrossFading {
            to.alpha = 0.0
        }
    }
    
    private func setupReverseToAnimation() {
    }
    
    private func performToForwardAnimations(at time: TimeInterval) {
        to?.transform = Interpolate.value(start: toTransform, end: .identity, progress: time)
        if isCrossFading {
            let offsetTime = max(time - 0.5, 0.0)
            to?.alpha = Interpolate.value(start: 0.0, end: 2.0, progress: offsetTime)
        }
    }
    
    private func performToReverseAnimations(at time: TimeInterval) {
        to?.transform = Interpolate.value(start: .identity, end: toTransform, progress: time)
        if isCrossFading {
            let offsetTime = min(time + 0.5, 1.0)
            to?.alpha = Interpolate.value(start: 2.0, end: 0.0, progress: offsetTime)
        }
    }
}

@available(iOS 10.0, *)
class PresentFromSourceAnimator: BaseAnimator {
    let sourceView: UIView
    var sourcePos = CGPoint.zero
    var initialTransforms = [UIView: CGAffineTransform]()
    var initialTranslations = [UIView: CGVector]()

    required init(views: [UIView?], source: UIView, easing: Easing = Easing(.quadInOut)) {
        self.sourceView = source
        super.init(views: views, easing: easing)
    }
    
    required public init(views: [UIView?], easing: Easing) {
        fatalError("init(views:easingFunction:) has not been implemented")
    }
    
    open override func setupAnimation(context: AnimationContext) {
        super.setupAnimation(context: context)
        if !isReverse {
            self.sourcePos = determineNatualCenter(for: sourceView, to: context.containerView)
            enumerateViews { (v, _) in
                initialTransforms[v] = v.transform
                let translation = initialTranslation(for: v, container: context.containerView)
                v.transform = v.transform.translatedBy(x: translation.dx, y: translation.dy)
                initialTranslations[v] = (initialTranslation(for: v, container: context.containerView))
            }
        }
    }
    
    func initialTranslation(for view: UIView, container: UIView) -> CGVector {
        let pos = determineNatualCenter(for: view, to: container)
        return CGVector(dx: sourcePos.x - pos.x, dy: sourcePos.y - pos.y)
    }
    
    open override func cancelAnimation(context: AnimationContext) {
        enumerateViews { (v, _) in v.transform = initialTransforms[v] ?? .identity }
        super.cancelAnimation(context: context)
    }
    
    open override func performAnimations(context: AnimationContext) {
        super.performAnimations(context: context)
        enumerateViews { (v, _) in
            var transform = initialTransforms[v] ?? .identity
            if isReverse {
                let translation = initialTranslations[v] ?? .zero
                transform = transform.translatedBy(x: translation.dx, y: translation.dy)
            }
            v.transform = transform
            UIView.animate(withDuration: 1.0) {
                
            }
        }
    }
}
