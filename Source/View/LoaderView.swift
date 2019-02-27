//
//  LoaderView.swift
//  Nub
//
//  Created by Nick Bolton on 1/17/17.
//  Copyright © 2017 Pixelbleed Inc. All rights reserved.
//

import UIKit

public class LoaderView: BaseView {
    
    public static let shared = LoaderView(image: UIImage(named: "spinner"))
    
    private let backgroundView = UIView()
    private let progressImageView = UIImageView()
    private var isAnimating = false
    private var ignoringInteractionCount = 0
    
    private let rotationAnimationKey = "rotationAnimation"
    
    weak private var ownerView: UIView?
    
    required public init(image: UIImage?, backgroundColor: UIColor = .clear) {
        self.backgroundView.backgroundColor = backgroundColor
        self.progressImageView.image = image
        super.init(frame: .zero)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    var isVisible = false {
        didSet {
            if isVisible {
                show(in: self)
            } else {
                hide(from: self)
            }
        }
    }
    
    public func initializeSpinnerImage(_ image: UIImage, backgroundColor: UIColor) {
        progressImageView.image = image
        backgroundView.backgroundColor = backgroundColor
    }
    
    // MARK: Begin View Hierarchy Construction
    
    override public func initializeViews() {
        super.initializeViews()
        alpha = 0.0
        backgroundColor = .clear
        initializeBackgroundView()
        translatesAutoresizingMaskIntoConstraints = false
        progressImageView.translatesAutoresizingMaskIntoConstraints = false
    }
    
    override public func assembleViews() {
        super.assembleViews()
        addSubview(backgroundView)
        addSubview(progressImageView)
    }
    
    override public func constrainViews() {
        super.constrainViews()
        if let image = progressImageView.image {
            NSLayoutConstraint.activate([
                progressImageView.widthAnchor.constraint(equalToConstant: image.size.width),
                progressImageView.heightAnchor.constraint(equalToConstant: image.size.height),
                progressImageView.centerXAnchor.constraint(equalTo: centerXAnchor),
                progressImageView.centerYAnchor.constraint(equalTo: centerYAnchor),
                ])
            constrainBackgroundView()
        }
    }

    // MARK: Background View

    private func initializeBackgroundView() {
    }

    private func constrainBackgroundView() {
        NSLayoutConstraint.activate([
            backgroundView.widthAnchor.constraint(equalTo: widthAnchor),
            backgroundView.heightAnchor.constraint(equalTo: heightAnchor),
            backgroundView.centerXAnchor.constraint(equalTo: centerXAnchor),
            backgroundView.centerYAnchor.constraint(equalTo: centerYAnchor),
            ])
    }
    
    // MARK: End View Hierarchy Construction
    
    // MARK: Public
    
    public func show(in view: UIView, animated: Bool = true, ignoreInteractionEvents: Bool = true, animations: DefaultHandler? = nil, onCompletion: DefaultHandler? = nil) {
        ownerView = view
        if view != self {
            view.addSubview(self)
        }
        NSLayoutConstraint.activate([
            widthAnchor.constraint(equalTo: view.widthAnchor),
            heightAnchor.constraint(equalTo: view.heightAnchor),
            centerXAnchor.constraint(equalTo: view.centerXAnchor),
            centerYAnchor.constraint(equalTo: view.centerYAnchor),
            ])
        if ignoreInteractionEvents {
            ignoringInteractionCount += 1
            UIApplication.shared.beginIgnoringInteractionEvents()
        }
        startAnimation()
        updateTheme()
        UIView.animate(withDuration: animated ? ThemeManager.shared.currentTheme().defaultAnimationDuration : 0.0, animations: {
            self.alpha = 1.0
            animations?()
        }) { _ in
            onCompletion?()
        }
    }
    
    public func hide(from view: UIView, animated: Bool = true, animations: DefaultHandler? = nil, onCompletion: DefaultHandler? = nil) {
        guard ownerView == nil || view == ownerView || superview != nil else {
            animations?()
            onCompletion?()
            return
        }
        ownerView = nil
        DispatchQueue.main.asyncAfter(timeInterval: animated ? 0.1 : 0.0) {
            let duration = animated ? ThemeManager.shared.currentTheme().defaultAnimationDuration : 0.0
            UIView.animate(withDuration: duration, animations: {
                self.alpha = 0.0
                animations?()
            }) { _ in
                if self.ignoringInteractionCount > 0 {
                    self.ignoringInteractionCount -= 1
                    UIApplication.shared.endIgnoringInteractionEvents()
                }
                self.stopAnimation()
                if view != self {
                    self.removeFromSuperview()
                }
                onCompletion?()
            }
        }
    }
    
    public func clear() {
        ownerView = nil
    }
    
    // MARK: Helpers
    
    private func startAnimation() {
        
        guard !isAnimating else {
            return
        }
        
        isAnimating = true
        let fullSpinInterval: TimeInterval = 1.0
        
        let animation = CABasicAnimation(keyPath: "transform.rotation.z")
        animation.toValue = CGFloat(2.0 * Double.pi)
        animation.duration = fullSpinInterval
        animation.isCumulative = true
        animation.repeatCount = Float.greatestFiniteMagnitude
        
        progressImageView.layer.add(animation, forKey: rotationAnimationKey)
    }
    
    private func stopAnimation() {
        guard isAnimating else {
            return
        }
        isAnimating = false
        progressImageView.layer.removeAnimation(forKey: rotationAnimationKey)
    }
}
