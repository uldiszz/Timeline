//
//  CloudKitSyncable.swift
//  Timeline
//
//  Created by Uldis Zingis on 19/10/16.
//  Copyright © 2016 Uldis Zingis. All rights reserved.
//

import Foundation
import CloudKit

protocol CloudKitSyncable {
    init?(record: CKRecord)
    var cloudKitRecordID: CKRecordID? { get set }
    var recordType: String { get }
}

extension CloudKitSyncable {
    var isSynced: Bool {
        return cloudKitRecordID != nil
    }
    var cloudKitReference: CKReference? {
        guard let cloudKitRecordID = cloudKitRecordID else { return nil }
        return CKReference(recordID: cloudKitRecordID, action: .none)
    }
}
