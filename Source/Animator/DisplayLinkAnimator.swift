//
//  DisplayLinkAnimator.swift
//  Bedrock
//
//  Created by Nick Bolton on 9/12/16.
//  Copyright © 2016 Pixelbleed LLC All rights reserved.
//

import UIKit

@available(iOS 10.0, *)
public typealias AnimationClosure = ((_ percent: TimeInterval) -> Void)

@available(iOS 10.0, *)
public typealias AnimationCompletion = ((Bool) -> Void)

@available(iOS 10.0, *)
public class DisplayLinkAnimator: NSObject {

    var _totalDuration: TimeInterval = 0.0
    public var totalDuration: TimeInterval {
        get { return isSlowMotionEnabled ? 3.0 : _totalDuration }
        set { _totalDuration = newValue }
    }
    
    private var animations: Array<Animation> = []
    private var displayLink: CADisplayLink?
    private var startTime: TimeInterval = 0.0
    public var completion: AnimationCompletion?
    public var isTimingDebugEnabled = false
    public var isSlowMotionEnabled = false
    public var isInteractive = false
    private var lastInteractivePercent: CGFloat = 0.0
    private var isCanceling = false
    public var interactiveCompletionDuration: TimeInterval = 0.0
    private var didCallCompletionHandler = false
    
    private var tickTimestamps = [TimeInterval]()
    private var tickDurations = [TimeInterval]()
    private var lastTimestamp: TimeInterval = 0.0
    
    public var isPaused: Bool { get { return displayLink?.isPaused ?? false } set { displayLink?.isPaused = isPaused } }
    
    public var isRunning: Bool {
        if let displayLink = displayLink {
            return !displayLink.isPaused
        }
        return false
    }
    
    static public func animator(with duration: TimeInterval) -> DisplayLinkAnimator {
        let animator = DisplayLinkAnimator()
        animator.totalDuration = duration
        return animator
    }
    
    public func registerAnimation(startingAt: TimeInterval = 0.0, endingAt: TimeInterval = 1.0, easing: Easing = Easing(.quadInOut), closure: @escaping AnimationClosure) {
        
        let animation = Animation(startTime: startingAt, endTime: endingAt, easing: easing, closure: closure)
        animations.append(animation)
    }
    
    public func start() {
        guard !isInteractive else { return }
        _tearDownDisplayLink()
        startTime = CACurrentMediaTime()
        isCanceling = false
        didCallCompletionHandler = false
        lastTimestamp = Date.timeIntervalSinceReferenceDate
        tickTimestamps.removeAll()
        tickDurations.removeAll()
        _setupDisplayLink()
    }
    
    public func cancel() {
        _tearDownDisplayLink()
    }
    
    public func completeInteractive() {
        guard isInteractive else { return }
        startTime = 0.0
        isCanceling = false
        _setupDisplayLink()
    }
    
    public func cancelInteractive() {
        guard isInteractive else { return }
        startTime = 0.0
        isCanceling = true
        _setupDisplayLink()
    }
    
    public func update(percent percentIn: CGFloat) {
        let percent = min(max(percentIn, 0.0), 1.0)
        isCanceling = false
        lastInteractivePercent = percent
        for animation in animations {
            animation.closure(TimeInterval(percent))
        }
    }
    
