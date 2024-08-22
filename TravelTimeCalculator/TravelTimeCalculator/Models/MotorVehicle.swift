//
//  MotorVehicle.swift
//  TravelTimeCalculator
//
//  Created by Synergy01 on 31.07.24.
//

import Foundation

class Vehicle: Movable {

    var speed: Double = 0.0
    var fuelConsumptionRate = 0.0
    var fuelLevel = 0.0
    private var startTime: Date?
    private var stopDuration: [Double] = []
    
    init(speed: Double, fuelConsumptionRate: Double = 0.0, fuelLevel: Double = 0.0, startTime: Date? = nil, stopDuration: [Double]) {
        self.speed = speed
        self.fuelConsumptionRate = fuelConsumptionRate
        self.fuelLevel = fuelLevel
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
        
    func calculateFuel(for distance: Double) -> Double {
        return distance / speed * fuelConsumptionRate
    }
    
    func isFuelEnough(for distance: Double) -> (isEnough: Bool, requiredFuel: Double) {
        let requiredFuel = calculateFuel(for: distance)
        let isEnough = fuelLevel >= requiredFuel
        return (isEnough, requiredFuel)
    }
}
