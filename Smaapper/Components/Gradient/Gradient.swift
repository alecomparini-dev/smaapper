//
//  Gradient.swift
//  Smaapper
//
//  Created by Alessandro Comparini on 27/04/23.
//

import UIKit

class Gradient {
    
    enum Direction {
        case leftToRight
        case rightToLeft
        case topToBottom
        case bottomToTop
        case leftBottomToRightTop
        case leftTopToRightBottom
        case rightBottomToLeftTop
        case rightTopToLeftBottom
    }
    
    private let gradient = CAGradientLayer()
    private var component: UIView
    
    
//  MARK: - Initializers
    init(_ component: UIView) {
        self.component = component
        self.initialization()
    }

    
//  MARK: - Set Properties
    
    func setDirection(_ direction: Gradient.Direction) -> Self {
        
        return self
    }
    
    func setColor(_ colors: [UIColor]) -> Self {
        gradient.colors = colors.map { $0.cgColor }
        return self
    }
    
    func setAxialGradient(_ direction: Gradient.Direction ) -> Self {
        self.setGradientDirection(direction)
        self.setType(.axial)
        return self
    }
    
    func setConicGradient(_ startPoint: CGPoint) -> Self {
        self.setStartPoint(startPoint.x, startPoint.y)
        self.setType(.conic)
        return self
    }
    
    func setRadialGradient(_ startPoint: CGPoint) -> Self {
        self.setStartPoint(startPoint.x, startPoint.y)
        self.setType(.radial)
        return self
    }
    
    
    
//  MARK: - Apply Gradient
    func apply() -> Self {
        DispatchQueue.main.async() {
            self.applyGradient()
        }
        return self
    }
    
    
//  MARK: - Component Private Functions
    
    private func setGradientDirection(_ direction: Direction) {
        
        switch direction {
            case .leftToRight:
                setStartPoint(0.0, 0.5)
                setEndPoint(1.0, 0.5)
            
            case .rightToLeft:
                setStartPoint(1.0, 0.5)
                setEndPoint(0.0, 0.5)
            
            case .topToBottom:
                setStartPoint(0.5, 0.0)
                setEndPoint(0.5, 1.0)
            
            case .bottomToTop:
                setStartPoint(0.5, 1.0)
                setEndPoint(0.5, 0.0)
            
            case .leftBottomToRightTop:
                setStartPoint(0.0, 1.0)
                setEndPoint(1.0, 0.0)
            
            case .leftTopToRightBottom:
                setStartPoint(0.0, 0.0)
                setEndPoint(1.0, 1.0)
            
            case .rightBottomToLeftTop:
                setStartPoint(1.0, 1.0)
                setEndPoint(0.0, 0.0)
            
            case .rightTopToLeftBottom:
                setStartPoint(1.0, 0.0)
                setEndPoint(0.0, 1.0)
            
        }
        
    }
    
    
    private func initialization() {
        self.setGradientDirection(.leftToRight)
        self.setType(.axial)
    }
    
    private func configGradient() {
        component.backgroundColor = .clear
        component.layoutIfNeeded()
    }
    
    private func setGradientOnComponent() {
        component.layer.insertSublayer(gradient, at: 0)
    }
    
    private func applyGradient() {
        self.configGradient()
        gradient.frame = component.bounds
        let endY = 0 + component.frame.size.width / component.frame.size.height / 2
        gradient.endPoint = CGPoint(x: 0, y: endY)
        self.setGradientOnComponent()
    }
    
    
    private func setType(_ type: CAGradientLayerType) {
        gradient.type = type
    }
    
    private func setStartPoint(_ x: Double, _ y: Double) {
        gradient.startPoint = CGPoint(x: x, y: y)
    }
    
    private func setEndPoint(_ x: Double, _ y: Double) {
        gradient.endPoint = CGPoint(x: x, y: y)
    }
    
    
}