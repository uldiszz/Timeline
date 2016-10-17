//
//  Comment.swift
//  Timeline
//
//  Created by Uldis Zingis on 17/10/16.
//  Copyright © 2016 Uldis Zingis. All rights reserved.
//

import Foundation

class Comment {
    
    var text: String
    var timestamp: Date
    var post: Post
    
    init(text: String, timestamp: Date = Date(), post: Post) {
        self.text = text
        self.timestamp = timestamp
        self.post = post
    }
    
}
