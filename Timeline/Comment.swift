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
             let text = record.value(forKey: kText) as? String else { return nil }
        
        self.text = text
        self.timestamp = timestamp
        self.cloudKitRecordID = record.recordID
    }
    
    func matchesSearchTerm(searchTerm: String) -> Bool {
        if self.text.lowercased().contains(searchTerm.lowercased()) { return true }
        return false
    }
}

extension CKRecord {
    convenience init(comment: Comment) {
        self.init(recordType: comment.recordType, recordID: comment.cloudKitRecordID!)
        
        let record = CKRecord(recordType: comment.recordType)
        record.setValue(comment.text, forKey: comment.kText)
        record.setValue(comment.timestamp, forKey: comment.kTimestamp)
        let postReference = CKReference(recordID: (comment.post?.cloudKitRecordID)!, action: .none)
        record.setValue(postReference, forKey: comment.kPost)
    }
}
