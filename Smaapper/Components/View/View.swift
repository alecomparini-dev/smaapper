//
//  View.swift
//  Smaapper
//
//  Created by Alessandro Comparini on 27/04/23.
//

import UIKit


class View: UIView {
    private var constraintBuilder: StartOfConstraintsFlow?
    
    init() {
        super.init(frame: .zero)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
//  MARK: - COMMON FUNCTIONS
//    func setGradient(_ gradient: (_ build: Gradient) -> Gradient) -> Self {
//        let _ = gradient(Gradient(self))
//        return self
//    }

//  MARK: - Constraints Area
    
    func setConstraints(_ builderConstraint: (_ build: StartOfConstraintsFlow) -> StartOfConstraintsFlow) -> Self {
        self.constraintBuilder = builderConstraint(StartOfConstraintsFlow(self))
        return self
    }
    
    func applyConstraint() {
        self.constraintBuilder?.applyConstraint()
    }
    
}
