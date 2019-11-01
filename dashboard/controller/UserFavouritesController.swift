//
//  UserFavouritesController.swift
//  dashboard
//
//  Created by Adhikari, Bishrant on 10/31/19.
//  Copyright © 2019 Adhikari, Bishrant. All rights reserved.
//

import UIKit


class UserFavouritesController: UIViewController, UIGestureRecognizerDelegate {
    var SqliteDb = SqliteDatabase()
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
    
    func setGradientBackground(colorTop: UIColor, colorBottom: UIColor) {
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [colorBottom.cgColor, colorTop.cgColor]
        gradientLayer.endPoint = CGPoint(x: 0.9, y: 0)
        gradientLayer.startPoint = CGPoint(x: 0.00, y: 0.9)

        gradientLayer.locations = [0, 1]
        gradientLayer.frame = self.view.bounds

        self.view?.layer.insertSublayer(gradientLayer, at: 0)
    }
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
                    sb.transform = CGAffineTransform(translationX: 0, y: 0)
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
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    private func getAllFavourites() {
        if SqliteDb.openDB() {
            self.favouritesList = SqliteDb.getFavourites();
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

        }
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
        for fav in self.favouritesList {
            let myView = FavUIView(photoName: fav.photo!)
            
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
            coverImageView.image = imageUtils.getImageFromFullFileName(name: fav.photo!)
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
            
            let deleteBtn: UIButton = DeleteButton(index: fav.id, photoName: fav.photo!, inView: myView)
            print(fav.photo!)
            deleteBtn.setTitle("Delete", for: .normal)
            deleteBtn.addTarget(self, action: #selector(deleteFav(_:)), for: UIControl.Event.touchUpInside)
            deleteBtn.tag = 1
            deleteBtn.isHidden = true
            myView.addSubview(deleteBtn)
            NSLayoutConstraint.activate([
                    deleteBtn.widthAnchor.constraint(equalToConstant: 80),
                    deleteBtn.heightAnchor.constraint(equalToConstant: 40),
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
        print("open pvideo page for ", pView.photoName)
        
        let storyboard = UIStoryboard(name: "VideoPlayer", bundle: Bundle.main)
        let destination1 = storyboard.instantiateViewController(withIdentifier: "VideoPlayer") as! VideoPlayerController
        destination1.photoName = pView.photoName!
        navigationController?.pushViewController(destination1, animated: true)
        
        print(sender)
        
    }
    @objc func deleteFav(_ sender: DeleteButton) {
        UIView.animate(withDuration: 1, animations: {
            sender.inView.layer.opacity = 0
        }, completion: {finished in
            sender.inView.removeFromSuperview()
            let deleteSuccess = self.SqliteDb.deleteFavEntryByPhotoName(photoName: sender.photoName);
            if deleteSuccess {
                self.favouritesList = self.SqliteDb.getFavourites();
                self.getAllFavourites()
                self.view.layoutIfNeeded()
            }
        })

    }
    
    func createButton(id: Int, myView: UIView) -> UIButton {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .green
        button.setTitle("Test Button" + String(id), for: UIControl.State.normal)
        return button
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
    var inView: UIView
    required init(index: Int, photoName: String, inView: UIView){
        self.index = index
        self.photoName = photoName
        self.inView = inView
        super.init(frame: .zero)
        backgroundColor = .red
        translatesAutoresizingMaskIntoConstraints = false
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("not initialized properly")
    }
}

class FavUIView: UIView {
    var photoName: String?
    init(photoName: String) {
        self.photoName = photoName
        
        super.init(frame: CGRect.zero)
        backgroundColor = .white
    }
    
    required init?(coder aDecoder: NSCoder) {
           super.init(coder: aDecoder)
       }
}
