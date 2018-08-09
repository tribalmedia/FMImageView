//
//  ImageCell.swift
//  Example
//
//  Created by Trần Quang Minh on 7/5/18.
//  Copyright © 2018 Hoang Trong Anh. All rights reserved.
//

import UIKit

class ImageCell: UITableViewCell {
    
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var photoGridView: UIView!
    @IBOutlet weak var photoGridHeightConstraint: NSLayoutConstraint!
    
    var presentFMImageView: ((_ index: Int, _ imageView: UIImageView, _ photoURLs: [URL]) -> Void)?
    
    var photoGrid = PhotoGridView(frame: CGRect.zero)
    private var photoUrl: [URL] = [URL(string: "https://media.funmee.jp/medias/6a6bdd8326c225b806021f39e19ed97b1cff8cc5/large.jpg")!,
                                   URL(string: "https://media.funmee.jp/medias/abbdda21d9c5859871bb88b521f6b4d2ab41601a/large.jpg")!,
                                   URL(string: "https://media.funmee.jp/medias/2833d8826ab34e3b9304b62bd3b4bda0164f8004/large.JPG")!,
                                   URL(string: "https://media.funmee.jp/medias/c455f72e904fbe0b22f44084c785f63a5367a54d/large.jpg")!]
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.photoImageView.contentMode = .scaleAspectFill
        self.photoImageView.clipsToBounds = true
        
        photoGrid.delegate = self
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func updateCell() {
        let photoGridWidth = UIScreen.main.bounds.width - 16 * 2
        photoGrid.frame = CGRect(x: 0, y: 0, width: photoGridWidth, height: photoGridWidth)
        photoGrid.photoUrl = photoUrl
        photoGridHeightConstraint.constant = photoGrid.frame.height
        for view in photoGridView.subviews {
            view.removeFromSuperview()
        }
        photoGridView.addSubview(photoGrid)
    }

}

extension ImageCell: PhotoGridDelegate {
    func didSelect(index: Int, imageView: UIImageView) {
        self.presentFMImageView?(index, imageView, self.photoUrl)
    }
}
