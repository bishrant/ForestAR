//
//  PlayFavVideoController.swift
//  dashboard
//
//  Created by Adhikari, Bishrant on 10/21/19.
//  Copyright © 2019 Adhikari, Bishrant. All rights reserved.
//

import UIKit

class PlayFavVideoController: UIViewController {

    @IBOutlet weak var idLbl: UILabel!
    var id: Int = 0
    override func viewDidLoad() {
        super.viewDidLoad()
        idLbl.text = String(id)
        setupNavigationBar()
        // Do any additional setup after loading the view.
        
    }
    
    @IBAction func goBack(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    @IBAction func goBackBtn(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    private func setupNavigationBar() {
        navigationController?.title = "Test"
        navigationItem.title = "Favourite";
        
        let t = UIImageView(image: UIImage(named: "menu"))
        navigationItem.titleView = t
        
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
