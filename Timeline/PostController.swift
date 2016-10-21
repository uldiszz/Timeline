//
//  PostController.swift
//  Timeline
//
//  Created by Uldis Zingis on 17/10/16.
//  Copyright © 2016 Uldis Zingis. All rights reserved.
//

import Foundation
import UIKit
import CloudKit

class PostController {
    
    static var sharedController = PostController()
    
    static let postsChangedNotification = Notification.Name("PostsChangedNotification")
    static let postCommentsChangedNotification = Notification.Name("PostCommentsChangedNotification")
    
    var posts: [Post] = [] {
        didSet {
            DispatchQueue.main.async {
                NotificationCenter.default.post(name: PostController.postsChangedNotification, object: self)
            }
        }
    }
    
    var cloudKitManager: CloudKitManager
    var isSyncing = false
    
    init() {
        self.cloudKitManager = CloudKitManager()
        performFullSync()
        subscribeToNewPosts()
    }
    
    func createPost(image: UIImage, caption: String) {
        guard let imageData = UIImageJPEGRepresentation(image, 1.0) else { return }
        let post = Post(photoData: imageData)
        
        let postRecord = CKRecord(post: post)
        cloudKitManager.saveRecord(postRecord) { (record, error) in
            if let error = error {
                NSLog("Error saving post to cloud kit: \(error)")
            }
            post.cloudKitRecordID = record?.recordID
            self.addCommentToPost(text: caption, post: post)
            self.posts.append(post)
        }
    }
    
