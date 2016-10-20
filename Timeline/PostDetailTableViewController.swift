//
//  PostDetailTableViewController.swift
//  Timeline
//
//  Created by Uldis Zingis on 17/10/16.
//  Copyright © 2016 Uldis Zingis. All rights reserved.
//

import UIKit

class PostDetailTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var postImaveView: UIImageView!
    @IBOutlet weak var tableView: UITableView!
    var post: Post?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 40
        updateWithPost()
        NotificationCenter.default.addObserver(self, selector: #selector(commentsWereUpdated), name: PostController.postCommentsChangedNotification, object: post)
    }
    
    func commentsWereUpdated() {
        self.tableView.reloadData()
    }
    
    func updateWithPost() {
        postImaveView.image = post?.photo
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return post?.comments.count ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "commentCell", for: indexPath)

        let comment = post?.comments[indexPath.row]
        cell.textLabel?.text = comment?.text
        if let timestamp = comment?.timestamp {
            let formatter = DateFormatter()
            formatter.dateStyle = .short
            formatter.timeStyle = .short
            cell.detailTextLabel?.text = "\(formatter.string(from: timestamp))"
        }

        return cell
    }
    
    @IBAction func commentButtonTapped(_ sender: AnyObject) {
        let alert = UIAlertController(title: "New comment", message: "", preferredStyle: .alert)
        var commentTextField = UITextField()
        alert.addTextField { (textField) in
            textField.placeholder = "Your comment"
            commentTextField = textField
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (_) in
        }
        let okAction = UIAlertAction(title: "Create", style: .default) { (action) in
            guard let text = commentTextField.text, let post = self.post else { return }
            if text != "" {
                PostController.sharedController.addCommentToPost(text: text, post: post)
                self.tableView.reloadData()
            }
        }
        alert.addAction(cancelAction)
        alert.addAction(okAction)
        
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func shareButtonTapped(_ sender: AnyObject) {
        let activityController =  UIActivityViewController(activityItems: [post?.photo, post?.comments.first], applicationActivities: nil)
        self.present(activityController, animated: true, completion: nil)
    }
    
    @IBAction func followButtonTapped(_ sender: AnyObject) {
        
    }
}


