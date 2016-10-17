//
//  PostController.swift
//  Timeline
//
//  Created by Uldis Zingis on 17/10/16.
//  Copyright © 2016 Uldis Zingis. All rights reserved.
//

import Foundation
import UIKit

class PostController {
    
    static var sharedController = PostController()
    
    var posts: [Post] = []
    
    func createPost(image: UIImage, caption: String) {
        guard let imageData = UIImageJPEGRepresentation(image, 1.0) else { return }
        let post = Post(photoData: imageData)
        addCommentToPost(text: caption, post: post)
        posts.append(post)
    }
    
    func addCommentToPost(text: String, post: Post) {
        post.comments.append(Comment(text: text, post: post))
    }
}