    func addCommentToPost(text: String, post: Post) {
        let comment = Comment(text: text, post: post)
        post.comments.append(comment)
        
        let commentRecord = CKRecord(comment: comment)
        cloudKitManager.saveRecord(commentRecord) { (record, error) in
            if let error = error {
                NSLog("Error saving comment to cloud kit: \(error)")
            }
            comment.cloudKitRecordID = record?.recordID
        }
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: PostController.postCommentsChangedNotification, object: self)
        }
    }
    
    func syncedRecords(type: String) -> [CloudKitSyncable] {
        var records: [CloudKitSyncable] = []
        posts.forEach { (post) in
            if post.cloudKitRecordID != nil { records.append(post) }
            post.comments.forEach { (comment) in
                if comment.cloudKitRecordID != nil { records.append(comment) }
            }
        }
        return records
    }
    
    func unsyncedRecords(type: String) -> [CloudKitSyncable] {
        var records: [CloudKitSyncable] = []
        posts.forEach { (post) in
            if post.cloudKitRecordID == nil { records.append(post) }
            post.comments.forEach { (comment) in
                if comment.cloudKitRecordID == nil { records.append(comment) }
            }
        }
        return records
    }
    
    func fetchNewRecords(type: String, completion: @escaping ((Error?) -> Void) = { _ in }) {
        var predicate: NSPredicate!
        
        let exclude: [CKReference] = syncedRecords(type: type).flatMap { $0.cloudKitReference }
        predicate = NSPredicate(format: "NOT(recordID IN %@)", argumentArray: [exclude])
        
        if exclude.isEmpty {
            predicate = NSPredicate(value: true)
        }
        
        cloudKitManager.fetchRecordsWithType(type, predicate: predicate, recordFetchedBlock: { (record) in
            switch type {
            case Post.kRecordType:
                guard let post = Post(record: record) else { return }
                self.posts.append(post)
            case Comment.kRecordType:
                guard let comment = Comment(record: record),
                    let postReference = record.value(forKey: comment.kPost) as? CKReference else { return }
                let matchingPost = PostController.sharedController.posts.filter({$0.cloudKitRecordID == postReference.recordID}).first
                
                matchingPost?.comments.append(comment)

            default:
                NSLog("Unsupported type to fetch")
            }
        }) { (records, error) in
            if let error = error {
                NSLog("Error fetching: \(error)")
                completion(error)
            }
            completion(nil)
        }
    }
    
    func pushChangestoCloudKit(completion: @escaping ((Bool, Error?) -> Void) = { _ in }) {
        let unsyncedPosts = unsyncedRecords(type: Post.kRecordType)
        let unsyncedComments = unsyncedRecords(type: Comment.kRecordType)
        
        var dict = [CKRecord : CloudKitSyncable]()
        
        unsyncedPosts.forEach { (post) in
            let record = CKRecord(post: post as! Post)
            dict[record] = post
        }
        
        unsyncedComments.forEach { (comment) in
            let record = CKRecord(comment: comment as! Comment)
            dict[record] = comment
        }
        
        let unsavedCKRecords = Array(dict.keys)
        
        cloudKitManager.saveRecords(unsavedCKRecords, perRecordCompletion: { (record, error) in
            guard let record = record else { return }
            switch record.recordType {
            case Post.kRecordType:
                let post = dict[record] as? Post
                post?.cloudKitRecordID = record.recordID
            case Comment.kRecordType:
                let comment = dict[record] as? Comment
                comment?.cloudKitRecordID = record.recordID
            default:
                NSLog("Not supported record type: \(record.recordType). Where did you get it?")
            }
            
        }) { (_, error) in
            if let error = error {
                NSLog("Error saving unsaved records: \(error)")
                completion(false, error)
            }
            completion(true, nil)
        }
    }
    
    func performFullSync(completion: @escaping ((Error?) -> Void) = { _ in }) {
        guard isSyncing == false else { NSLog("Sync already in progress..."); completion(nil); return }
        self.isSyncing = true
        
        pushChangestoCloudKit { (success, error) in
            self.fetchNewRecords(type: Post.kRecordType, completion: { (error) in
                if let error = error {
                    NSLog("Error fetching posts: \(error)")
                    self.isSyncing = false
                    completion(error)
                    return
                }
                
                self.fetchNewRecords(type: Comment.kRecordType, completion: { (error) in
                    if let error = error {
                        NSLog("Error fetching comments: \(error)")
                        self.isSyncing = false
                        completion(error)
                        return
                    }
                })
                
                self.isSyncing = false
                completion(nil)
            })
        }
    }
    
    func subscribeToNewPosts(completion: @escaping ((Bool, Error?) -> Void) = { _ in }) {
        cloudKitManager.subscribe(Post.kRecordType, predicate: NSPredicate(value: true), subscriptionID: "SubscribedToAllPosts", contentAvailable: true, alertBody: "New post in Timeline.", options: .firesOnRecordCreation) { (subscription, error) in
            if let error = error {
                NSLog("Error subscribing to all posts: \(error)")
                completion(false, error)
                return
            }
            completion(true, nil)
        }
    }
    
    func addSubscriptionToPostComments(post: Post, alertBody: String = "New comment", completion: @escaping ((Bool, Error?) -> Void) = { _ in }) {
        
        guard let postCloudKitRecordID = post.cloudKitRecordID else { return }
        
        let subscriptionID = "SubscribedToPost" + String(describing: post.cloudKitRecordID)
        
        let predicate = NSPredicate(format: "Post == %@", postCloudKitRecordID)

        cloudKitManager.subscribe("Comment", predicate: predicate, subscriptionID: subscriptionID, contentAvailable: true, alertBody: alertBody, options: .firesOnRecordCreation) { (_, error) in
            if let error = error {
                NSLog("Error subscribing to comment: \(error.localizedDescription)")
                completion(false, error)
                return
            }
            completion(true, nil)
        }
    }
    
    func removeSubscriptionToPostcomments(post: Post, completion: @escaping ((Bool, Error?) -> Void) = { _ in }) {
        let subscriptionID = "SubscribedToPost" + String(describing: post.cloudKitRecordID)
        cloudKitManager.unsubscribe(subscriptionID) { (success, error) in
            if let error = error {
                NSLog("Error unsubscribing from post: \(error.localizedDescription)")
                completion(false, error)
                return
            }
            completion(true, nil)
        }
    }
    
    func checkSubscriptionToPostComments(post: Post, completion: @escaping ((Bool) -> Void) = { _ in }) {
        let subscriptionID = "SubscribedToPost" + String(describing: post.cloudKitRecordID)
        cloudKitManager.fetchSubscriptionWith(subscriptionID) { (subscription, error) in
            if let error = error {
                NSLog("Error fetching subscription: \(error)")
                completion(false)
                return
            }
            if subscription != nil {
                completion(true)
            } else {
                completion(false)
            }
        }
    }
    
    func togglePostCommentSubscription(post: Post, completion: @escaping ((Bool, _ isSubscribed: Bool, _ error: Error?) -> Void) = { _ in }) {
        checkSubscriptionToPostComments(post: post) { (isSubscribed) in
            if isSubscribed {
                self.removeSubscriptionToPostcomments(post: post)
                completion(true, false, nil)
            } else {
                self.addSubscriptionToPostComments(post: post)
                completion(true, true, nil)
            }
        }
    }
}








