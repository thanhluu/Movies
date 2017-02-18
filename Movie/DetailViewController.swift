//
//  DetailViewController.swift
//  Movie
//
//  Created by Luu Tien Thanh on 2/17/17.
//  Copyright © 2017 Luu Tien Thanh. All rights reserved.
//

import UIKit
import AFNetworking

class DetailViewController: UIViewController {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var overviewLabel: UILabel!
    @IBOutlet weak var posterView: UIImageView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var infoView: UIView!
    @IBOutlet weak var releaseDate: UILabel!
    @IBOutlet weak var voteAverage: UILabel!
    
    var overview: String!
    var movieTitle: String!
    var poster: String!
    var releaseDateText: String!
    var voteText: Double!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        titleLabel.text = movieTitle
        titleLabel.sizeToFit()
        overviewLabel.text = overview
        overviewLabel.sizeToFit()
        infoView.frame.size.height = overviewLabel.frame.size.height + overviewLabel.frame.origin.y + 10
        scrollView.contentSize = CGSize(width: scrollView.frame.size.width, height: 60 + infoView.frame.origin.y + infoView.frame.size.height)
  
        releaseDate.text = releaseDateText
        voteAverage.text = String(voteText)
        
        if let posterPath = poster {
            let posterBaseUrl = "http://image.tmdb.org/t/p/w500"
            posterView.setImageWith(URL(string: posterBaseUrl + posterPath)!)
        }
        else {
            // No poster image. Can either set to nil (no image) or a default movie poster image
            // that you include as an asset
            posterView.image = nil
        }

        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
