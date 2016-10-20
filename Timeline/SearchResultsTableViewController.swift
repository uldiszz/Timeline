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
    var sourceTableViewController: UITableViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func reloadTableView() {
        tableView.reloadData()
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        sourceTableViewController?.performSegue(withIdentifier: "showPost", sender: cell)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return resultsArray.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "postCell", for: indexPath) as? PostTableViewCell, let post = resultsArray[indexPath.row] as? Post else { return UITableViewCell() }

        cell.updateWithPost(post: post)
        
        return cell
    }
}
