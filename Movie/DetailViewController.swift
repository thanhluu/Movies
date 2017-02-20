//
//  DetailViewController.swift
//  Movie
//
//  Created by Luu Tien Thanh on 2/17/17.
//  Copyright © 2017 Luu Tien Thanh. All rights reserved.
//

import UIKit
import AFNetworking
import MBProgressHUD

class DetailViewController: UIViewController {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var overviewLabel: UILabel!
    @IBOutlet weak var posterView: UIImageView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var infoView: UIView!
    @IBOutlet weak var releaseDate: UILabel!
    @IBOutlet weak var voteAverage: UILabel!
    
    var movieId: Int!
    var movieInfo = NSDictionary()
    var poster: String!

//    var overview: String!
//    var movieTitle: String!

//    var releaseDateText: String!
//    var voteText: Double!
    
    override func viewWillAppear(_ animated: Bool) {
        tabBarController?.tabBar.isHidden = true
        loadMovieInfo(movieId)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        

        // Do any additional setup after loading the view.
//        titleLabel.text = movieTitle
//        titleLabel.sizeToFit()
//        overviewLabel.text = overview
//        overviewLabel.sizeToFit()
//        infoView.frame.size.height = overviewLabel.frame.size.height + overviewLabel.frame.origin.y + 10
//        scrollView.contentSize = CGSize(width: scrollView.frame.size.width, height: 60 + infoView.frame.origin.y + infoView.frame.size.height)
//
//        releaseDate.text = releaseDateText
//        voteAverage.text = String(voteText)
//        
        if let posterPath = poster {
            
            let smallImageUrl = "http://image.tmdb.org/t/p/w92" + posterPath
            let largeImageUrl = "http://image.tmdb.org/t/p/w1000" + posterPath
            
            let smallImageRequest = NSURLRequest(url: NSURL(string: smallImageUrl)! as URL)
            let largeImageRequest = NSURLRequest(url: NSURL(string: largeImageUrl)! as URL)
            
            posterView.setImageWith(
                smallImageRequest as URLRequest,
                placeholderImage: nil,
                success: { (smallImageRequest, smallImageResponse, smallImage) -> Void in
                    
                    // smallImageResponse will be nil if the smallImage is already available
                    // in cache (might want to do something smarter in that case).
                    self.posterView.alpha = 0.0
                    self.posterView.image = smallImage
                    
                    UIView.animate(withDuration: 0.3, animations: { () -> Void in
                        
                        self.posterView.alpha = 1.0
                        
                    }, completion: { (sucess) -> Void in
                        
                        // The AFNetworking ImageView Category only allows one request to be sent at a time
                        // per ImageView. This code must be in the completion block.
                        self.posterView.setImageWith(
                            largeImageRequest as URLRequest,
                            placeholderImage: smallImage,
                            success: { (largeImageRequest, largeImageResponse, largeImage) -> Void in
                                
                                self.posterView.image = largeImage
                                
                        },
                            failure: { (request, response, error) -> Void in
                                // do something for the failure condition of the large image request
                                // possibly setting the ImageView's image to a default image
                        })
                    })
            },
                failure: { (request, response, error) -> Void in
                    // do something for the failure condition
                    // possibly try to get the large image
            })
        }
        else {
            // No poster image. Can either set to nil (no image) or a default movie poster image
            // that you include as an asset
            posterView.image = nil
        }
    }
    
    func loadMovieInfo(_ movieId: Int = 1) {
        let apiKey = "a07e22bc18f5cb106bfe4cc1f83ad8ed"
        let url = URL(string: "https://api.themoviedb.org/3/movie/\(movieId)?api_key=\(apiKey)")
        //print(url!)
        let request = URLRequest(
            url: url!,
            cachePolicy: NSURLRequest.CachePolicy.reloadIgnoringLocalCacheData,
            timeoutInterval: 10)
        let session = URLSession(
            configuration: URLSessionConfiguration.default,
            delegate: nil,
            delegateQueue: OperationQueue.main
        )

        // Display HUD right before the request is made
        MBProgressHUD.showAdded(to: self.view, animated: true)
        
        let task: URLSessionDataTask =
            session.dataTask(with: request,
                             completionHandler: { (dataOrNil, response, error) in
                                if (error != nil) {
                                    print("error \(error)")
                                    MBProgressHUD.hide(for: self.view, animated: true)
                                }
                                
                                if let data = dataOrNil {
                                    if let responseDictionary = try! JSONSerialization.jsonObject(
                                        with: data, options:[]) as? NSDictionary {
                                        self.titleLabel.text = responseDictionary.value(forKey: "title") as! String?
                                        self.titleLabel.sizeToFit()
                                        self.overviewLabel.text = responseDictionary.value(forKey: "overview") as! String?
                                        self.overviewLabel.sizeToFit()
                                        self.infoView.frame.size.height = self.overviewLabel.frame.size.height + self.overviewLabel.frame.origin.y + 10
                                        self.scrollView.contentSize = CGSize(width: self.scrollView.frame.size.width, height: 60 + self.infoView.frame.origin.y + self.infoView.frame.size.height)
                                        
                                        self.releaseDate.text = responseDictionary.value(forKey: "release_date") as! String?
                                        //self.voteAverage.text = String(responseDictionary.value(forKey: "vote_average") as! String?
                                    }
                                    
                                }
            })
        // Hide HUD once the network request comes back (must be done on main UI thread)
        MBProgressHUD.hide(for: self.view, animated: true)
        task.resume()
    }
    
    @IBAction func unwindToDetailViewController(segue: UIStoryboardSegue) {}
    
    @IBAction func onPresentModal(_ sender: Any) {
        performSegue(withIdentifier: "zoomPoster", sender: self)
        
        let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let posterVC = mainStoryboard.instantiateViewController(withIdentifier: "posterVC") as! PosterViewController
        
        self.present(posterVC, animated: true, completion: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /*
    // MARK: - Navigation
    // In a storyboard-based application, you will often want to do a little preparation before navigation
     */
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        let posterViewController = segue.destination as! PosterViewController
        posterViewController.posterView = posterView.image
    }
 

}
