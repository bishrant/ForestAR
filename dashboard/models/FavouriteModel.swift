//
//  File.swift
//  dashboard
//
//  Created by Adhikari, Bishrant on 10/22/19.
//  Copyright © 2019 Adhikari, Bishrant. All rights reserved.
//

import UIKit

class FavouriteTableCell: UITableViewCell {
    var cellButton: FavouriteDeleteBtn!
    var cellLabel: UILabel!

    init(frame: CGRect, title: String, id: Int) {
        
        super.init(style: UITableViewCell.CellStyle.default, reuseIdentifier: "cell")
//        print(frame.width, "width of frame", self.frame.width)
        cellLabel = UILabel(frame: CGRect(x: 20, y: 10, width: frame.width-45, height: 40))
        cellLabel.textColor = UIColor.red
        self.backgroundView?.backgroundColor = UIColor.white
        cellLabel.font = UIFont.systemFont(ofSize: 20)
        cellButton = FavouriteDeleteBtn(name: title, id: id);
        cellButton.frame =  CGRect(x: frame.width - 45, y: 10, width: 35, height: 25)
        cellButton.setImage(UIImage(named: "trash"), for: UIControl.State.normal)
        cellButton.imageView?.contentMode = .scaleAspectFit
        addSubview(cellLabel)
        addSubview(cellButton)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
}

class FavouriteDeleteBtn: UIButton {
    var name: String
    var id: Int
    required init(name: String, id: Int) {
        self.name = name
        self.id = id
        super.init(frame: .zero)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class FavouritesStruct {
    var id: Int
    var name: String?
    var link: String?
    init(id: Int, name: String?, link: String?) {
        self.id = id
        self.name = name
        self.link = link
    }
}
