//
//  HelpController.swift
//  dashboard
//
//  Created by Adhikari, Bishrant on 10/22/19.
//  Copyright © 2019 Adhikari, Bishrant. All rights reserved.
//

import UIKit

class HelpController: UIViewController, UIScrollViewDelegate {
    var slides:[HelpSlide] = [];
    @IBOutlet weak var helpScrollView: UIScrollView!
    @IBOutlet weak var helpPageControl: UIPageControl!
    override func viewDidLoad() {
        super.viewDidLoad()
        helpScrollView.delegate = self
        slides = createSlides()
        setupSlideScrollView(slides: slides)
        helpPageControl.numberOfPages = slides.count
        helpPageControl.currentPage = 0
        
        view.bringSubviewToFront(helpPageControl)
    }
    
    @IBAction func goBack(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func test(_ sender: Any) {
        print(1)
    }
    
    func setupSlideScrollView(slides : [HelpSlide]) {
        let statusBarheight = view.window?.windowScene?.statusBarManager?.statusBarFrame.height ?? 0
        let topOffset = 80 + statusBarheight
        helpScrollView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height - topOffset)
        helpScrollView.contentSize = CGSize(width: view.frame.width * CGFloat(slides.count), height: view.frame.height - topOffset)
        helpScrollView.isPagingEnabled = true
        
        for i in 0 ..< slides.count {
            slides[i].frame = CGRect(x: view.frame.width * CGFloat(i), y: 0, width: view.frame.width, height: view.frame.height - topOffset)
            helpScrollView.addSubview(slides[i])
        }
    }
    
    func createSlides() -> [HelpSlide] {

        let slide1:HelpSlide = Bundle.main.loadNibNamed("HelpSlide", owner: self, options: nil)?.first as! HelpSlide
        slide1.HelpImageView.image = UIImage(named: "350")
        slide1.HelpPageTitle.text = "Help Page 1"
        slide1.HelpDescription.text = "Help description for page 1"
        
        let slide2:HelpSlide = Bundle.main.loadNibNamed("HelpSlide", owner: self, options: nil)?.first as! HelpSlide
        slide2.HelpImageView.image = UIImage(named: "350")
        slide2.HelpPageTitle.text = "Help Page 2"
        slide2.HelpDescription.text = "Help description for page 3"
        
        let slide3:HelpSlide = Bundle.main.loadNibNamed("HelpSlide", owner: self, options: nil)?.first as! HelpSlide
        slide3.HelpImageView.image = UIImage(named: "350")
        slide3.HelpPageTitle.text = "Help Page 3"
        slide3.HelpDescription.text = "Help description for page 3"
        
        let slide4:HelpSlide = Bundle.main.loadNibNamed("HelpSlide", owner: self, options: nil)?.first as! HelpSlide
        slide4.HelpImageView.image = UIImage(named: "350")
        slide4.HelpPageTitle.text = "Help Page 4"
        slide4.HelpDescription.text = "Help description for page 4"
        
        
        let slide5:HelpSlide = Bundle.main.loadNibNamed("HelpSlide", owner: self, options: nil)?.first as! HelpSlide
        slide5.HelpImageView.image = UIImage(named: "350")
        slide5.HelpPageTitle.text = "Help Page 5"
        slide5.HelpDescription.text = "Help description for page 5"
        
        return [slide1, slide2, slide3, slide4, slide5]
    }
    
    /*
         * default function called when view is scolled. In order to enable callback
         * when scrollview is scrolled, the below code needs to be called:
         * slideScrollView.delegate = self or
         */
        func scrollViewDidScroll(_ scrollView: UIScrollView) {
            let pageIndex = round(scrollView.contentOffset.x/view.frame.width)
            helpPageControl.currentPage = Int(pageIndex)
            
            let maximumHorizontalOffset: CGFloat = scrollView.contentSize.width - scrollView.frame.width
            let currentHorizontalOffset: CGFloat = scrollView.contentOffset.x
            
            // vertical
            let maximumVerticalOffset: CGFloat = scrollView.contentSize.height - scrollView.frame.height
            let currentVerticalOffset: CGFloat = scrollView.contentOffset.y
            
            let percentageHorizontalOffset: CGFloat = currentHorizontalOffset / maximumHorizontalOffset
            let percentageVerticalOffset: CGFloat = currentVerticalOffset / maximumVerticalOffset
            
            
            /*
             * below code changes the background color of view on paging the scrollview
             */
    //        self.scrollView(scrollView, didScrollToPercentageOffset: percentageHorizontalOffset)
            
        
            /*
             * below code scales the imageview on paging the scrollview
             */
            let percentOffset: CGPoint = CGPoint(x: percentageHorizontalOffset, y: percentageVerticalOffset)
            
            if(percentOffset.x > 0 && percentOffset.x <= 0.25) {
                
                slides[0].HelpImageView.transform = CGAffineTransform(scaleX: (0.25-percentOffset.x)/0.25, y: (0.25-percentOffset.x)/0.25)
                slides[1].HelpImageView.transform = CGAffineTransform(scaleX: percentOffset.x/0.25, y: percentOffset.x/0.25)
                
            } else if(percentOffset.x > 0.25 && percentOffset.x <= 0.50) {
                slides[1].HelpImageView.transform = CGAffineTransform(scaleX: (0.50-percentOffset.x)/0.25, y: (0.50-percentOffset.x)/0.25)
                slides[2].HelpImageView.transform = CGAffineTransform(scaleX: percentOffset.x/0.50, y: percentOffset.x/0.50)
                
            } else if(percentOffset.x > 0.50 && percentOffset.x <= 0.75) {
                slides[2].HelpImageView.transform = CGAffineTransform(scaleX: (0.75-percentOffset.x)/0.25, y: (0.75-percentOffset.x)/0.25)
                slides[3].HelpImageView.transform = CGAffineTransform(scaleX: percentOffset.x/0.75, y: percentOffset.x/0.75)
                
            } else if(percentOffset.x > 0.75 && percentOffset.x <= 1) {
                slides[3].HelpImageView.transform = CGAffineTransform(scaleX: (1-percentOffset.x)/0.25, y: (1-percentOffset.x)/0.25)
                slides[4].HelpImageView.transform = CGAffineTransform(scaleX: percentOffset.x, y: percentOffset.x)
            }
        }
}
