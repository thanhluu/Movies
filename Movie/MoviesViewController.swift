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

class MoviesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UICollectionViewDelegate, UICollectionViewDataSource, UISearchBarDelegate {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var errorView: UIView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var layoutSwitch: UISegmentedControl!
    @IBOutlet weak var searchBar: UISearchBar!
    
    let posterBaseUrl = "http://image.tmdb.org/t/p/w185"
    var movies = [NSDictionary]()
    var filteredMovies = [NSDictionary]()
    var endpoint: String!
    let refreshControl = UIRefreshControl()
    
    // Custom Colors
    let primaryColor = UIColor(red: 136/255, green: 160/255, blue: 31/255, alpha: 1)
    let darkColor = UIColor(red: 30/255, green: 34/255, blue: 36/255, alpha: 1)
    let lightColor = UIColor(red: 72/255, green: 76/255, blue: 82/255, alpha: 1)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Custom Navigation Bar
        navigationController?.navigationBar.barStyle = UIBarStyle.black
        navigationController?.navigationBar.tintColor = primaryColor
        let imageView = UIImageView(image: UIImage(named: "logo"))
        navigationItem.titleView = imageView
        navigationController?.navigationBar.barTintColor = darkColor
        
        // Custom Search Bar
        searchBar.layer.borderWidth = 1
        searchBar.layer.borderColor = lightColor.cgColor
        
        // Custom Table View
        tableView.backgroundColor = darkColor

        // Data Source & Delegate
        tableView.dataSource = self
        tableView.delegate = self
        collectionView.dataSource = self
        collectionView.delegate = self
        searchBar.delegate = self

        refreshControl.addTarget(self, action: #selector(MoviesViewController.loadMovie), for: UIControlEvents.valueChanged)
        
        tableView.addSubview(refreshControl)
        
        tableView.isHidden = false
        collectionView.isHidden = true
        
        loadMovie()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBAction func switchLayout(_ sender: AnyObject) {
        tableView.isHidden = sender.selectedSegmentIndex == 1
        collectionView.isHidden = sender.selectedSegmentIndex == 0
        
        if (sender.selectedSegmentIndex == 0) {
            tableView.insertSubview(refreshControl, at: 0)
            tableView.reloadData()
        } else {
            collectionView.insertSubview(refreshControl, at: 0)
            collectionView.reloadData()
        }
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if (searchText == "") {
            filteredMovies = movies

            searchBar.perform(#selector(UIResponder.resignFirstResponder), with: nil, afterDelay: 0.1)
        } else {
            filteredMovies = movies.filter({ (movie: NSDictionary) in
                let title = movie["title"] as! String
                let overview = movie["overview"] as! String
                return title.localizedCaseInsensitiveContains(searchText) || overview.localizedCaseInsensitiveContains(searchText)
            })
        }
        
        if (layoutSwitch.selectedSegmentIndex == 0) {
            tableView.reloadData()
        } else {
            collectionView.reloadData()
        }
    }
    
    func loadMovie() {
        let apiKey = "a07e22bc18f5cb106bfe4cc1f83ad8ed"
        let url = URL(string: "https://api.themoviedb.org/3/movie/\(endpoint!)?api_key=\(apiKey)")
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
                                        self.filteredMovies = self.movies
                                        
                                        if (self.layoutSwitch.selectedSegmentIndex == 0) {
                                            self.tableView.reloadData()
                                        } else {
                                            self.collectionView.reloadData()
                                        }
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
    
    // List View
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredMovies.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "movieCell") as! MovieCell
        let movie = filteredMovies[indexPath.row]
        
        cell.titleLabel.text = movie["title"] as? String
        cell.overviewLabel.text = movie["overview"] as? String
        
        // Use a red color when the user selects the cell
        let backgroundView = UIView()
        backgroundView.backgroundColor = lightColor
        cell.selectedBackgroundView = backgroundView
        
        // cell.posterView.setImageWith(URL(string: posterBaseUrl + posterPath)!)
        // Below code are impliment images are fade in as they are loading from network
        if let posterPath = movie["poster_path"] as? String {
            let imageUrl = posterBaseUrl + posterPath
            let imageRequest = NSURLRequest(url: NSURL(string: imageUrl)! as URL)
            
            cell.posterView.setImageWith(
                imageRequest as URLRequest,
                placeholderImage: nil,
                success: { (imageRequest, imageResponse, image) -> Void in
                    
                    // imageResponse will be nil if the image is cached
                    if imageResponse != nil {
                        //print("Image was NOT cached, fade in image")
                        cell.posterView.alpha = 0.0
                        cell.posterView.image = image
                        UIView.animate(withDuration: 0.3, animations: { () -> Void in
                            cell.posterView.alpha = 1.0
                        })
                    } else {
                        //print("Image was cached so just update the image")
                        cell.posterView.image = image
                    }
            },
                failure: { (imageRequest, imageResponse, error) -> Void in
                    // do something for the failure condition
            })
        }
        else {
            cell.posterView.image = nil
        }

        return cell
    }
    
    // Grid View
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return filteredMovies.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "gridMovieCell", for: indexPath) as! GridMovieCell
        let movie = filteredMovies[indexPath.row]
        
        // cell.posterView.setImageWith(URL(string: posterBaseUrl + posterPath)!)
        // Below code are impliment images are fade in as they are loading from network
        if let posterPath = movie["poster_path"] as? String {
            let imageUrl = posterBaseUrl + posterPath
            let imageRequest = NSURLRequest(url: NSURL(string: imageUrl)! as URL)
            
            cell.posterView.setImageWith(
                imageRequest as URLRequest,
                placeholderImage: nil,
                success: { (imageRequest, imageResponse, image) -> Void in
                    
                    // imageResponse will be nil if the image is cached
                    if imageResponse != nil {
                        //print("Image was NOT cached, fade in image")
                        cell.posterView.alpha = 0.0
                        cell.posterView.image = image
                        UIView.animate(withDuration: 0.3, animations: { () -> Void in
                            cell.posterView.alpha = 1.0
                        })
                    } else {
                        //print("Image was cached so just update the image")
                        cell.posterView.image = image
                    }
            },
                failure: { (imageRequest, imageResponse, error) -> Void in
                    // do something for the failure condition
            })
        }
        else {
            cell.posterView.image = nil
        }
        return cell
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (sender is UITableViewCell) {
            let cell = sender as! UITableViewCell
            let indexPath = tableView.indexPath(for: cell)
            let movie = filteredMovies[indexPath!.row]
            
            let detailViewController = segue.destination as! DetailViewController
            
            detailViewController.movieTitle = movie["title"] as? String
            detailViewController.overview = movie["overview"] as? String
            detailViewController.poster = movie["poster_path"] as? String
            detailViewController.voteText = movie["vote_average"] as? Double
            detailViewController.releaseDateText = movie["release_date"] as? String

            tableView.deselectRow(at: indexPath!, animated: true)
        } else {
            
            let cell = sender as! UICollectionViewCell
            let indexPath = collectionView.indexPath(for: cell)
            let movie = filteredMovies[indexPath!.row]
            
            let detailViewController = segue.destination as! DetailViewController
            
            detailViewController.movieTitle = movie["title"] as? String
            detailViewController.overview = movie["overview"] as? String
            detailViewController.poster = movie["poster_path"] as? String
            detailViewController.voteText = movie["vote_average"] as? Double
            detailViewController.releaseDateText = movie["release_date"] as? String
            
        }
        
    }
}
