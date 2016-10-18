//
//  SearchResultsTableViewController.swift
//  Timeline
//
//  Created by Uldis Zingis on 17/10/16.
//  Copyright © 2016 Uldis Zingis. All rights reserved.
//

import UIKit

class SearchResultsTableViewController: UITableViewController {

    var resultsArray: [SearchableRecord] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        presentingViewController?.performSegue(withIdentifier: "showPost", sender: self)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return resultsArray.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "postCell", for: indexPath) as? PostTableViewCell, let post = resultsArray[indexPath.row] as? Post else { return UITableViewCell() }

        cell.updateWithPost(post: post)
        
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        if segue.identifier == "showPost" {
//            guard let nextVC = segue.destination as? PostDetailTableViewController, let indexPath = tableView.indexPathForSelectedRow else { return }
//            let post = resultsArray[indexPath.row]
//            nextVC.post = post
//        }
    }
}
