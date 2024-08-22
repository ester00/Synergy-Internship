//
//  Walking.swift
//  TravelTimeCalculator
//
//  Created by Synergy01 on 31.07.24.
//

import Foundation

class Walking: Movable {
    
    var speed: Double = 0.0
    private var startTime: Date?
    private var stopDuration: [Double] = []
    
    init(speed: Double, startTime: Date? = nil, stopDuration: [Double]) {
        self.speed = speed
        self.startTime = startTime
        self.stopDuration = stopDuration
    }
    
    func start(at time: Date) {
        self.startTime = time
    }
    
    func stop(duration: Double) {
        stopDuration.append(duration)
    }
    
    func calculateTime(to destination: Double) -> Double {
        guard speed > 0 else {return Double.infinity}
        let travelTime = destination/speed
        let totalStopTime = stopDuration.reduce(0, +) / 60.0
        return travelTime + totalStopTime
    }
    
    
}
