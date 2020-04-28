//
//  UserFavouritesController.swift
//  dashboard
//
//  Created by Adhikari, Bishrant on 10/31/19.
//  Copyright © 2019 Adhikari, Bishrant. All rights reserved.
//

import UIKit


class UserFavouritesController: UIViewController, UIGestureRecognizerDelegate {
    var favouritesList = [FavouritesStruct] ()
    
    @IBOutlet weak var noFavourites: UILabel!
    @IBOutlet weak var swipeInstructions: UIView!
    @IBAction func goBack(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    lazy var scrollView: UIScrollView = {
        let sView = UIScrollView()
        sView.translatesAutoresizingMaskIntoConstraints = false
        sView.contentSize.height = 2000
        return sView
    }()
    
    let stackView: UIStackView = {
        let v = UIStackView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.axis = .vertical
        v.distribution = .equalSpacing
        v.spacing = 10
        
        return v
    }()
    
    @objc func swipeHandler(_ sender: UISwipeGestureRecognizer){
        for ss: UIView in self.stackView.subviews {
            ss.backgroundColor = .white
            ss.layer.borderWidth = 0
            for sb in ss.subviews {
                if (sb is DeleteButton) {
                    if (sb.tag == 1) {
                        sb.isHidden = true
                    }
                }
                if (sb is UIStackView) {
                    UIView.animate(withDuration: 1, animations: {
                        sb.transform = CGAffineTransform(translationX: 0, y: 0)
                    }, completion: nil)
                    
                }
            }
        }
        
        sender.view?.layer.borderWidth = 2
        for stack in sender.view!.subviews {
            if (stack is UIStackView) {
                stack.transform = CGAffineTransform(translationX: -80, y: 0)
            }
        }
        for btn in sender.view!.subviews {
            if (btn is DeleteButton){
                if (btn.tag == 1) {
                    btn.isHidden = false
                }
            }
        }
    }
    
    @objc func swipeHandlerClose(_ sender: UISwipeGestureRecognizer){
        sender.view?.backgroundColor = .white
        sender.view?.layer.borderWidth = 0
        for stack in sender.view!.subviews {
            if (stack is UIStackView) {
                stack.transform = CGAffineTransform(translationX: 0, y: 0)
            }
        }
        for btn in sender.view!.subviews {
            if (btn is UIButton){
                if (btn.tag == 1) {
                    btn.isHidden = true
                }
            }
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let gradientView = GradientView(frame: self.view.bounds)
        self.view.insertSubview(gradientView, at: 0)
        
        view.addSubview(scrollView)
        getAllFavourites();
        
        self.view.isUserInteractionEnabled = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    private func getAllFavourites() {
        var db: SqliteDatabase!
        db = SqliteDatabase()
        self.favouritesList = db.getFavourites();
        if (self.favouritesList.count > 0) {
            self.swipeInstructions.isHidden = false
            self.noFavourites.isHidden = true
            setupScrollView()
            setupStackView()
            addStackViewButtons()
        } else {
            self.swipeInstructions.isHidden = true
            self.noFavourites.isHidden = false
        }
        db = nil
    }
    
    func setupScrollView() {
        scrollView.topAnchor.constraint(equalTo: swipeInstructions.bottomAnchor, constant: 10).isActive = true
        scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -10).isActive = true
        scrollView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 10).isActive = true
        scrollView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -10).isActive = true
    }
    
