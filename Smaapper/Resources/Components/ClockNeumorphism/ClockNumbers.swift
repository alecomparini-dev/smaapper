//
//  ClockNumbers.swift
//  Smaapper
//
//  Created by Alessandro Comparini on 19/05/23.
//

import UIKit


class ClockNumbers: View {
    
    private var weight: CGFloat = 5
    private var neumorphism: NeumorphismBuilder?
    private var number: Int = 0
    
    private let hasLeftTopStroke = [4,5,6,8,9,0]
    private let hasLeftBottomStroke = [2,6,8,0]
    private let hasRightTopStroke = [1,2,3,4,7,8,9,0]
    private let hasRightBottomStroke = [1,3,4,5,6,7,8,9,0]
    private let hasTopMiddleStroke = [2,3,5,7,8,9,0]
    private let hasMiddleStroke = [2,3,4,5,6,8,9]
    private let hasBottomMiddleStroke = [2,3,5,6,8,0]
    
    
    init(number: Int, weight: CGFloat = 5) {
        self.number = number
        self.weight = weight
        super.init()
        self.initialization()
    }
    
    override init() {
        super.init()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func initialization() {
        addElement()
        configConstraints()
    }
    
    
//  MARK: - STACKS
    lazy var stackLeft: StackBuilder = {
        let st = StackBuilder()
            .setAxis(.vertical)
            .setAlignment(.fill)
            .setDistribution(.fillEqually)
            .setSpacing(4)
        return st
    }()
    
    lazy var stackMiddle: StackBuilder = {
        let st = StackBuilder()
            .setAxis(.vertical)
            .setDistribution(.fillProportionally)
        return st
    }()
    
    lazy var stackRight: StackBuilder = {
        let st = StackBuilder()
            .setAxis(.vertical)
            .setAlignment(.fill)
            .setDistribution(.fillEqually)
            .setSpacing(4)
        return st
    }()
    
    
//  MARK: - LEFT STROKES
    
    lazy var leftTopStroke: ViewBuilder = {
        return (hasLeftTopStroke.contains(number)) ? createView(true) : ViewBuilder()
    }()
    
    lazy var leftBottomStroke: ViewBuilder = {
        return (hasLeftBottomStroke.contains(number)) ? createView(true) : ViewBuilder()
    }()
    

//  MARK: - MIDDLE STROKE
    lazy var topMiddleStrokeView: ViewBuilder = { return createView(false) }()
    
    lazy var middleStrokeView: ViewBuilder = { return createView(false) }()
    
    lazy var middleBottomView: ViewBuilder = { return createView(false) }()
    
    lazy var topMiddleStroke: ViewBuilder = { return (hasTopMiddleStroke.contains(number)) ? createView(true) : ViewBuilder() }()
    
    lazy var middleStroke: ViewBuilder = { return (hasMiddleStroke.contains(number)) ? createView(true) : ViewBuilder() }()
    
    lazy var bottomMiddleStroke: ViewBuilder = { return (hasBottomMiddleStroke.contains(number)) ? createView(true) : ViewBuilder() }()
    

//  MARK: - RIGHT STROKE
    
    lazy var rightTopStroke: ViewBuilder = {
        return (hasRightTopStroke.contains(number)) ? createView(true) : ViewBuilder()
    }()
    
    lazy var rightBottomStroke: ViewBuilder = {
        return (hasRightBottomStroke.contains(number)) ? createView(true) : ViewBuilder()
    }()
    
    
//  MARK: - Private Functions Area
    
    private func configNeumorphism(_ component: UIView, _ lightPosition: NeumorphismBuilder.LightPosition = .leftTop) {
        NeumorphismBuilder(component)
            .setReferenceColor(Theme.shared.currentTheme.surfaceContainerHigh)
            .setShape(.concave)
            .setLightPosition(lightPosition)
            .setIntensity(to:.light,percent: 50)
            .setIntensity(to:.dark,percent: 100)
            .setBlur(to:.light, percent: 0)
            .setBlur(to:.dark, percent: 5)
            .setDistance(to:.light, percent: 3)
            .setDistance(to:.dark, percent: 10)
            .apply()
    }
    
    private func addElement() {
        addStackLeft()
        addStackMiddle()
        addStackRight()
    }
    
    private func addStackLeft() {
        stackLeft.add(insideTo: self)
        leftTopStroke.add(insideTo: stackLeft.view)
        leftBottomStroke.add(insideTo: stackLeft.view)
    }

    private func addStackMiddle() {
        stackMiddle.add(insideTo: self)
        topMiddleStrokeView.add(insideTo: stackMiddle.view)
        middleStrokeView.add(insideTo: stackMiddle.view)
        middleBottomView.add(insideTo: stackMiddle.view)
        topMiddleStroke.add(insideTo: topMiddleStrokeView.view)
        middleStroke.add(insideTo: middleStrokeView.view)
        bottomMiddleStroke.add(insideTo: middleBottomView.view)
    }
    
    private func addStackRight(){
        stackRight.add(insideTo: self)
        rightTopStroke.add(insideTo: stackRight.view)
        rightBottomStroke.add(insideTo: stackRight.view)
    }
    
    private func configConstraints() {
        configStackLeftConstraints()
        configStackMiddleConstraints()
        configStackRightConstraints()
        configTopMiddleStrokeConstraints()
        configMiddleStrokeConstraints()
        configBottomMiddleStrokeConstraints()
    }
    
    private func configStackLeftConstraints() {
        stackLeft.setConstraints({ build in
            build
                .setTop.setBottom.equalToSuperView(1)
                .setLeading.equalToSuperView
                .setWidth.equalToConstant(weight)
                .apply()
        })
    }
    
    
    private func configStackMiddleConstraints() {
        stackMiddle.setConstraints({ build in
            build
                .setTop.setBottom.equalToSuperView
                .setLeading.equalTo(stackLeft.view, .trailing, 0)
                .setTrailing.equalTo(stackRight.view, .leading, 0)
                .apply()
        })
    }
    
    private func configStackRightConstraints() {
        stackRight.setConstraints({ build in
            build
                .setTop.setBottom.equalToSuperView(1)
                .setTrailing.equalToSuperView
                .setWidth.equalToConstant(weight)
                .apply()
        })
    }
    
    private func configTopMiddleStrokeConstraints() {
        topMiddleStroke.setConstraints { build in
            build
                .setTop.equalToSuperView
                .setLeading.equalToSuperView
                .setTrailing.equalToSuperView
                .setHeight.equalToConstant(weight/1.4)
                .apply()
        }
    }
    
    private func configMiddleStrokeConstraints() {
        middleStroke.setConstraints({ build in
            build
                .setVerticalAlignmentY.equalToSafeArea
                .setLeading.equalToSuperView
                .setTrailing.equalToSuperView
                .setHeight.equalToConstant(weight/2)
                .apply()
        })
    }
    
    private func configBottomMiddleStrokeConstraints() {
        bottomMiddleStroke.setConstraints({ build in
            build
                .setBottom.equalToSuperView
                .setTrailing.equalToSuperView(calculateTrailing())
                .setLeading.equalToSuperView(calculateLeading())
                .setHeight.equalToConstant(weight/1.4)
                .apply()
        })
    }
    
    private func createView(_ withNeumorphism: Bool, _ lightPosition: NeumorphismBuilder.LightPosition = .leftTop) -> ViewBuilder {
        let v = ViewBuilder()
        if withNeumorphism {
            configNeumorphism(v.view, lightPosition)
        }
        return v
    }
    
    private func calculateLeading() -> CGFloat {
        if self.number == 5 {
            return -weight/1.5
        }
        return 0
    }
    
    private func calculateTrailing() -> CGFloat {
        if self.number == 2 {
            return weight/1.5
        }
        return 0
    }
    
}
