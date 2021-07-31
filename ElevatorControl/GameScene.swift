//
//  GameScene.swift
//  PromiseMe
//
//  Created by Mert Tecimen on 24.11.2020.
//
import SpriteKit
import GameplayKit

class GameScene: SKScene {
    
    private var costumerHolder: Costumer?
    private var originalCostumerArray: [Costumer] = []
    private var costumerArray: [Costumer]{
        get{
            return dataQueue.sync{
                originalCostumerArray
            }
        }
        set{
            dataQueue.sync(flags: .barrier) {
                self.originalCostumerArray = newValue
            }
        }
        
    }
    private var elevators: [Elevator] = []
    private var idGiver: Int32 = 1
    private var exitCount = 0
   
    // Main Threads
    let loginThread = DispatchQueue(label: "LoginThread",
                                    qos: .background,
                                    attributes: .concurrent,
                                    autoreleaseFrequency: .workItem,
                                    target: nil)
    let exitThread = DispatchQueue(label: "ExitThread",
                                    qos: .background,
                                    attributes: .concurrent,
                                    autoreleaseFrequency: .workItem,
                                    target: nil)
    let controlThread = DispatchQueue(label: "ControlThread",
                                    qos: .background,
                                    attributes: .concurrent,
                                    autoreleaseFrequency: .workItem,
                                    target: nil)
    let labelThread = DispatchQueue(label: "Graphics", attributes: .concurrent)
    let dataQueue = DispatchQueue(label: "DataQueue", attributes: .concurrent)
    
    
    
    // Graphical elements
    private var queueLabel1, queueLabel2, queueLabel3, queueLabel4, queueLabel5, exitLabel: SKLabelNode?
    
