//
//  StorageFacade.swift
//  Pebbledrop
//
//  Created by Reid Case on 2/22/18.
//  Copyright © 2018 Reid Case. All rights reserved.
//

import Foundation

class StorageFacade {
    static let sharedInstance = StorageFacade()
    
    func getImagesIn(range: Int, of userLoc: WorldCoordinate) -> [Pebble]{
        return []
    }
    
    func initializeConnection(){
        
    }
    
    func closeConnection(){
        
    }
    
    func drop(this pebble:Pebble)//do I need elevation separate from gps coords?
    {
        
    }
}
