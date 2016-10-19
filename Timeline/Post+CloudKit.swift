//
//  Post+CloudKit.swift
//  Timeline
//
//  Created by Uldis Zingis on 18/10/16.
//  Copyright © 2016 Uldis Zingis. All rights reserved.
//

import Foundation
import CloudKit

extension Post {
    
    static let kRecordType = "Post"
    
//    convenience init?(cloudKitRecord: CKRecord) {
//        guard let timestamp = cloudKitRecord.value(forKey: ktimestamp) as? Date,
//             let photoURL = cloudKitRecord.value(forKey: kPhotoURL) else { return nil }
//        
//        self.init(photoData: Data(), timestamp: timestamp)
////        self.photoData =
////        self.timestamp = timestamp
//    }
}
