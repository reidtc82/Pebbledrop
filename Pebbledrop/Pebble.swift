//
//  Pebble.swift
//  Pebbledrop
//
//  Created by Reid Case on 2/22/18.
//  Copyright © 2018 Reid Case. All rights reserved.
//

import Foundation
import CoreLocation
import UIKit

struct Pebble {
    
    var message: String
    var locationOffset: Int
    var location: CLLocation
    var imageURL: NSURL?
    var image: UIImage
    
    init(message: String, locationOffset: Int, at location:CLLocation, imageURL: NSURL, image:UIImage){
        self.message = message
        self.locationOffset = locationOffset
        self.location = location
        self.imageURL = imageURL
        self.image = image
    }
}
