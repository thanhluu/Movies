//
//  MoviesViewController.swift
//  Movie
//
//  Created by Luu Tien Thanh on 2/15/17.
//  Copyright © 2017 Luu Tien Thanh. All rights reserved.
//

import UIKit
import AFNetworking
import MBProgressHUD

class MoviesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var errorView: UIView!
    
    let posterBaseUrl = "http://image.tmdb.org/t/p/w500"
    var movies = [NSDictionary]()
    var endpoint: String!
    let refreshControl = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.

        tableView.dataSource = self
        tableView.delegate = self

        refreshControl.addTarget(self, action: #selector(MoviesViewController.loadMovie), for: UIControlEvents.valueChanged)
        
        tableView.addSubview(refreshControl)
        loadMovie()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func loadMovie() {
        let apiKey = "a07e22bc18f5cb106bfe4cc1f83ad8ed"
        let url = URL(string: "https://api.themoviedb.org/3/movie/\(endpoint)?api_key=\(apiKey)")
        let request = URLRequest(
            url: url!,
            cachePolicy: NSURLRequest.CachePolicy.reloadIgnoringLocalCacheData,
            timeoutInterval: 10)
        let session = URLSession(
            configuration: URLSessionConfiguration.default,
            delegate: nil,
            delegateQueue: OperationQueue.main
        )
        
        errorView.isHidden = true
        // Display HUD right before the request is made
        MBProgressHUD.showAdded(to: self.view, animated: true)
        
        let task: URLSessionDataTask =
            session.dataTask(with: request,
                             completionHandler: { (dataOrNil, response, error) in
                                if (error != nil) {
                                    print("error \(error)")
                                    self.errorView.isHidden = false
                                    self.refreshControl.endRefreshing()
                                }
                                if let data = dataOrNil {
                                    if let responseDictionary = try! JSONSerialization.jsonObject(
                                        with: data, options:[]) as? NSDictionary {
                                        self.movies = responseDictionary["results"] as! [NSDictionary]
                                        
                                        //print(self.movies)
                                        self.tableView.reloadData()

                                        self.refreshControl.endRefreshing()
                                        
                                    }
                                } else {
                                    self.refreshControl.endRefreshing()
                                    self.errorView.isHidden = false
                                }
                                // Hide HUD once the network request comes back (must be done on main UI thread)
                                MBProgressHUD.hide(for: self.view, animated: true)
            })
        task.resume()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return movies.count
    }
    
    
    // Row display. Implementers should *always* try to reuse cells by setting each cell's reuseIdentifier and querying for available reusable cells with dequeueReusableCellWithIdentifier:
    // Cell gets various attributes set automatically based on table (separators) and data source (accessory views, editing controls)
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = UITableViewCell(
//        cell.textLabel?.text = movies[indexPath.row]["title"] as? String

        let cell = tableView.dequeueReusableCell(withIdentifier: "movieCell") as! MovieCell
        cell.titleLabel.text = movies[indexPath.row]["title"] as? String
        cell.overviewLabel.text = movies[indexPath.row]["overview"] as? String
        
        if let posterPath = movies[indexPath.row]["poster_path"] as? String {
            cell.posterView.setImageWith(URL(string: posterBaseUrl + posterPath)!)
        }
        else {
            // No poster image. Can either set to nil (no image) or a default movie poster image
            // that you include as an asset
            cell.posterView.image = nil
        }
        
        
        
        return cell
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    */
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        let nextVC = segue.destination as! DetailViewController
        let ip = tableView.indexPathForSelectedRow
        nextVC.movieTitle = movies[(ip?.row)!]["title"] as? String
        nextVC.overview = movies[(ip?.row)!]["overview"] as? String
        nextVC.poster = movies[(ip?.row)!]["poster_path"] as? String
        
        tableView.deselectRow(at: ip!, animated: true)
    }
 

}
