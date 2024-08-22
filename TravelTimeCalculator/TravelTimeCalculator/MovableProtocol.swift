//
//  MovableProtocol.swift
//  TravelTimeCalculator
//
//  Created by Synergy01 on 30.07.24.
//

import Foundation

protocol Movable {
    var speed: Double {get set}
    func start(at time: Date)
    func stop(duration: Double)
    func calculateTime(to destination: Double) -> Double
}

enum TerrainType {
    case flat
    case uphill
    case downhill
    
    var description: String {
        switch self {
        case .flat: return "Flat"
        case .uphill: return "Uphill"
        case .downhill: return "Downhill"
        }
    }
}


