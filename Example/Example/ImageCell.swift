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
    private var photoUrl: [URL] = [URL(string: "https://cdn.stocksnap.io/img-thumbs/960w/LHOLK9MS1O.jpg")!,
                                   URL(string: "https://cdn.stocksnap.io/img-thumbs/960w/FAOI1VDJBI.jpg")!,
                                   URL(string: "https://cdn.stocksnap.io/img-thumbs/960w/L4B2YC09F2.jpg")!,
                                   URL(string: "https://cdn.stocksnap.io/img-thumbs/960w/GHR0BY9GIJ.jpg")!]
    
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
