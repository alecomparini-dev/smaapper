//
//  WeatherCoordinator.swift
//  Smaapper
//
//  Created by Alessandro Comparini on 09/06/23.
//

import UIKit

class WeatherCoordinator: Coordinator {

    var floatNavigationController: FloatNavigationController
    
    required init(_ floatNavigationController: FloatNavigationController) {
        self.floatNavigationController = floatNavigationController
    }
    
    func start(where component: UIView) {
        let weather = WeatherFloatViewController()
        weather.setCustomAttribute(WeatherFloatViewController.identifierApp)
        floatNavigationController.present(weather, where: component )
    }

    func start() {
        
    }

    
}
