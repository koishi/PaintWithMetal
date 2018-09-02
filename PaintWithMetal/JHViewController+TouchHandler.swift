//
//  JHViewController+TouchHandler.swift
//  PaintWithMetal
//
//  Created by Jae Hee Cho on 2015-11-29.
//  Copyright © 2015 Jae Hee Cho. All rights reserved.
//

import Foundation
import UIKit

extension JHViewController {
    func handleTouches(_ touches: Set<UITouch>, withEvent event:UIEvent?) {
        for touch in touches {
            let touchPoint = touch.location(in: self.view)
            
            self.didTouchEnded = 0
            
            if self.prevVertex == nil {
                self.prevVertex = touchPoint
            } else {
                let distance = distanceBetween(pointA: self.prevVertex, pointB: touchPoint)
                var lineThickness = distance/10
                
                lineThickness = min(20, lineThickness)
                lineThickness = max(0.2, lineThickness)
                
                var dirVector = CGPoint(x: touchPoint.x - self.prevVertex.x, y: touchPoint.y - self.prevVertex.y)
                dirVector = normalize(dirVector)
                
                var normalVector = CGPoint(x: dirVector.y, y: -dirVector.x)
                
                let a = CGPoint(x: self.prevVertex.x + normalVector.x * lineThickness , y: self.prevVertex.y + normalVector.y * lineThickness)
                let b = CGPoint(x: touchPoint.x + normalVector.x * lineThickness, y: touchPoint.y + normalVector.y * lineThickness)
                
                normalVector = CGPoint(x: -dirVector.y, y: dirVector.x)
                
                let c = CGPoint(x: self.prevVertex.x + normalVector.x * lineThickness , y: self.prevVertex.y + normalVector.y * lineThickness)
                
                let d = CGPoint(x: touchPoint.x + normalVector.x * lineThickness, y: touchPoint.y + normalVector.y * lineThickness)
                
                let metalCoordinateA = getMetalCoordinate(forPoint: a, forFrame: self.view.frame)
                let metalCoordinateB = getMetalCoordinate(forPoint: b, forFrame: self.view.frame)
                let metalCoordinateC = getMetalCoordinate(forPoint: c, forFrame: self.view.frame)
                let metalCoordinateD = getMetalCoordinate(forPoint: d, forFrame: self.view.frame)
                
                self.vertexData.append(metalCoordinateA.0)
                self.vertexData.append(metalCoordinateA.1)
                self.vertexData.append(contentsOf: [metalZCoordinate, metalWCoordinate])
                
                self.vertexData.append(metalCoordinateC.0)
                self.vertexData.append(metalCoordinateC.1)
                self.vertexData.append(contentsOf: [metalZCoordinate, metalWCoordinate])
                
                self.vertexData.append(metalCoordinateB.0)
                self.vertexData.append(metalCoordinateB.1)
                self.vertexData.append(contentsOf: [metalZCoordinate, metalWCoordinate])
                
                self.vertexData.append(metalCoordinateD.0)
                self.vertexData.append(metalCoordinateD.1)
                self.vertexData.append(contentsOf: [metalZCoordinate, metalWCoordinate])
                
                var dataSize = self.vertexData.count * MemoryLayout.size(ofValue: self.vertexData[0])
                self.vertexBuffer = self.device.makeBuffer(bytes: self.vertexData, length: dataSize, options: [])
                
                let redColorComponents = UnsafeMutablePointer<CGFloat>.allocate(capacity: 1)
                let greenColorComponents = UnsafeMutablePointer<CGFloat>.allocate(capacity: 1)
                let blueColorComponents = UnsafeMutablePointer<CGFloat>.allocate(capacity: 1)
                let alphaColorComponents = UnsafeMutablePointer<CGFloat>.allocate(capacity: 1)
                
                
                self.currentColor.getRed(redColorComponents, green: greenColorComponents, blue: blueColorComponents, alpha: alphaColorComponents)
                
                for _ in 1...4 {
                    self.colorData.append(Float(redColorComponents.pointee))
                    self.colorData.append(Float(greenColorComponents.pointee))
                    self.colorData.append(Float(blueColorComponents.pointee))
                    self.colorData.append(Float(alphaColorComponents.pointee))
                }
                
                redColorComponents.deinitialize()
                redColorComponents.deallocate(capacity: 1)
                greenColorComponents.deinitialize()
                greenColorComponents.deallocate(capacity: 1)
                blueColorComponents.deinitialize()
                blueColorComponents.deallocate(capacity: 1)
                alphaColorComponents.deinitialize()
                alphaColorComponents.deallocate(capacity: 1)
                
                dataSize = self.colorData.count * MemoryLayout.size(ofValue: self.colorData[0])
                self.colorBuffer = self.device.makeBuffer(bytes: self.colorData, length: dataSize, options: [])
                
                self.prevVertex = touchPoint
            }
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.handleTouches(touches, withEvent: event)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.handleTouches(touches, withEvent: event)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.handleTouches(touches, withEvent: event)
    }    
}
