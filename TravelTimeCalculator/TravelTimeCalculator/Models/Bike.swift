//
//  Bike.swift
//  TravelTimeCalculator
//
//  Created by Synergy01 on 31.07.24.
//

import Foundation

class Bike: Movable {

    var speed: Double = 0.0
    private var startTime: Date?
    private var stopDuration: [Double] = []
    var terrainType: TerrainType = .flat
    
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
        var adjustedSpeed = speed
        print("calculationg with terrin type: \(terrainType)")
        
        switch terrainType {
        case .flat:
            break
        case .uphill:
            adjustedSpeed *= 0.5 // reduce by 50%
        case .downhill:
            adjustedSpeed *= 1.5 // increase by 50%
        }
        guard speed > 0 else {return Double.infinity}
        
        let travelTime = destination/adjustedSpeed
        let totalStopTime = stopDuration.reduce(0, +) / 60.0
        return travelTime + totalStopTime
    }
}
