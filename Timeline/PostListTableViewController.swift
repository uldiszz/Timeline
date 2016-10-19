//
//  PostListTableViewController.swift
//  Timeline
//
//  Created by Uldis Zingis on 17/10/16.
//  Copyright © 2016 Uldis Zingis. All rights reserved.
//

import UIKit

class PostListTableViewController: UITableViewController, UISearchResultsUpdating {

    var searchController: UISearchController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        tableView.reloadData()
        setUpSearchController()
    }
    
    private var resultsController: SearchResultsTableViewController?
    
    func setUpSearchController() {
        let storybord = UIStoryboard.init(name: "Main", bundle: nil)
        resultsController = storybord.instantiateViewController(withIdentifier: "searchResultsController") as? SearchResultsTableViewController
        resultsController?.sourceTableViewController = self
        
        self.searchController = UISearchController(searchResultsController: resultsController)
        self.searchController?.searchResultsUpdater = self

        tableView.tableHeaderView = self.searchController?.searchBar
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        if let searchTerm = searchController.searchBar.text {
            let filteredPosts = PostController.sharedController.posts.filter { $0.matchesSearchTerm(searchTerm: searchTerm) }
            resultsController?.resultsArray = filteredPosts
            resultsController?.reloadTableView()
        }
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return PostController.sharedController.posts.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "postCell", for: indexPath) as? PostTableViewCell else { return UITableViewCell() }

        let post = PostController.sharedController.posts[indexPath.row]
        cell.updateWithPost(post: post)

        return cell
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            guard let indexPath = tableView.indexPathForSelectedRow else { return }
            PostController.sharedController.posts.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }


    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showPost" {
            if let nextVC = segue.destination as? PostDetailTableViewController {
                if let indexPath = tableView.indexPathForSelectedRow {
                    let post = PostController.sharedController.posts[indexPath.row]
                    nextVC.post = post
                } else {
                    guard let cell = sender as? PostTableViewCell,
                        let searchResultsController = searchController?.searchResultsController as? SearchResultsTableViewController,
                        let searchResultsTableView = searchResultsController.tableView,
                        let searchResultsIndexPath = searchResultsTableView.indexPath(for: cell),
                        let post = searchResultsController.resultsArray[searchResultsIndexPath.row] as? Post else { return }
                    
                    nextVC.post = post
                    searchResultsController.dismiss(animated: true, completion: nil)
                }
            }
        }
    }
}
