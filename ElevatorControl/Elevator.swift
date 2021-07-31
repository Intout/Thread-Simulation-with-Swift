//
//  Elevator.swift
//  PromiseMe
//
//  Created by Mert Tecimen on 25.11.2020.
//

import SpriteKit
import Foundation


class Elevator: SKNode {
    // Data Threads
    let queue = DispatchQueue (label: "QueueAccess")
    private var dataQueue = DispatchQueue(label: "TargetElevatorQueue", attributes: .concurrent)
    private var dataQueue2 = DispatchQueue(label: "CurrentFloorQueue", attributes: .concurrent)
    private var dataQueue3 = DispatchQueue(label: "TargetFloorQueue", attributes: .concurrent)
    private var dataQueue4 = DispatchQueue(label: "TargetFloorQueue", attributes: .concurrent)
    // Elevator Thread
    public let elevatorThread = DispatchQueue(label: "ElevatorQueue", attributes: .concurrent)
    
    var originalCurrentFloor: Int8 = 0
    var currentFloor: Int8{
        get{
            return dataQueue.sync{
                originalCurrentFloor
            }
        }
        
        set{
            dataQueue.sync(flags: .barrier) {
                self.originalCurrentFloor = newValue
            }
        }
    }
    
    public var elevatorNo: Int = 0
    
    public var originalIsActive = false
    public var isActive: Bool{
        get{
            return dataQueue4.sync{
                originalIsActive
            }
        }
        
        set{
            dataQueue4.sync(flags: .barrier) {
                self.originalIsActive = newValue
            }
        }
    }
    
    public var originalNumOfCostumersIn = 0
    public var numOfCostumersIn: Int{
        get{
            return dataQueue2.sync{
                originalNumOfCostumersIn
            }
        }
        
        set{
            dataQueue2.sync(flags: .barrier) {
                self.originalNumOfCostumersIn = newValue
            }
        }
    }
    
    public var originalElevatorQueue: [Int32] = [0,0,0,0,0]
    public var elevatorQueue: [Int32]{
        get{
            return dataQueue3.sync{
                originalElevatorQueue
            }
        }
        
        set{
            dataQueue3.sync(flags: .barrier) {
                self.originalElevatorQueue = newValue
            }
        }
        
    }
    
    public var originalIsUp: Bool = true
    public var isUp: Bool{
        get{
            return elevatorThread.sync{
                originalIsUp
            }
        }
        
        set{
            elevatorThread.sync(flags: .barrier) {
                self.originalIsUp = newValue
            }
        }
        
    }
    
    public let elevatorNode: SKSpriteNode
    
    // Visual indicators
    private var elevatorUpArrow: SKSpriteNode?
    private var elevatorDownArrow: SKSpriteNode?
    public var elevatorIdleLamp: SKSpriteNode?
    
