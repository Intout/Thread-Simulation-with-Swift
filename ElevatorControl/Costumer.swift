//
//  Costumer.swift
//  PromiseMe
//
//  Created by Mert Tecimen on 3.12.2020.
//

import SpriteKit
import Foundation

class Costumer: SKNode {

    // Data Threads
    private var dataQueue = DispatchQueue(label: "TargetElevatorQueue", attributes: .concurrent)
    private var dataQueue2 = DispatchQueue(label: "CurrentFloorQueue", attributes: .concurrent)
    private var dataQueue3 = DispatchQueue(label: "TargetFloorQueue", attributes: .concurrent)
    
    public let costumerNode: SKSpriteNode
    public let costumerID: Int32?
    
    public var originalIsNewComer: Bool = true
    public var isNewComer: Bool{
        get{
            return dataQueue3.sync(flags: .barrier){
                originalIsNewComer
            }
        }
        set{
            dataQueue3.sync{
                self.originalIsNewComer = newValue
            }
        }
    }
    
    public var originalInElevator: Bool = false
    public var inElevator: Bool{
        get{
            return dataQueue3.sync{
                originalInElevator
            }
        }
        set{
            dataQueue3.sync(flags: .barrier){
                self.originalInElevator = newValue
            }
        }
    }
    
    // change this to limit upper floors
    var originaltargetFloor: Int8 = Int8(arc4random_uniform(4)+1)
    var targetFloor: Int8{
        get{
            return dataQueue3.sync(flags: .barrier){
                originaltargetFloor
            }
        }
        set{
            dataQueue3.sync{
                self.originaltargetFloor = newValue
            }
        }
    }
    
    var OriginalCurrentFloor: Int8 = 0
    var currentFloor: Int8{
        get{
            return dataQueue2.sync(flags: .barrier){
                OriginalCurrentFloor
            }
        }
        set{
            dataQueue2.sync{
                self.OriginalCurrentFloor = newValue
            }
        }
        
    }
    var originalTargetElavator: Int8 = 0
    var targetElavator: Int8{
        get{
            return dataQueue.sync(flags: .barrier){
                originalTargetElavator
            }
        }
        set{
            dataQueue.sync{
                self.originalTargetElavator = newValue
            }
        }
        
    }
    
    init(ID: Int32, scene: SKScene, x: CGFloat, y: CGFloat) {
        self.costumerID = ID
        // if the random number is equal to 0 set famale texture or if the number is 1 set male texture.
        costumerNode = SKSpriteNode(imageNamed: arc4random_uniform(2) == 0 ? (ImageName.Costumer2)
                                                                            : (ImageName.Costumer1))
        let coordinates: CGPoint = CGPoint(x: x, y: y)
        costumerNode.position = coordinates
        costumerNode.zPosition = 2
        costumerNode.xScale = 0.8
        scene.addChild(costumerNode)
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func setPosition(x: CGFloat, y: CGFloat){
        let coordinates: CGPoint = CGPoint(x: x, y: y)
        costumerNode.position = coordinates
    }
    

    }

