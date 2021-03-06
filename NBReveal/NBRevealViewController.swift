//
//  NBRevealViewController.swift
//  NBReveal
//
//  Created by Nikhil on 20/10/17.
//  Copyright © 2017 Nikhil. All rights reserved.
//

import UIKit

class NBRevealViewController: UIViewController {
    weak var backController: UIViewController!
    weak var frontController: UIViewController!

    var transparentGestureView: UIView!
    var leftPaddingConstraint: NSLayoutConstraint!
    var transparentLeftPaddingConstraint: NSLayoutConstraint!
    
    var swipeMargin:(()-> CGFloat)?
    var transformFrontView: CGAffineTransform?
    
    private var _shouldAddShadows: Bool?
    var shouldAddShadows:Bool? {
        get {
            if let addshadows = _shouldAddShadows {
                return addshadows
            } else {
                return false
            }
        }
        
        set {
            _shouldAddShadows = newValue
            if _shouldAddShadows! == true {
                self.frontController?.view.layer.shadowColor = UIColor.black.cgColor
                self.frontController?.view.layer.shadowPath = UIBezierPath(rect: self.frontController.view.frame).cgPath
                self.frontController?.view.layer.shadowOpacity = 0.5
                self.frontController?.view.layer.shadowOffset = CGSize.zero
            }
        }
    }
    
    private var _shouldPan: Bool?
    var shouldPan: Bool? {
        set {
            _shouldPan = newValue
            if (newValue!) {
                addPanGesture()
            } else {
                addSwipeGesture()
            }
        }
        
        get {
            if let s = _shouldPan {
                return s
            } else {
                return false
            }
        }
    }
    
    var animationDuration:TimeInterval = 0.5
    
    func setup(withBackController backController:UIViewController, withFrontController frontController:UIViewController) {
        self.addChildViewController(backController)
        self.addChildViewController(frontController)
        self.backController = backController
        self.frontController = frontController
        
        self.view.addSubview(backController.view)
        self.view.addSubview(frontController.view)
        
        setupConstraints()
        
        transparentGestureView = UIView()
        view.addSubview(transparentGestureView)
        
        self.transparentLeftPaddingConstraint = transparentGestureView.leftAnchor.constraint(equalTo: self.view.leftAnchor)
        self.transparentLeftPaddingConstraint.isActive = true
        transparentGestureView.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
        transparentGestureView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
        transparentGestureView.widthAnchor.constraint(equalToConstant: 20).isActive = true
        transparentGestureView.translatesAutoresizingMaskIntoConstraints = false
        if (shouldPan!) {
            addPanGesture()
        } else {
            addSwipeGesture()
        }
        transparentGestureView.backgroundColor = .red
        transparentGestureView.alpha = 0.3
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
    }
    
    func setupConstraints() {
        
        self.backController.view.widthAnchor.constraint(equalTo: self.view.widthAnchor).isActive = true
        self.backController.view.heightAnchor.constraint(equalTo: self.view.heightAnchor).isActive = true
        self.backController.view.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
        
        leftPaddingConstraint = self.frontController.view.leftAnchor.constraint(equalTo: self.view.leftAnchor)
        leftPaddingConstraint.isActive = true
        
        self.backController.view.translatesAutoresizingMaskIntoConstraints = false
        self.frontController.view.translatesAutoresizingMaskIntoConstraints = false
        
        self.view.leftAnchor.constraint(equalTo: self.frontController.view.leftAnchor).isActive = true
        self.frontController.view.widthAnchor.constraint(equalTo: self.view.widthAnchor).isActive = true
        self.frontController.view.heightAnchor.constraint(equalTo: self.view.heightAnchor).isActive = true
        self.frontController.view.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
    }
    
    func addPanGesture() {
        let gesture = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(gesture:)))
        transparentGestureView.addGestureRecognizer(gesture)
    }
    
    func addSwipeGesture() {
        let gesture = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipeGesture(gesture:)))
        transparentGestureView.addGestureRecognizer(gesture)
        
        let leftGesture = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipeGesture(gesture:)))
        leftGesture.direction = .left
        transparentGestureView.addGestureRecognizer(leftGesture)
    }
    
    @objc func handlePanGesture(gesture: UIPanGestureRecognizer) {
        print("handle pan")
    }
    
    @objc func handleSwipeGesture(gesture: UISwipeGestureRecognizer) {
        if (gesture.direction == .right) {
            showBackViewController(withAnimation: true)
        } else if (gesture.direction == .left) {
            hideBackViewController(withAnimation: true)
        }
        
        print("swiping")
    }
    
    func showBackViewController(withAnimation shouldAnimate:Bool) {
        if self.leftPaddingConstraint.constant > 0 {
            return
        }
        let position = self.swipeMargin?() ?? self.view.frame.size.width - 100
        self.leftPaddingConstraint.constant = position
        self.transparentLeftPaddingConstraint.constant = position - transparentGestureView.frame.size.width
        
        if (shouldAnimate) {
            UIView.animate(withDuration: animationDuration, animations: {
                self.view.layoutIfNeeded()
                self.transparentGestureView.alpha = 1
                if let transform = self.transformFrontView {
                    self.frontController.view.transform = transform
                }
                if (self.shouldAddShadows ?? false) {
                    self.frontController.view.layer.shadowOpacity = 0.5
                }
            })
        } else {
            self.transparentGestureView.alpha = 1
            if let transform = self.transformFrontView {
                self.frontController.view.transform = transform
            }
            if (self.shouldAddShadows ?? false) {
                self.frontController.view.layer.shadowOpacity = 0.5
            }
            self.view.setNeedsLayout()
        }
    }
    
    func hideBackViewController(withAnimation shouldAnimate:Bool) {
        if self.leftPaddingConstraint.constant ==  0 {
            return
        }
        
        self.leftPaddingConstraint.constant = 0
        self.transparentLeftPaddingConstraint.constant = 0
        
        if (shouldAnimate) {
            UIView.animate(withDuration: animationDuration, animations: {
                self.view.layoutIfNeeded()
                self.transparentGestureView.alpha = 0.1
                self.frontController.view.transform = CGAffineTransform.init(scaleX: 1, y: 1)
                if (self.shouldAddShadows ?? false) {
                    self.frontController.view.layer.shadowOpacity = 0.0
                }
            })
        } else {
            self.view.setNeedsLayout()
            self.transparentGestureView.alpha = 0.1
            self.frontController.view.transform = CGAffineTransform.init(scaleX: 1, y: 1)
            if (self.shouldAddShadows ?? false) {
                self.frontController.view.layer.shadowOpacity = 0.0
            }
        }
    }
}
