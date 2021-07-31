//
//  Constants.swift
//  PromiseMe
//
//  Created by Mert Tecimen on 26.11.2020.
//

import Foundation
import SpriteKit

enum ImageName {

    static let background = "MallBackground"
    static let elevator = "Elevator"
    static let Costumer1 = "Costumer1"
    static let Costumer2 = "Costumer2"
    
}

enum Coordinates {
    
    static let yOfFloors: [CGFloat] = [-171.382, -14.496, 143.503, 301.503, 458.502]
    static let xOfElevatorQueues: [CGFloat] = [720, 331.081, -50.919, -430.919, -820.858]
    static let xOfElevatorIn: [CGFloat] = [581, 195, -187.839, -571.098, -953.992]
    
}

enum Textures {
    
    static let upArrowOpen = SKTexture(imageNamed: "UpArrow-Open")
    static let upArrowClose = SKTexture(imageNamed: "UpArrow-Close")
    static let downArrowOpen = SKTexture(imageNamed: "DownArrow-Open")
    static let downArrowClose = SKTexture(imageNamed: "DownArrow-Close")
    static let idleLampOpen = SKTexture(imageNamed: "IdleLamp-Open")
    static let idleLampClose = SKTexture(imageNamed: "IdleLamp-Close")
    
}

