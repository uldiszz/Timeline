//
//  PostTableViewCell.swift
//  Timeline
//
//  Created by Uldis Zingis on 17/10/16.
//  Copyright © 2016 Uldis Zingis. All rights reserved.
//

import UIKit

class PostTableViewCell: UITableViewCell {

    @IBOutlet weak var postImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func updateWithPost(post: Post) {
        postImageView.image = post.photo
    }

}
