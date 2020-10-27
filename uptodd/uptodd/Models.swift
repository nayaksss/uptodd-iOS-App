//
//  Models.swift
//  uptodd
//
//  Created by Vinayak Balaji Tuptewar on 25/10/20.
//

import Foundation
import UIKit

class Songs{
    var name:String
    var artistName:String
    var songString:String
    var imageString:String
    
    init(name:String, artistName:String, songString:String, imageString:String) {
        self.name = name
        self.artistName = artistName
        self.songString = songString
        self.imageString = imageString
    }
    
}