    ///  Initialize class by getting pre-defined SKSpireteNode from "GameScene.sks".
    /// - Parameter node: Add pre-defined SKSpriteNode
    init(node: SKSpriteNode?, upArrow: SKSpriteNode?, downArrow: SKSpriteNode?, idleLamp: SKSpriteNode?){
        // Create elavator node.
        self.elevatorNode = node!
        self.elevatorUpArrow = upArrow
        self.elevatorUpArrow?.zPosition = 1
        self.elevatorDownArrow = downArrow
        self.elevatorDownArrow?.zPosition = 1
        self.elevatorIdleLamp = idleLamp
        self.elevatorIdleLamp?.zPosition = 1
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    func takeCostumersIn(costumer: Costumer) -> Void{
        costumer.setPosition(x: Coordinates.xOfElevatorIn[Int(costumer.targetElavator)] + CGFloat(11.0*Double(numOfCostumersIn)), y: Coordinates.yOfFloors[Int(costumer.currentFloor)])
        self.numOfCostumersIn += 1
    }
    
    func moveCostumers(costumer: Costumer, costumerArray: [Costumer]){
        let moves = costumer.targetFloor - self.currentFloor
        
        if(moves > 0){
            for _ in 0..<moves{
                self.elevatorNode.run(moveUp(), completion: {
                    
                })
                for i in costumerArray{
                    if(i.targetFloor == self.currentFloor && i.targetElavator == elevatorNo && i.inElevator && i.targetElavator != -1 && self.numOfCostumersIn > 0){
                        self.numOfCostumersIn -= 1
                        i.currentFloor = i.targetFloor
                        i.targetElavator = -1
                        i.inElevator = false
                        i.costumerNode.isHidden = true
                        i.setPosition(x: 100.0, y: 0.0)
                    }
                }
                // take costumers from current floor if there is a space
                for j in costumerArray{
                    if j.currentFloor == self.currentFloor && j.targetElavator == self.elevatorNo && !j.inElevator && self.numOfCostumersIn < 10{
                        self.elevatorQueue[Int(j.currentFloor)] -= 1
                        self.takeCostumersIn(costumer: j)
                        j.inElevator = true
                    }
                }
                if(costumer.currentFloor == costumer.targetFloor || self.elevatorQueue[Int(self.currentFloor)] > 0){
                    break
                }
            }
        }
        else if(moves < 0){
            for _ in 0..<abs(moves){
                self.elevatorNode.run(moveDown())
                for i in costumerArray{
                    if(i.targetFloor == self.currentFloor && i.targetElavator == elevatorNo && i.inElevator && i.targetElavator != -1 && self.numOfCostumersIn > 0){
                        self.numOfCostumersIn -= 1
                        i.currentFloor = i.targetFloor
                        i.targetElavator = -1
                        i.inElevator = false
                        i.costumerNode.isHidden = true
                        i.setPosition(x: 100.0, y: 0.0)
                    }
                }
                // take costumers from current floor if there is a space
                for j in costumerArray{
                    if j.currentFloor == self.currentFloor && j.targetElavator == self.elevatorNo && !j.inElevator && self.numOfCostumersIn < 10{
                        self.elevatorQueue[Int(j.currentFloor)] -= 1
                        self.takeCostumersIn(costumer: j)
                        j.inElevator = true
                    }
                }
                if(costumer.currentFloor == costumer.targetFloor || self.elevatorQueue[Int(self.currentFloor)] > 0){
                    break
                }
            }
        }
        else{
            for i in costumerArray{
                if(i.targetFloor == self.currentFloor && i.targetElavator == elevatorNo && i.inElevator && i.targetElavator != -1 && self.numOfCostumersIn > 0){
                    self.numOfCostumersIn -= 1
                    i.currentFloor = i.targetFloor
                    i.targetElavator = -1
                    i.inElevator = false
                    i.costumerNode.isHidden = true
                    i.setPosition(x: 100.0, y: 0.0)
                }
            }
        }
        
    }
    
    func goToCostumer(costumerArray: [Costumer]){
        for i in costumerArray {
            if i.targetElavator == elevatorNo {
                let moves = i.currentFloor - self.currentFloor
                if moves > 0{
                    for _ in 0..<moves{
                        self.elevatorNode.run(self.moveUp())
                        // take costumers from current floor if there is a space
                        for j in costumerArray{
                            if j.currentFloor == self.currentFloor && j.targetElavator == self.elevatorNo && !j.inElevator && self.numOfCostumersIn < 10{
                                self.elevatorQueue[Int(j.currentFloor)] -= 1
                                self.takeCostumersIn(costumer: j)
                                j.inElevator = true
                            }
                        }
                        if(self.numOfCostumersIn>0){
                            break
                        }
    
                    }
                }
                else if(moves < 0){
                    for _ in 0..<abs(moves){
                        self.elevatorNode.run(self.moveDown())
                        // take costumers from current floor if there is a space
                        for j in costumerArray{
                            if j.currentFloor == self.currentFloor && j.targetElavator == self.elevatorNo && !j.inElevator && self.numOfCostumersIn < 10{
                                self.elevatorQueue[Int(j.currentFloor)] -= 1
                                self.takeCostumersIn(costumer: j)
                                j.inElevator = true
                            }
                        }
                        if(self.numOfCostumersIn>0){
                            break
                        }
                    }

                }
            }
        }
    }
    
    //MARK:- Elevator Movement Controllers.
    /// This will move elevator one floor above. To achive that, it will create a "SKAction.moveBy" action and takes elevator +157 up in y-axis from current coordinate.
    /// - Returns: Void
    func moveUp() -> SKAction! {
        // Updates Navigtion Indicator
        usleep(1000000/10)
        self.elevatorDownArrow?.texture = Textures.downArrowClose
        self.elevatorUpArrow?.texture = Textures.upArrowOpen
        self.elevatorIdleLamp?.texture = Textures.idleLampClose
        self.currentFloor += 1
        return SKAction.moveBy(x: 0,
                               y: 157,
                               duration: 0.1)
    }
    
    /// This will move elevator one floor below. To achive that, it will create a "SKAction.moveBy" action and takes elevator -157 down in y-axis from current coordinate.
    /// - Returns: Void
    func moveDown() -> SKAction! {
        // Updates Navigtion Indicator
        usleep(1000000/10)
        self.elevatorDownArrow?.texture = Textures.downArrowOpen
        self.elevatorUpArrow?.texture = Textures.upArrowClose
        self.elevatorIdleLamp?.texture = Textures.idleLampClose
        self.currentFloor -= 1
        return SKAction.moveBy(x: 0,
                               y: -157,
                               duration: 0.1)
    }
    
}
