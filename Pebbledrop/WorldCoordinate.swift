//
//  WorldCoordinate.swift
//  Pebbledrop
//
//  Created by Reid Case on 2/22/18.
//  Copyright © 2018 Reid Case. All rights reserved.
//

import Foundation

struct WorldCoordinate {
    //I think Double is sufficient accuracy...
    var longitude: Double
    var latitude: Double
    var elevation: Double
    var orientation: Double //probably in radians or something
}
