//
//  Comment.swift
//  Timeline
//
//  Created by Uldis Zingis on 17/10/16.
//  Copyright © 2016 Uldis Zingis. All rights reserved.
//

import Foundation
import CloudKit

class Comment: SearchableRecord, CloudKitSyncable {
    
    static let kRecordType = "Comment"
    let kText = "Text"
    let kTimestamp = "Timestamp"
    let kPost = "Post"
    
    var text: String
    var timestamp: Date
    var post: Post?
    
    var recordType: String { return "Comment" }
    var cloudKitRecordID: CKRecordID?
    
    init(text: String, timestamp: Date = Date(), post: Post) {
        self.text = text
        self.timestamp = timestamp
        self.post = post
    }
    
    required init?(record: CKRecord) {
        guard let timestamp = record.value(forKey: kTimestamp) as? Date,
             let text = record.value(forKey: kText) as? String,
             let postReference = record.value(forKey: kPost) as? CKReference else { return nil }
        
        self.text = text
        self.timestamp = timestamp
        self.cloudKitRecordID = record.recordID
        let matchingPost = PostController.sharedController.posts.filter({$0.cloudKitRecordID == postReference.recordID}).first
        self.post =  matchingPost
    }
    
    func matchesSearchTerm(searchTerm: String) -> Bool {
        if self.text.lowercased().contains(searchTerm.lowercased()) { return true }
        return false
    }
}

extension CKRecord {
    convenience init(comment: Comment) {
        self.init(recordType: comment.recordType)
        
        self[comment.kText] = comment.text as CKRecordValue?
        self[comment.kTimestamp] = comment.timestamp as CKRecordValue?
        let postReference = CKReference(recordID: (comment.post?.cloudKitRecordID)!, action: .none)
        self[comment.kPost] = postReference
    }
}