    private func _setupDisplayLink() {
        displayLink = CADisplayLink(target: self, selector: #selector(_tickAnimation))
        displayLink?.add(to: RunLoop.main, forMode: .common)
        displayLink?.isPaused = false
    }
    
    private func _tearDownDisplayLink() {
        for i in 0..<tickTimestamps.count {
            print("\(tickTimestamps[i]):\t\(tickDurations[i])")
        }
        print("duration: \(totalDuration)")
        print("ticks: \(tickTimestamps.count)")
        displayLink?.isPaused = true
        displayLink?.invalidate()
        displayLink = nil
        tickTimestamps.removeAll()
    }

    @objc internal func _tickAnimation() {
        guard let displayLink = displayLink else { return }
        guard !displayLink.isPaused else { return }
        
        let now = Date.timeIntervalSinceReferenceDate
        tickTimestamps.append(now - lastTimestamp)
        lastTimestamp = now
        
        var duration = totalDuration
        
        if interactiveCompletionDuration > 0.0 {
            duration = interactiveCompletionDuration
        }

        if startTime == 0.0 {
            var startingPercentComplete = TimeInterval(lastInteractivePercent)
            if isCanceling {
                startingPercentComplete = 1.0 - startingPercentComplete
            }
            startTime = displayLink.timestamp - (startingPercentComplete * duration)
        }
        
        let elapsedTime = displayLink.timestamp - startTime

        var time = duration > 0.0 ? (elapsedTime) / duration : 1.0
        time = clamp(time, min: 0.0, max: 1.0)

        if isCanceling {
            time = 1.0 - time
        }
        
        let t1 = Date.timeIntervalSinceReferenceDate
        
        for animation in animations {
            let duration = animation.endTime - animation.startTime
            var animationTime = (time - animation.startTime) / duration
            animationTime = clamp(animationTime, min: 0.0, max: 1.0)
            var percent: TimeInterval = 0.0
            if lastInteractivePercent > 0.0 {
                if isCanceling {
                    percent = animation.easing.solveForTime(animationTime)
                } else {
                    percent = animation.easing.inverseSolveForTime(animationTime)
                }
            } else {
                percent = animation.easing.solveForTime(animationTime)
            }
            animation.closure(percent)
        }
        
        let animationsElapsedTime = Date.timeIntervalSinceReferenceDate - t1
        if isTimingDebugEnabled {
            DispatchQueue.global().async { Logger.shared.debug("animation tick took: \(animationsElapsedTime) s") }
        }
        
        if displayLink.timestamp + animationsElapsedTime > displayLink.targetTimestamp {
            DispatchQueue.global().async { Logger.shared.warning("animation tick took too long!! \(animationsElapsedTime)") }
        }
        
        tickDurations.append(Date.timeIntervalSinceReferenceDate - now)
        
        if (isCanceling && time <= 0.0) || (!isCanceling && time >= 1.0) {
            lastInteractivePercent = 0.0
            _tearDownDisplayLink()
            if !didCallCompletionHandler {
                didCallCompletionHandler = true
                completion?(!isCanceling)
            }
        }
    }
}

public struct Interpolate {
    
    static public func discreteValues<T>(_ values: [T], progress: Double) -> T? {
        if (values.count <= 0) {
            return nil
        }
        
        var index = lround((progress * Double(values.count)) - 0.5)
        index = min(values.count - 1, max(0, index))
        return values[index]
    }
    
    static public func value(start: CGFloat, end: CGFloat, progress: Double) -> CGFloat {
        return start * CGFloat(1.0 - progress) + end * CGFloat(progress)
    }

    static public func value(start: Int, end: Int, progress: Double) -> Int {
        return Int(round(Float(start) * Float(1.0 - progress) + Float(end) * Float(progress)))
    }

    static public func value(start: CGPoint, end: CGPoint, progress: Double) -> CGPoint {
        let x = value(start: start.x, end: end.x, progress: progress)
        let y = value(start: start.y, end: end.y, progress: progress)
        return CGPoint(x: x, y: y)
    }

    static public func value(start: CGSize, end: CGSize, progress: Double) -> CGSize {
        let w = value(start: start.width, end: end.width, progress: progress)
        let h = value(start: start.height, end: end.height, progress: progress)
        return CGSize(width: w, height: h)
    }

    static public func value(start: CGRect, end: CGRect, progress: Double) -> CGRect {
        let origin = value(start: start.origin, end: end.origin, progress: progress)
        let size = value(start: start.size, end: end.size, progress: progress)
        return CGRect(origin: origin, size: size)
    }

    static public func value(start: CGVector, end: CGVector, progress: Double) -> CGVector {
        let dx = value(start: start.dx, end: end.dx, progress: progress)
        let dy = value(start: start.dy, end: end.dy, progress: progress)
        return CGVector(dx: dx, dy: dy)
    }

    static public func value(start: UIOffset, end: UIOffset, progress: Double) -> UIOffset {
        let h = value(start: start.horizontal, end: end.horizontal, progress: progress)
        let v = value(start: start.vertical, end: end.vertical, progress: progress)
        return UIOffset(horizontal: h, vertical: v)
    }
    
    static public func value(start: CGAffineTransform, end: CGAffineTransform, progress: Double) -> CGAffineTransform {
        let a = value(start: start.a, end: end.a, progress: progress)
        let b = value(start: start.b, end: end.b, progress: progress)
        let c = value(start: start.c, end: end.c, progress: progress)
        let d = value(start: start.d, end: end.d, progress: progress)
        let tx = value(start: start.tx, end: end.tx, progress: progress)
        let ty = value(start: start.ty, end: end.ty, progress: progress)
        return CGAffineTransform(a: a, b: b, c: c, d: d, tx: tx, ty: ty)
    }
    
