//
//  Annotations.swift
//  syntheticDataGenerator
//
//  Created by Yago  Cereijo Botana on 15/8/22.
//

import Foundation

struct DetectionData: Encodable {
    
    let image: String
    let annotations: [Annotations]
    
    internal init(image: String, annotations: [Annotations]) {
        self.image = image
        self.annotations = annotations
    }
    
}

struct Annotations: Encodable  {
    
    let label: String
    let coordinates: Coordinates
    
    internal init(label: String, coordinates: Coordinates) {
        self.label = label
        self.coordinates = coordinates
    }
    
}

struct Coordinates: Encodable  {
    
    let x: Float
    let y: Float
    let width: Float
    let height: Float
    
    internal init(x: Float, y: Float, width: Float, height: Float) {
        self.x = x
        self.y = y
        self.width = width
        self.height = height
    }
}
