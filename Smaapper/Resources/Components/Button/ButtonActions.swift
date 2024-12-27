//
//  ButtonActions.swift
//  Smaapper
//
//  Created by Alessandro Comparini on 26/05/23.
//

import UIKit


class ButtonActions: BaseActions {
    
    
    private let buttonBuilder: ButtonBuilder
    
    init(_ buttonBuilder: ButtonBuilder) {
        self.buttonBuilder = buttonBuilder
        super.init(self.buttonBuilder)
    }
    
    
//  MARK: - Action Area
    
    @discardableResult
    public func setTarget(_ target: Any, _ action: Selector , _ event: UIControl.Event) -> Self {
        self.buttonBuilder.view.addTarget(target, action: action, for: event )
        return self
    }
    
    
}
