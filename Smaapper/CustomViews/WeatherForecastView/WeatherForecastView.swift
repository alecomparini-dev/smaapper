//
//  WeatherForecastView.swift
//  Smaapper
//
//  Created by Alessandro Comparini on 26/05/23.
//

import UIKit


class WeatherForecastView: ViewBuilder {
    
    private var temperature: CGFloat
    
    init(temperature: CGFloat) {
        self.temperature = temperature
        super.init()
        addElements()
        configConstraints()
    }
    
    
//  MARK: - Lazy Area
    
    lazy var weatherImageView: ImageViewBuilder = {
        let img = ImageViewBuilder()
            .setImage(UIImage(systemName: "cloud.sun.fill"))
//            .setImage(UIImage(systemName: "sun.max.fill"))
//            .setImage(UIImage(systemName: "cloud.bolt.rain.fill"))
            .setTintColor(Theme.shared.currentTheme.onSurface)
            .setContentMode(.scaleAspectFit)
            .setConstraints { build in
                build
                    .setLeading.equalToSuperView(8)
                    .setVerticalAlignmentY.equalToSuperView(2)
                    .setHeight
                    .setWidth.equalToConstant(40)
            }
        return img
    }()
    
    lazy var locationImageView: ImageViewBuilder = {
        let img = ImageViewBuilder(UIImage(systemName: "location.fill"))
            .setSize(12)
            .setTintColor(Theme.shared.currentTheme.onSurfaceInverse)
            .setContentMode(.center)
            .setConstraints { build in
                build
                    .setTop.equalTo(weatherImageView.view, .top, 4)
                    .setLeading.equalTo(weatherImageView.view, .trailing, 12)
            }
        return img
    }()
    
    lazy var temperatureLabel: LabelBuilder = {
        let label = LabelBuilder("25")
            .setColor(Theme.shared.currentTheme.onSurfaceInverse)
            .setFont(UIFont.systemFont(ofSize: 15, weight: .semibold))
            .setConstraints { build in
                build
                    .setLeading.equalTo(locationImageView.view, .leading, -2)
                    .setBottom.equalTo(weatherImageView.view, .bottom, -1 )
            }
        return label
    }()
    
    lazy var degreesLabel: LabelBuilder = {
        let label = LabelBuilder("0")
            .setColor(Theme.shared.currentTheme.onSurfaceInverse)
            .setFont(UIFont.systemFont(ofSize: 8, weight: .medium))
            .setConstraints { build in
                build
                    .setTop.equalTo(temperatureLabel.view, .top)
                    .setLeading.equalTo(temperatureLabel.view, .trailing)
            }
        return label
    }()

    
    lazy var arrowOpenImageView: ImageViewBuilder = {
        let img = ImageViewBuilder(UIImage(systemName: "chevron.forward"))
            .setSize(14)
            .setWeight(.semibold)
            .setTintColor(Theme.shared.currentTheme.onSurfaceInverse)
            .setContentMode(.center)
            .setConstraints { build in
                build
                    .setTrailing.equalToSuperView(-15)
                    .setVerticalAlignmentY.equalToSuperView
            }
        return img
    }()

    
    
//  MARK: - Private Area
    
    private func addElements() {
        weatherImageView.add(insideTo: self.view)
        locationImageView.add(insideTo: self.view)
        temperatureLabel.add(insideTo: self.view)
        degreesLabel.add(insideTo: self.view)
        arrowOpenImageView.add(insideTo: self.view)
        
    }
    
    private func configConstraints() {
        weatherImageView.applyConstraint()
        locationImageView.applyConstraint()
        temperatureLabel.applyConstraint()
        degreesLabel.applyConstraint()
        arrowOpenImageView.applyConstraint()
    }
    
}

