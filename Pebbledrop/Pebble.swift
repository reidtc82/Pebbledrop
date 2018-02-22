//
//  Pebble.swift
//  Pebbledrop
//
//  Created by Reid Case on 2/22/18.
//  Copyright © 2018 Reid Case. All rights reserved.
//

import Foundation

struct Pebble {
    var location: WorldCoordinate
    var image: [Int] //Placeholder. Will probably need bytes or some other prebuilt image object
    var timeStamp: time_value //No idea, will need to keep a time value for purging daily
}
