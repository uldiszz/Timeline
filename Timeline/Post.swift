//
//  Post.swift
//  Timeline
//
//  Created by Uldis Zingis on 17/10/16.
//  Copyright © 2016 Uldis Zingis. All rights reserved.
//

import Foundation
import UIKit

class Post {
    
    var photoData: Data?
    var timestamp: Date
    var comments: [Comment]
    
    var photo: UIImage {
        guard let data = photoData, let image = UIImage(data: data) else { return UIImage() }
        return image
    }
    
    init(photoData: Data, timestamp: Date = Date(), comments: [Comment] = []) {
        self.photoData = photoData
        self.timestamp = timestamp
        self.comments = comments
    }
    
}
