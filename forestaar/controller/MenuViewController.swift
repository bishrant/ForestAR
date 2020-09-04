//
//  MenuViewController.swift
//  dashboard
//
//  Created by Adhikari, Bishrant on 9/4/20.
//  Copyright © 2020 Adhikari, Bishrant. All rights reserved.
//

import UIKit
import LinkPresentation

class MenuViewController: UIViewController, MenuDelegate , UIActivityItemSource {
    var metadata: LPLinkMetadata?
    func activityViewController(_ activityViewController: UIActivityViewController, itemForActivityType activityType: UIActivity.ActivityType?) -> Any? {
        return self.metadata?.originalURL;
    }
    
    // The placeholder the share sheet will use while metadata loads
    func activityViewControllerPlaceholderItem(_ activityViewController: UIActivityViewController) -> Any {
        return "Placeholder"
    }
    
    // The item we want the user to act on.
    // The metadata we want the system to represent as a rich link
    func activityViewControllerLinkMetadata(_ activityViewController: UIActivityViewController) -> LPLinkMetadata? {
        let metadata = LPLinkMetadata()
        metadata.originalURL = URL(string: "https://tfsweb.tamu.edu")
        metadata.url = metadata.originalURL;
        metadata.title = "Share ForestAR"
        let iProvider = NSItemProvider(contentsOf: Bundle.main.url(forResource: "forestar", withExtension: "png"))
        metadata.imageProvider = iProvider;
        metadata.iconProvider = metadata.imageProvider
        self.metadata = metadata;
        return metadata;
    }
    func shareClicked(sender: UIButton) {
        
        //        self.metadata = linkMetaData
        let activityVc = UIActivityViewController(activityItems: [self], applicationActivities: nil)
        activityVc.excludedActivityTypes = [.airDrop]
        activityVc.popoverPresentationController?.sourceView = self.view;
        activityVc.popoverPresentationController?.sourceRect = sender.frame;
        
                DispatchQueue.main.async {
        self.present(activityVc, animated: true)
                }
    }
    //
    
    
    var myMenu: MyMenu!;
    func menuSelected(menuName: String) {
        let storyboardId: String
        if (menuName == "HOME") {
            navigationController?.popViewController(animated: true)
        } else {
            switch menuName {
            case "FAVORITES":
                storyboardId = "UserFavourites"
                break
            case "HOW TO":
                storyboardId = "Help"
                break
            default:
                storyboardId = "HOME"
            }
            self.goToPage(storyboardName: storyboardId)
        }
    }
    
    func goToPage(storyboardName: String) {
        let storyboard = UIStoryboard(name: storyboardName, bundle: Bundle.main)
        let destination = storyboard.instantiateViewController(withIdentifier: storyboardName)
        navigationController?.pushViewController(destination, animated: true)
    }
    
    func menuClosed() {
        navigationController?.popViewController(animated: true);
    }
    
    var frame: CGRect!;
    override func viewDidLoad() {
        self.myMenu = MyMenu(frame: self.frame);
        self.view.addSubview(self.myMenu)
        self.view.layoutIfNeeded();
        self.myMenu.delegate = self
    }
    
    override func loadView() {
        let view = UIView();
        self.view = view
    }
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        coordinator.animate(alongsideTransition: { (context) in
        }) { (context) in
            self.frame.size = size;
            self.myMenu.frame.size = size;
            self.view.setNeedsLayout()
        }
    }
    
    
    
    
}
