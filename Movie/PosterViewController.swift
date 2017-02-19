//
//  PosterViewController.swift
//  Movie
//
//  Created by Luu Tien Thanh on 2/19/17.
//  Copyright © 2017 Luu Tien Thanh. All rights reserved.
//

import UIKit

class PosterViewController: UIViewController, UIScrollViewDelegate {
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var imageView: UIImageView!
    
    var posterView: UIImage?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(PosterViewController.tappedPosterImage))
        imageView.addGestureRecognizer(tapGesture)
        imageView.isUserInteractionEnabled = true
        imageView.image = posterView
        
        scrollView.delegate = self
        scrollView.minimumZoomScale = 1
        scrollView.maximumZoomScale = 2
        
        //scrollView.contentSize = (posterView?.size)!
        scrollView.zoomScale = 0.5
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tappedPosterImage() {
        performSegue(withIdentifier: "unwindToDetailViewController", sender: self)
    }

}