    func setupStackView() {
        scrollView.addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.topAnchor.constraint(equalTo: scrollView.topAnchor).isActive = true
        stackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor).isActive = true
        stackView.leftAnchor.constraint(equalTo: scrollView.leftAnchor).isActive = true
        stackView.rightAnchor.constraint(equalTo: scrollView.rightAnchor, constant: 0).isActive = true
    }
    
    
    func addStackViewButtons() {
        for v in stackView.subviews {
            v.removeFromSuperview()
        }
        for fav in self.favouritesList {
            let myView = FavUIView(photoName: fav.photo!, folderName: fav.folderName!)
            
            stackView.addArrangedSubview(myView)
            myView.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: 0).isActive = true
            myView.heightAnchor.constraint(greaterThanOrEqualToConstant: 80).isActive = true
            myView.translatesAutoresizingMaskIntoConstraints = false
            myView.layer.borderColor = UIColor(hexString: "#f0554a").cgColor
            myView.layer.cornerRadius = 10
            myView.layer.masksToBounds = true
            
            let horizonatlStackView = setupHorizontalStack(forView: myView)
            
            myView.addSubview(horizonatlStackView)
            
            NSLayoutConstraint.activate([
                horizonatlStackView.topAnchor.constraint(equalTo: myView.topAnchor),
                horizonatlStackView.bottomAnchor.constraint(equalTo: myView.bottomAnchor),
                horizonatlStackView.leftAnchor.constraint(equalTo: myView.leftAnchor),
                horizonatlStackView.rightAnchor.constraint(equalTo: myView.rightAnchor),
            ])
            
            horizonatlStackView.backgroundColor = .green
            
            let imageUtils = ImageUtils()
            //            let img = UIImage(named: "350")
            let coverImageView = ScaledHeightImageView()
            coverImageView.frame.size.height = 100
            coverImageView.frame.size.width = 100
            coverImageView.image = imageUtils.getImageFromFullFileName(name: fav.photo!, folderName: fav.folderName!)
            coverImageView.contentMode = .scaleAspectFit // OR .scaleAspectFill
            coverImageView.clipsToBounds = true
            coverImageView.translatesAutoresizingMaskIntoConstraints = false
            coverImageView.widthAnchor.constraint(equalToConstant: 120).isActive = true
            
            horizonatlStackView.addArrangedSubview(coverImageView)
            
            let bodyText = UILabel()
            bodyText.translatesAutoresizingMaskIntoConstraints = false
            bodyText.text = fav.name!
            bodyText.textColor = .black
            print(fav.name!)
            bodyText.numberOfLines = 0;
            bodyText.lineBreakMode = .byWordWrapping
            horizonatlStackView.addArrangedSubview(bodyText)
            
            let deleteBtn: UIButton = DeleteButton(index: fav.id, photoName: fav.photo!, inView: myView, folderName: fav.folderName!)
            print(fav.photo!)
            deleteBtn.setTitle("Delete", for: .normal)
            deleteBtn.addTarget(self, action: #selector(deleteFav(_:)), for: UIControl.Event.touchUpInside)
            deleteBtn.tag = 1
            deleteBtn.isHidden = true
            myView.addSubview(deleteBtn)
            NSLayoutConstraint.activate([
                deleteBtn.widthAnchor.constraint(equalToConstant: 80),
                deleteBtn.heightAnchor.constraint(equalToConstant: 80),
                deleteBtn.trailingAnchor.constraint(equalTo: self.stackView.trailingAnchor),
                deleteBtn.centerYAnchor.constraint(equalTo: myView.centerYAnchor)
            ])
            
            let rightSwipe = UISwipeGestureRecognizer(target: self, action: #selector(self.swipeHandler(_:)))
            rightSwipe.direction = .left
            rightSwipe.delegate = self
            myView.addGestureRecognizer(rightSwipe)
            
            let leftSwipe = UISwipeGestureRecognizer(target: self, action: #selector(self.swipeHandlerClose(_:)))
            leftSwipe.direction = .right
            leftSwipe.delegate = self
            myView.addGestureRecognizer(leftSwipe)
            
            let viewTapped = UITapGestureRecognizer(target: self, action: #selector(self.favTapped(_:)))
            viewTapped.delegate = self
            myView.addGestureRecognizer(viewTapped)
        }
        
    }
    
    @objc func favTapped(_ sender: UITapGestureRecognizer){
        let pView = sender.view as! FavUIView
        print("open pvideo page for ", pView.photoName!)
        let storyboard = UIStoryboard(name: "VideoPlayer", bundle: Bundle.main)
        let destination1 = storyboard.instantiateViewController(withIdentifier: "VideoPlayer") as! VideoPlayerController
        destination1.photoName = pView.photoName!
        destination1.folderName = pView.folderName!
        navigationController?.pushViewController(destination1, animated: true)
    }
    
    @objc func deleteFav(_ sender: DeleteButton) {
        var db: SqliteDatabase!
        db = SqliteDatabase()
        UIView.animate(withDuration: 1, animations: {
            sender.inView.layer.opacity = 0
        }, completion: {finished in
            sender.inView.removeFromSuperview()
            let deleteSuccess = db.deleteFavEntryByPhotoName(photoName: sender.photoName, folderName: sender.folderName);
            if deleteSuccess {
                self.favouritesList = db.getFavourites();
                self.getAllFavourites()
                self.view.layoutIfNeeded()
            }
            db = nil
        })
        
    }
    
    func setupHorizontalStack(forView: UIView) -> UIStackView {
        let horizontalStackView = UIStackView()
        horizontalStackView.translatesAutoresizingMaskIntoConstraints = false
        horizontalStackView.axis = .horizontal
        horizontalStackView.distribution = .fill
        horizontalStackView.alignment = .fill
        horizontalStackView.spacing = 10
        horizontalStackView.backgroundColor = .purple
        return horizontalStackView
    }
    
}

class DeleteButton: UIButton {
    var index: Int
    var photoName: String
    var folderName: String
    var inView: UIView
    required init(index: Int, photoName: String, inView: UIView, folderName: String){
        self.index = index
        self.photoName = photoName
        self.inView = inView
        self.folderName = folderName
        super.init(frame: .zero)
        backgroundColor = .red
        translatesAutoresizingMaskIntoConstraints = false
        layer.cornerRadius = 5
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("not initialized properly")
    }
}

class FavUIView: UIView {
    var photoName: String?
    var folderName: String?
    init(photoName: String, folderName: String) {
        self.photoName = photoName
        self.folderName = folderName
        super.init(frame: CGRect.zero)
        backgroundColor = .white
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
