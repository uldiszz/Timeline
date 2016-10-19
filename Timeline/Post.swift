//
//  Post.swift
//  Timeline
//
//  Created by Uldis Zingis on 17/10/16.
//  Copyright © 2016 Uldis Zingis. All rights reserved.
//

import Foundation
import UIKit
import CloudKit

class Post: SearchableRecord, CloudKitSyncable {
    
    let kPhotoURL = "PhotoURL"
    let ktimestamp = "Timestamp"
    
    var photoData: Data?
    var timestamp: Date
    var comments: [Comment]?
    
    var recordType: String { return "Post" }
    var cloudKitRecordID: CKRecordID?
    
    var temporaryPhotoURL: URL {
        // Must write to temporary directory to be able to pass image file path url to CKAsset
        let temporaryDirectory = NSTemporaryDirectory()
        let temporaryDirectoryURL = URL(fileURLWithPath: temporaryDirectory)
        let fileURL = temporaryDirectoryURL.appendingPathComponent(NSUUID().uuidString).appendingPathExtension("jpg")
        
        do {
            try photoData?.write(to: fileURL)
        } catch {
            NSLog("Error writing photo data to file url: \(error)")
        }
        
        return fileURL
    }
    
    var photo: UIImage {
        guard let data = photoData, let image = UIImage(data: data) else { return UIImage() }
        return image
    }
    
    init(photoData: Data, timestamp: Date = Date(), comments: [Comment] = []) {
        self.photoData = photoData
        self.timestamp = timestamp
        self.comments = comments
    }
    
    required init?(record: CKRecord) {
        guard let timestamp = record.value(forKey: ktimestamp) as? Date, let photoAsset = record.value(forKey: kPhotoURL) as? CKAsset else { return nil }
        
        self.photoData = try? Data(contentsOf: photoAsset.fileURL)
        self.timestamp = timestamp
        self.cloudKitRecordID = record.recordID
    }
    
    func matchesSearchTerm(searchTerm: String) -> Bool {
        guard let comments = self.comments else { return false }
        for comment in comments {
            if comment.text.lowercased().contains(searchTerm.lowercased()) { return true }
        }
        return false
    }
}

extension CKRecord {
    convenience init(post: Post) {
        self.init(recordType: post.recordType, recordID: post.cloudKitRecordID!)
        
        let record = CKRecord(recordType: post.recordType)
        record.setValue(post.timestamp, forKey: post.ktimestamp)
        record.setValue(post.temporaryPhotoURL, forKey: post.kPhotoURL)
    }
}