    override func didMove(to view: SKView) {
        
        
        // Graphic indicator initilation
        queueLabel1 = self.childNode(withName: "queueLabel1") as? SKLabelNode
        queueLabel2 = self.childNode(withName: "queueLabel2") as? SKLabelNode
        queueLabel3 = self.childNode(withName: "queueLabel3") as? SKLabelNode
        queueLabel4 = self.childNode(withName: "queueLabel4") as? SKLabelNode
        queueLabel5 = self.childNode(withName: "queueLabel5") as? SKLabelNode
        exitLabel = self.childNode(withName: "exitLabel") as? SKLabelNode
        
        
        
        
        // Create a Elevators
        elevators = [
            Elevator(
                node: self.childNode(withName: "elevator1") as? SKSpriteNode,
                upArrow: self.childNode(withName: "elevator1UpArrow") as? SKSpriteNode,
                downArrow: self.childNode(withName: "elevator1DownArrow") as? SKSpriteNode,
                idleLamp: self.childNode(withName: "elevator1IdleLamp") as? SKSpriteNode
            ),
            Elevator(
                node: self.childNode(withName: "elevator2") as? SKSpriteNode,
                upArrow: self.childNode(withName: "elevator2UpArrow") as? SKSpriteNode,
                downArrow: self.childNode(withName: "elevator2DownArrow") as? SKSpriteNode,
                idleLamp: self.childNode(withName: "elevator2IdleLamp") as? SKSpriteNode
            ),
            Elevator(
                node: self.childNode(withName: "elevator3") as? SKSpriteNode,
                upArrow: self.childNode(withName: "elevator3UpArrow") as? SKSpriteNode,
                downArrow: self.childNode(withName: "elevator3DownArrow") as? SKSpriteNode,
                idleLamp: self.childNode(withName: "elevator3IdleLamp") as? SKSpriteNode
            ),
            Elevator(
                node: self.childNode(withName: "elevator4") as? SKSpriteNode,
                upArrow: self.childNode(withName: "elevator4UpArrow") as? SKSpriteNode,
                downArrow: self.childNode(withName: "elevator4DownArrow") as? SKSpriteNode,
                idleLamp: self.childNode(withName: "elevator4IdleLamp") as? SKSpriteNode
            ),
            Elevator(
                node: self.childNode(withName: "elevator5") as? SKSpriteNode,
                upArrow: self.childNode(withName: "elevator5UpArrow") as? SKSpriteNode,
                downArrow: self.childNode(withName: "elevator5DownArrow") as? SKSpriteNode,
                idleLamp: self.childNode(withName: "elevator5IdleLamp") as? SKSpriteNode
            )
        ]
        elevators[0].isActive = true
        elevators[1].elevatorNo = 1
        elevators[2].elevatorNo = 2
        elevators[3].elevatorNo = 3
        elevators[4].elevatorNo = 4
        
        loginThread.async{
                while true{
                    usleep(1000000/5)
                    self.generateCostumers()
                }
        }
        controlThread.async{
            while true{
                
                for i in self.costumerArray{
                    if(i.isNewComer){
                        if((self.elevators[0].elevatorQueue[Int(i.currentFloor)] ) < 20 && i.targetElavator >= 0){
                            i.targetElavator = 0
                            self.relocateCostumer(costumer: i)
                            self.elevators[0].elevatorQueue[Int(i.currentFloor)] += 1
                            i.isNewComer = false
                        }
                        else if ((self.elevators[1].elevatorQueue[Int(i.currentFloor)]) < 20 && i.targetElavator >= 0){
                            i.targetElavator = 1
                            self.relocateCostumer(costumer: i)
                            self.elevators[1].elevatorQueue[Int(i.currentFloor)] += 1
                            i.isNewComer = false
                        }
                        else if ((self.elevators[2].elevatorQueue[Int(i.currentFloor)]) < 20 && i.targetElavator >= 0){
                            i.targetElavator = 2
                            self.relocateCostumer(costumer: i)
                            self.elevators[2].elevatorQueue[Int(i.currentFloor)] += 1
                            i.isNewComer = false
                        }
                        else if ((self.elevators[3].elevatorQueue[Int(i.currentFloor)]) < 20 && i.targetElavator >= 0){
                            i.targetElavator = 3
                            self.relocateCostumer(costumer: i)
                            self.elevators[3].elevatorQueue[Int(i.currentFloor)] += 1
                            i.isNewComer = false
                        }
                        else if ((self.elevators[4].elevatorQueue[Int(i.currentFloor)]) < 20 && i.targetElavator >= 0){
                            i.targetElavator = 4
                            self.relocateCostumer(costumer: i)
                            self.elevators[4].elevatorQueue[Int(i.currentFloor)] += 1
                            i.isNewComer = false
                        }
                        
                    }
                }
                
            }
        }
        
        elevators[0].elevatorThread.async {
            while true{
                // Elevator should be inactive is there's no csotumers in queues.
                var checker = 5
                
                for i in 0..<5{
                    if((self.elevators[0].elevatorQueue[i]) == 0){
                        checker -= 1
                    }
                }
                if(checker == 0){
                    self.elevators[0].isActive = false
                }
                else{
                    self.elevators[0].isActive = true
                }
                // Elevators costumer capacity is 10
                if (self.elevators[0].numOfCostumersIn) < 10 && self.elevators[0].isActive{
                for i in self.costumerArray {
                    if i.currentFloor == self.elevators[0].currentFloor && i.targetElavator == 0 && !i.inElevator && self.elevators[0].numOfCostumersIn < 10{
                        self.elevators[0].elevatorQueue[Int(i.currentFloor)] -= 1
                        self.elevators[0].takeCostumersIn(costumer: i)
                        i.inElevator = true
                    }
                }

            }
                 if (self.elevators[0].numOfCostumersIn) > 0{
                    for i in self.costumerArray {
                        if(i.inElevator && i.targetElavator == 0){
                            self.elevators[0].moveCostumers(costumer: i, costumerArray: self.costumerArray)
                            break
                        }
                    }
                }
                
                
                if(self.elevators[0].numOfCostumersIn == 0 && self.elevators[0].elevatorQueue[Int(self.elevators[0].currentFloor)] == 0){
                    self.elevators[0].goToCostumer(costumerArray: self.costumerArray)
                }
                if(!self.elevators[0].isActive){
                    self.elevators[0].elevatorIdleLamp?.texture = Textures.idleLampOpen
                }
            }
            
        }
        
        elevators[1].elevatorThread.async {
            while true{
                // Elevator should be inactive is there's no csotumers in queues.
                var checker = 5
                
                for i in 0..<5{
                    if((self.elevators[1].elevatorQueue[i]) == 0){
                        checker -= 1
                    }
                }
                if(checker == 0){
                    self.elevators[1].isActive = false
                }
                else{
                    self.elevators[1].isActive = true
                }
                // Elevators costumer capacity is 10
                if (self.elevators[1].numOfCostumersIn) < 10 && self.elevators[1].isActive{
                for i in self.costumerArray {
                    if i.currentFloor == self.elevators[1].currentFloor && i.targetElavator == 1 && !i.inElevator && self.elevators[1].numOfCostumersIn < 10{
                        self.elevators[1].elevatorQueue[Int(i.currentFloor)] -= 1
                        self.elevators[1].takeCostumersIn(costumer: i)
                        i.inElevator = true
                    }
                }
            }
                 if (self.elevators[1].numOfCostumersIn) > 0{
                    for i in self.costumerArray {
                        if(i.inElevator && i.targetElavator == 0){
                            self.elevators[1].moveCostumers(costumer: i, costumerArray: self.costumerArray)
                            break
                        }
                    }
                }
                
                if(self.elevators[1].numOfCostumersIn == 0 && self.elevators[1].elevatorQueue[Int(self.elevators[1].currentFloor)] == 0){
                    self.elevators[1].goToCostumer(costumerArray: self.costumerArray)
                }
                
                if(!self.elevators[1].isActive){
                    self.elevators[1].elevatorIdleLamp?.texture = Textures.idleLampOpen
                }
                
            }
            
        }
        
        elevators[2].elevatorThread.async {
            while true{
                // Elevator should be inactive is there's no csotumers in queues.
                var checker = 5
                
                for i in 0..<5{
                    if((self.elevators[2].elevatorQueue[i]) == 0){
                        checker -= 1
                    }
                }
                if(checker == 0){
                    self.elevators[2].isActive = false
                }
                else{
                    self.elevators[2].isActive = true
                }
                // Elevators costumer capacity is 10
                if (self.elevators[2].numOfCostumersIn) < 10 && self.elevators[2].isActive{
                for i in self.costumerArray {
                    if i.currentFloor == self.elevators[2].currentFloor && i.targetElavator == 2 && !i.inElevator && self.elevators[2].numOfCostumersIn < 10{
                        self.elevators[2].elevatorQueue[Int(i.currentFloor)] -= 1
                        self.elevators[2].takeCostumersIn(costumer: i)
                        i.inElevator = true
                    }
                }
            }
                 if (self.elevators[2].numOfCostumersIn) > 0{
                    for i in self.costumerArray {
                        if(i.inElevator && i.targetElavator == 0){
                            self.elevators[2].moveCostumers(costumer: i, costumerArray: self.costumerArray)
                            break
                        }
                    }
                }
                
                
                if(self.elevators[2].numOfCostumersIn == 0 && self.elevators[2].elevatorQueue[Int(self.elevators[2].currentFloor)] == 0){
                    self.elevators[2].goToCostumer(costumerArray: self.costumerArray)
                }
                if(!self.elevators[2].isActive){
                    self.elevators[2].elevatorIdleLamp?.texture = Textures.idleLampOpen
                }
            }
            
        }
        
        elevators[3].elevatorThread.async {
            while true{
                // Elevator should be inactive is there's no csotumers in queues.
                var checker = 5
                
                for i in 0..<5{
                    if((self.elevators[3].elevatorQueue[i]) == 0){
                        checker -= 1
                    }
                }
                if(checker == 0){
                    self.elevators[3].isActive = false
                }
                else{
                    self.elevators[3].isActive = true
                }
                // Elevators costumer capacity is 10
                if (self.elevators[3].numOfCostumersIn) < 10 && self.elevators[3].isActive{
                for i in self.costumerArray {
                    if i.currentFloor == self.elevators[3].currentFloor && i.targetElavator == 3 && !i.inElevator && self.elevators[3].numOfCostumersIn < 10{
                        self.elevators[3].elevatorQueue[Int(i.currentFloor)] -= 1
                        self.elevators[3].takeCostumersIn(costumer: i)
                        i.inElevator = true
                    }
                }
            }
                 if (self.elevators[3].numOfCostumersIn) > 0{
                    for i in self.costumerArray {
                        if(i.inElevator && i.targetElavator == 0){
                            self.elevators[3].moveCostumers(costumer: i, costumerArray: self.costumerArray)
                            break
                        }
                    }
                }
                
                
                if(self.elevators[3].numOfCostumersIn == 0 && self.elevators[3].elevatorQueue[Int(self.elevators[3].currentFloor)] == 0){
                    self.elevators[3].goToCostumer(costumerArray: self.costumerArray)
                }
                if(!self.elevators[3].isActive){
                    self.elevators[3].elevatorIdleLamp?.texture = Textures.idleLampOpen
                }
            }
            
        }
        
        elevators[4].elevatorThread.async {
            while true{
                // Elevator should be inactive is there's no csotumers in queues.
                var checker = 5
                
                for i in 0..<5{
                    if((self.elevators[4].elevatorQueue[i]) == 0){
                        checker -= 1
                    }
                }
                if(checker == 0){
                    self.elevators[4].isActive = false
                }
                else{
                    self.elevators[4].isActive = true
                }
                // Elevators costumer capacity is 10
                if (self.elevators[4].numOfCostumersIn) < 10 && self.elevators[4].isActive{
                for i in self.costumerArray {
                    if i.currentFloor == self.elevators[4].currentFloor && i.targetElavator == 4 && !i.inElevator && self.elevators[4].numOfCostumersIn < 10{
                        self.elevators[4].elevatorQueue[Int(i.currentFloor)] -= 1
                        self.elevators[4].takeCostumersIn(costumer: i)
                        i.inElevator = true
                    }
                }
            }
                 if (self.elevators[4].numOfCostumersIn) > 0{
                    for i in self.costumerArray {
                        if(i.inElevator && i.targetElavator == 0){
                            self.elevators[4].moveCostumers(costumer: i, costumerArray: self.costumerArray)
                            break
                        }
                    }
                }
                
                
                if(self.elevators[4].numOfCostumersIn == 0 && self.elevators[4].elevatorQueue[Int(self.elevators[4].currentFloor)] == 0){
                    self.elevators[4].goToCostumer(costumerArray: self.costumerArray)
                }
                if(!self.elevators[4].isActive){
                    self.elevators[4].elevatorIdleLamp?.texture = Textures.idleLampOpen
                }
            }
            
        }
        
        // Print Elevvator variables to frame
        labelThread.async {
            while true{
                self.queueLabel1?.text = String("5th Floor Queue: \(self.elevators[0].elevatorQueue[4])\n4th Floor Queue: \(self.elevators[0].elevatorQueue[3])\n3rd Floor Queue: \(self.elevators[0].elevatorQueue[2])\n2nd Floor Queue: \(self.elevators[0].elevatorQueue[1])\n1st Floor Queue: \(self.elevators[0].elevatorQueue[0])\nCostumers in Elevator: \(self.elevators[0].numOfCostumersIn)\nCurrent Floor: \(self.elevators[0].currentFloor+1)\nCurrent: \(self.elevators[0].isActive)")
                self.queueLabel2?.text = String("5th Floor Queue: \(self.elevators[1].elevatorQueue[4])\n4th Floor Queue: \(self.elevators[1].elevatorQueue[3])\n3rd Floor Queue: \(self.elevators[1].elevatorQueue[2])\n2nd Floor Queue: \(self.elevators[1].elevatorQueue[1])\n1st Floor Queue: \(self.elevators[1].elevatorQueue[0])\nCostumers in Elevator: \(self.elevators[1].numOfCostumersIn)\nCurrent Floor: \(self.elevators[1].currentFloor+1)\nCurrent: \(self.elevators[1].isActive)")
                self.queueLabel3?.text = String("5th Floor Queue: \(self.elevators[2].elevatorQueue[4])\n4th Floor Queue: \(self.elevators[2].elevatorQueue[3])\n3rd Floor Queue: \(self.elevators[2].elevatorQueue[2])\n2nd Floor Queue: \(self.elevators[2].elevatorQueue[1])\n1st Floor Queue: \(self.elevators[2].elevatorQueue[0])\nCostumers in Elevator: \(self.elevators[2].numOfCostumersIn)\nCurrent Floor: \(self.elevators[2].currentFloor+1)\nCurrent: \(self.elevators[2].isActive)")
                self.queueLabel4?.text = String("5th Floor Queue: \(self.elevators[3].elevatorQueue[4])\n4th Floor Queue: \(self.elevators[3].elevatorQueue[3])\n3rd Floor Queue: \(self.elevators[3].elevatorQueue[2])\n2nd Floor Queue: \(self.elevators[3].elevatorQueue[1])\n1st Floor Queue: \(self.elevators[3].elevatorQueue[0])\nCostumers in Elevator: \(self.elevators[3].numOfCostumersIn)\nCurrent Floor: \(self.elevators[3].currentFloor+1)\nCurrent: \(self.elevators[3].isActive)")
                self.queueLabel5?.text = String("5th Floor Queue: \(self.elevators[4].elevatorQueue[4])\n4th Floor Queue: \(self.elevators[4].elevatorQueue[3])\n3rd Floor Queue: \(self.elevators[4].elevatorQueue[2])\n2nd Floor Queue: \(self.elevators[4].elevatorQueue[1])\n1st Floor Queue: \(self.elevators[4].elevatorQueue[0])\nCostumers in Elevator: \(self.elevators[4].numOfCostumersIn)\nCurrent Floor: \(self.elevators[4].currentFloor+1)\nCurrent: \(self.elevators[4].isActive)")
                self.exitLabel?.text = String("Costumers left: \(self.exitCount)")
            }
        }
        // Selects costumers in other floors and sets their target to first floor.
        exitThread.async {
            while true{
                usleep(1000000/1)
                self.chooseToShoo()
                for i in self.costumerArray {
                    if(i.targetFloor == 0 && i.currentFloor == 0){
                        self.costumerArray.remove(at: self.costumerArray.firstIndex(of: i)!)
                        self.exitCount += 1
                    }
                }
            }
        }

    }
    
    func generateCostumers() -> Void{

        for _ in 0..<(arc4random_uniform(9)+1){ // reason of sum is original call of function gives us interval between 0 to 9 but we need 1 to 10
                costumerHolder = Costumer(ID: idGiver,scene: self, x: 0, y: 0)
                    self.costumerArray.append(self.costumerHolder!)
          
                self.idGiver += 1
            }
        }
    
    func relocateCostumer(costumer: Costumer) -> Void{
        let sizeOfElevatorQueue = Int32((self.elevators[Int(costumer.targetElavator)].elevatorQueue[Int(costumer.currentFloor)]))
        costumer.setPosition(x: Coordinates.xOfElevatorQueues[Int(costumer.targetElavator)] + 11.0*CGFloat(sizeOfElevatorQueue), y:  Coordinates.yOfFloors[Int(costumer.currentFloor)])
        
    }
    
    func chooseToShoo(){
        for _ in 0..<arc4random_uniform(5){
            for i in self.costumerArray {
                if i.targetFloor == i.currentFloor && i.targetElavator == -1 && i.currentFloor != 0{
                    i.targetFloor = 0
                    i.targetElavator = 0
                    i.isNewComer = true
                    i.costumerNode.isHidden = false
                    break
                }
            }
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
    }
}
