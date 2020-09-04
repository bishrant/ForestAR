//
//  ViewController.swift
//  forestaar
//
//  Created by Adhikari, Bishrant on 10/16/19.
//  Copyright © 2019 Adhikari, Bishrant. All rights reserved.
//

import UIKit
import SQLite3

class ViewController: UIViewController {
    internal var imageViewBackground: UIImageView!
    @IBOutlet weak var LeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var tfsLogo: UIImageView!
    @IBOutlet weak var MenuBtn: UIButton!
    @IBOutlet weak var TrailingConstraint: NSLayoutConstraint!;
    
    @IBOutlet weak var tfsLogoWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var instructionConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var startScanningBtn: UIButton!
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    var timer: Timer!;
    override func viewDidLoad() {
        super.viewDidLoad()
        self.startScanningBtn.isEnabled = false;
        self.showInitialWalkthrough()
        Service.sharedInstance.triggerInit();
        TrailingConstraint.constant = self.view.frame.width;
        let gradientView = GradientView(frame: self.view.bounds)
        self.view.insertSubview(gradientView, at: 0)
        
        self.imageViewBackground = self.getBackground()
        self.view.addSubview(imageViewBackground)
        self.view.sendSubviewToBack(imageViewBackground)
        
        self.setupLogoClick()
        self.adjustInstructionConstraint()
        navigationController?.setNavigationBarHidden(true, animated: false)
        
        tfsLogoWidthConstraint.constant =  view.frame.width > 500 ? 190 : 150
        
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(self.checkAppStatus), userInfo: nil, repeats: true)
    }
    
    @objc
    func checkAppStatus() {
        if Service.sharedInstance.downloadComplete {
            timer.invalidate();
            loadingIndicator.isHidden = true
            self.startScanningBtn.isEnabled = true;
        } else {
            self.startScanningBtn.isEnabled = false;
        }
    }
    
    func adjustInstructionConstraint() {
        self.instructionConstraint.constant = UIDevice.current.orientation.isLandscape ? -10 : -30
    }
    
    @objc func goToTFSHome(){
        guard let url = URL(string: "https://tfsweb.tamu.edu") else { return }
        UIApplication.shared.open(url)
        
    }
    func setupLogoClick() {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(goToTFSHome))
        tfsLogo.isUserInteractionEnabled = true
        tfsLogo.addGestureRecognizer(tapGestureRecognizer)
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        coordinator.animate(alongsideTransition: { (context) in
        }) { (context) in
            self.imageViewBackground.frame.size = size
            self.TrailingConstraint.constant = self.TrailingConstraint.constant == 0 ? 0: self.view.frame.width
            self.adjustInstructionConstraint()
        }
    }
    
    func getBackground() -> UIImageView {
        let width = UIScreen.main.bounds.size.width
        let height = UIScreen.main.bounds.size.height
        let imageViewBackground = UIImageView(frame: CGRect(x: 0, y: 0, width: width, height: height))
        imageViewBackground.image = UIImage(named: "Fort Davis 2008.jpg")
        imageViewBackground.contentMode = .scaleAspectFill
        return imageViewBackground
    }
    
    @IBAction func showARDashboard(_ sender: Any) {
        self.goToPage(storyboardName: "ARDashboard")
    }
    
    func goToPage(storyboardName: String) {
        let storyboard = UIStoryboard(name: storyboardName, bundle: Bundle.main)
        let destination = storyboard.instantiateViewController(withIdentifier: storyboardName)
        navigationController?.pushViewController(destination, animated: true)
    }
    
    private func toggleMenuFunc() {
        let menuController = MenuViewController();
        menuController.frame = self.view.frame;
        menuController.view.layoutIfNeeded();
        navigationController?.pushViewController(menuController, animated: true)
    }
    
    
    @IBAction func toggleMenu(_ sender: UIButton) {
        toggleMenuFunc();
    }
    
    @IBAction func goToHome(_ sender: UIStoryboardSegue) {}
}



extension ViewController {
    func showInitialWalkthrough() {
        let launchedBefore = UserDefaults.standard.bool(forKey: "launchedBefore")
        if launchedBefore  {
            print("Not first launch.")
        } else {
            print("First launch, setting UserDefault.")
            let storyboard = UIStoryboard(name: "Tutorial", bundle: Bundle.main)
            let destination1 = storyboard.instantiateViewController(withIdentifier: "Tutorial") as! TutorialViewController
            navigationController?.pushViewController(destination1, animated: false)
            UserDefaults.standard.set(true, forKey: "launchedBefore")
        }
    }
}

