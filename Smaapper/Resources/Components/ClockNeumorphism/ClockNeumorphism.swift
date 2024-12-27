//
//  ClockNeumorphism.swift
//  Smaapper
//
//  Created by Alessandro Comparini on 19/05/23.
//

import UIKit


class ClockNeumorphism: ViewBuilder {
    
    enum Weight {
        case ultraLight
        case thin
        case light
        case regular
        case medium
        case semibold
        case bold
        case heavy
        case black
    }
    
    private var timer: DispatchSourceTimer?
    private var weight: CGFloat = 4
    private var enabledDay: Bool = false
    private var hour1: Int = 0
    private var hour2: Int = 0
    private var minute1: Int = 0
    private var minute2: Int = 0
    
    override init() {
        super.init()
        self.initialization()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func initialization() {
        addElements()
        configConstraints()
        startClock()
    }
    
    lazy var stackHours: StackBuilder = {
        let st = StackBuilder()
            .setAxis(.horizontal)
            .setDistribution(.fillEqually)
            .setSpacing(8)
        return st
    }()
    
    lazy var stackMinutes: StackBuilder = {
        let st = StackBuilder()
            .setAxis(.horizontal)
            .setDistribution(.fillEqually)
            .setSpacing(8)
        return st
    }()
    
    lazy var day: LabelBuilder = {
        let label = LabelBuilder()
            .setFont(UIFont.systemFont(ofSize: 14, weight: .thin))
            .setColor(Theme.shared.currentTheme.primary)
            .setTextAlignment(.right)
            .setConstraints { build in
                build
                    .setTop.equalTo(stackMinutes.view, .bottom, 5)
                    .setLeading.equalToSuperView(10)
                    .setTrailing.equalToSuperView(2)
            }
        return label
    }()
    
    lazy var twoPoints: ViewBuilder = {
        let view = ViewBuilder()
        
        let stack = StackBuilder()
            .setAxis(.vertical)
            .setDistribution(.fillEqually)
            .view
    
        stack.add(insideTo: view.view)
        stack.makeConstraints { make in
            make
                .setPin.equalToSuperView
                .apply()
        }
        let topView = ViewBuilder()
        let middleView = ViewBuilder()
        let bottomView = ViewBuilder()
        
        topView.add(insideTo: stack)
        middleView.add(insideTo: stack)
        bottomView.add(insideTo: stack)
    
        DispatchQueue.main.async {
            let points = self.createTwoPoints(middleView.view.frame.height)
            points.add(insideTo: middleView.view)
            points.makeConstraints { make in
                make
                    .setPin.equalToSuperView
                    .apply()
            }
        }
        return view
    }()
    
    
//  MARK: - SET Properties
    @discardableResult
    func setWeight(_ weight: CGFloat) -> Self {
        self.weight = weight
        return self
    }
    
    @discardableResult
    func setEnabledDay(_ enabled: Bool) -> Self {
        self.enabledDay = enabled
        return self
    }
    
    
//  MARK: - Private Function Area
    
    // TODO: - CREATE METHOD START OR SHOW AND UPDATE ONLY WHEN NUMBER CHANGES
    private func startClock() {
        updateClock()
        timer = DispatchSource.makeTimerSource()
        
        timer?.schedule(deadline: .now(), repeating: .seconds(1))
        timer?.setEventHandler { [weak self ] in
            DispatchQueue.main.async {
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "ss"
                if dateFormatter.string(from: Date()) == "00" {
                    self?.updateClock()
                }
            }
        }
        timer?.resume()
    }
    
    private func updateClock() {
        removeSubviews()
        let hourView1 = ClockNumbers(number: getHour(firstPosition: true), weight: weight)
        let hourView2 = ClockNumbers(number: getHour(firstPosition: false), weight: weight)
        let minuteView1 = ClockNumbers(number: getMinute(firstPosition: true), weight: weight)
        let minuteView2 = ClockNumbers(number: getMinute(firstPosition: false), weight: weight)
        hourView1.add(insideTo: stackHours.view)
        hourView2.add(insideTo: stackHours.view)
        minuteView1.add(insideTo: stackMinutes.view)
        minuteView2.add(insideTo: stackMinutes.view)
    }
    
    private func removeSubviews() {
        stackHours.view.subviews.forEach { $0.removeFromSuperview() }
        stackMinutes.view.subviews.forEach { $0.removeFromSuperview() }
    }
    
    private func getHour(firstPosition: Bool) -> Int {
        let hour = getDateFormatter("HH")
        if firstPosition {
            return Int(hour.prefix(1)) ?? 0
        }
        return Int(hour.prefix(2).suffix(1)) ?? 0
    }
    
    private func getMinute(firstPosition: Bool) -> Int {
        let minutes = getDateFormatter("mm")
        if firstPosition {
            return Int(minutes.prefix(1)) ?? 0
        }
        return Int(minutes.prefix(2).suffix(1)) ?? 0
    }
    
    private func getDateFormatter(_ formatter: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = formatter
        return dateFormatter.string(from: Date())
    }
    
    private func createTwoPoints(_ width: CGFloat) -> UIView {
        let widthPoints = width/3
        let point1 = createPoint(widthPoints)
        let point2 = createPoint(widthPoints)
        
        let view = UIView()
        point1.add(insideTo: view)
        point2.add(insideTo: view)
        
        point1.setConstraints({ build in
            build
                .setTop.equalToSuperView(-4)
                .setHorizontalAlignmentX.equalTo(view)
                .setSize.equalToConstant(widthPoints)
                .apply()
        })
        
        point2.setConstraints({ build in
            build
                .setBottom.equalToSuperView(4)
                .setHorizontalAlignmentX.equalToSuperView
                .setSize.equalToConstant(widthPoints)
                .apply()
        })

        return view
    }
    
    private func createPoint(_ widthPoints: CGFloat) -> ViewBuilder {
        return ViewBuilder()
            .setBorder { build in
                build.setCornerRadius(widthPoints/2)
            }
            .setNeumorphism { build in
                build
                    .setReferenceColor(Theme.shared.currentTheme.primary)
                    .setShape(.flat)
                    .setLightPosition(.leftTop)
                    .setShadowColor(to: .dark, .black)
                    .setIntensity(to:.light,percent: 0)
                    .setIntensity(to:.dark,percent: 100)
                    .setBlur(to:.light, percent: 0)
                    .setBlur(to:.dark, percent: 3)
                    .setDistance(to:.light, percent: 3)
                    .setDistance(to:.dark, percent: 10)
                    .apply()
            }
    }
    
    
    private func addElements() {
        stackHours.add(insideTo: self.view)
        stackMinutes.add(insideTo: self.view)
        twoPoints.add(insideTo: self.view)
        day.add(insideTo: self.view)
    }
    
    private func configConstraints() {
        configStackHoursConstraint()
        configTwoPointsConstraint()
        configStackMinutesConstraint()
        day.applyConstraint()
    }
    
    private func configStackHoursConstraint() {
        stackHours.setConstraints({ build in
            build
                .setPinLeft.equalToSuperView
                .setTrailing.equalTo(twoPoints.view, .leading, -3)
                .apply()
        })
            
    }
    
    private func configStackMinutesConstraint() {
        stackMinutes.setConstraints({ build in
            build
                .setPinRight.equalToSuperView
                .setLeading.equalTo(twoPoints.view, .trailing)
                .apply()
        })
    }
    
    private func configTwoPointsConstraint() {
        twoPoints.setConstraints({ build in
            build
                .setTop.setBottom.equalToSuperView
                .setWidth.equalToConstant(20)
                .setHorizontalAlignmentX.equalToSuperView
                .apply()
        })
    }
    
}