    static public func value(start: UIEdgeInsets, end: UIEdgeInsets, progress: Double) -> UIEdgeInsets {
        let t = value(start: start.top, end: end.top, progress: progress)
        let b = value(start: start.bottom, end: end.bottom, progress: progress)
        let l = value(start: start.left, end: end.left, progress: progress)
        let r = value(start: start.right, end: end.right, progress: progress)
        return UIEdgeInsets(top: t, left: l, bottom: b, right: r)
    }

    static public func value(start: UIColor, end: UIColor, progress: Double) -> UIColor {
        var startHue: CGFloat = 0.0
        var startBrightness: CGFloat = 0.0
        var startSaturation: CGFloat = 0.0
        var startHSBAlpha: CGFloat = 0.0
        var endHue: CGFloat = 0.0
        var endBrightness: CGFloat = 0.0
        var endSaturation: CGFloat = 0.0
        var endHSBAlpha: CGFloat = 0.0
        var isHSBColorSpace = start.getHue(&startHue, saturation: &startSaturation, brightness: &startBrightness, alpha: &startHSBAlpha)
        isHSBColorSpace = isHSBColorSpace && end.getHue(&endHue, saturation: &endSaturation, brightness: &endBrightness, alpha: &endHSBAlpha)
    
        if isHSBColorSpace {
            let hue = value(start: startHue, end: endHue, progress: progress)
            let saturation = value(start: startSaturation, end: endSaturation, progress: progress)
            let brightness = value(start: startBrightness, end: endBrightness, progress: progress)
            let alpha = value(start: startHSBAlpha, end: endHSBAlpha, progress: progress)
            return UIColor(hue: hue, saturation: saturation, brightness: brightness, alpha: alpha)
        }
        
        var startRed: CGFloat = 0.0
        var startGreen: CGFloat = 0.0
        var startBlue: CGFloat = 0.0
        var startRGBAlpha: CGFloat = 0.0
        var endRed: CGFloat = 0.0
        var endGreen: CGFloat = 0.0
        var endBlue: CGFloat = 0.0
        var endRGBAlpha: CGFloat = 0.0
        
        var isRGBColorSpace = start.getRed(&startRed, green: &startGreen, blue: &startBlue, alpha: &startRGBAlpha)
        isRGBColorSpace = isRGBColorSpace && end.getRed(&endRed, green: &endGreen, blue: &endBlue, alpha: &endRGBAlpha)
        
        if isRGBColorSpace {
            let red = value(start: startRed, end: endRed, progress: progress)
            let green = value(start: startGreen, end: endGreen, progress: progress)
            let blue = value(start: startBlue, end: endBlue, progress: progress)
            let alpha = value(start: startRGBAlpha, end: endRGBAlpha, progress: progress)
            return UIColor(red: red, green: green, blue: blue, alpha: alpha)
        }
    
        var startWhite: CGFloat = 0.0
        var startGrayscaleAlpha: CGFloat = 0.0
        var endWhite: CGFloat = 0.0
        var endGrayscaleAlpha: CGFloat = 0.0
        var isGrayscaleColorSpace = start.getWhite(&startWhite, alpha: &startGrayscaleAlpha)
        isGrayscaleColorSpace = isGrayscaleColorSpace && end.getWhite(&endWhite, alpha: &endGrayscaleAlpha)
        if isGrayscaleColorSpace {
            let white = value(start: startWhite, end: endWhite, progress: progress)
            let alpha = value(start: startGrayscaleAlpha, end: endGrayscaleAlpha, progress: progress)
            return UIColor(white: white, alpha: alpha)
        }
    
        assert(false, "Cannot interpolate between two UIColors in different color spaces.")
        return start
    }    
}

@available(iOS 10.0, *)
private struct Animation {
    var closure: AnimationClosure
    var startTime: TimeInterval = 0.0
    var endTime: TimeInterval = 0.0
    var easing: Easing
    
    init(startTime: TimeInterval, endTime: TimeInterval, easing: Easing, closure: @escaping AnimationClosure) {
        self.startTime = startTime
        self.endTime = endTime
        self.easing = easing
        self.closure = closure
    }
}
