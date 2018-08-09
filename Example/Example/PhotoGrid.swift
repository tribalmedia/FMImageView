//
//  PhotoGridView.swift
//  funmee-app
//
//  Created by Duc Nguyen Viet on 7/5/18.
//  Copyright © 2018 Tribal Media Houes.inc. All rights reserved.
//

import UIKit
import FMImageView

// ratio of height and width in case >= 5 photos
private let kRectPhotoGridViewHeightRatio: CGFloat = 99/119

// ratio of big photo and small photo in case has 4 photos
private let kImageSizeRatio: CGFloat = 173/304

// padding between photos
private let kPhotoPadding: CGFloat = 3

class PhotoGridView: UIView {
    
    let imageView0 = UIImageView()
    let imageView1 = UIImageView()
    let imageView2 = UIImageView()
    let imageView3 = UIImageView()
    let imageView4 = UIImageView()
    
    // more photo view
    var remainingPhotoLabel = UILabel()
    var morePhotoView = UIView()
    
    var photoUrl: [URL] = [] {
        didSet {
            clearConstraints()
            loadPhoto()
            setFrameHeight(frame: &self.frame)
            setMorePhotoViewAppearance()
            setupConstraint()
        }
    }
    
    weak var delegate: PhotoGridDelegate?
    
    private var allConstraints: [NSLayoutConstraint] = []
    private var horizontalConstraints: [NSLayoutConstraint] = []
    private var verticalConstraints: [NSLayoutConstraint] = []
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupImageViewOption(imageView0)
        setupImageViewOption(imageView1)
        setupImageViewOption(imageView2)
        setupImageViewOption(imageView3)
        setupImageViewOption(imageView4)
        
        addImageView(imageView0)
        addImageView(imageView1)
        addImageView(imageView2)
        addImageView(imageView3)
        addImageView(imageView4)
        
        addImageViewTapGesture()
        
        self.addSubview(morePhotoView)
        setupMorePhotoView()
        addMorePhotoViewTapGesture()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    // MARK: - Public functions
    
    public func getImageView(index: Int) -> UIImageView {
        switch index {
        case 0:
            return self.imageView0
            
        case 1:
            return self.imageView1
            
        case 2:
            return self.imageView2
            
        case 3:
            return self.imageView3
            
        default:
            return self.imageView4
        }
    }
    
    private func addImageView(_ imgView: UIImageView) {
        self.addSubview(imgView)
    }
    
    // MARK: Setup Tap Gesture
    private func addImageViewTapGesture() {
        addImageView0TapGesture()
        addImageView1TapGesture()
        addImageView2TapGesture()
        addImageView3TapGesture()
        addImageView4TapGesture()
    }
    
    // image0
    private func addImageView0TapGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(image0TapGesture))
        imageView0.addGestureRecognizer(tapGesture)
    }
    
    @objc private func image0TapGesture(_ gesture: UITapGestureRecognizer) {
        delegate?.didSelect(index: 0, imageView: imageView0)
    }
    
    // image1
    private func addImageView1TapGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(image1TapGesture))
        imageView1.addGestureRecognizer(tapGesture)
    }
    
    @objc private func image1TapGesture(_ gesture: UITapGestureRecognizer) {
        delegate?.didSelect(index: 1, imageView: imageView1)
    }
    
    // image2
    private func addImageView2TapGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(image2TapGesture))
        imageView2.addGestureRecognizer(tapGesture)
    }
    
    @objc private func image2TapGesture(_ gesture: UITapGestureRecognizer) {
        delegate?.didSelect(index: 2, imageView: imageView2)
    }
    
    // image3
    private func addImageView3TapGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(image3TapGesture))
        imageView3.addGestureRecognizer(tapGesture)
    }
    
    @objc private func image3TapGesture(_ gesture: UITapGestureRecognizer) {
        delegate?.didSelect(index: 3, imageView: imageView3)
    }
    
    // image4
    private func addImageView4TapGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(image4TapGesture))
        imageView4.addGestureRecognizer(tapGesture)
    }
    
    @objc private func image4TapGesture(_ gesture: UITapGestureRecognizer) {
        delegate?.didSelect(index: 4, imageView: imageView4)
    }
    
    // more photo's view
    private func addMorePhotoViewTapGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(image4TapGesture))
        morePhotoView.addGestureRecognizer(tapGesture)
    }
    
    private func clearConstraints() {
        self.removeConstraints(allConstraints)
    }
    
    private func collectConstraints(_ constraint: [NSLayoutConstraint]) {
        self.addConstraints(constraint)
        allConstraints.append(contentsOf: constraint)
    }
    
    private func setupMorePhotoView() {
        remainingPhotoLabel.translatesAutoresizingMaskIntoConstraints = false
        remainingPhotoLabel.font = UIFont.systemFont(ofSize: 25)
        remainingPhotoLabel.textColor = UIColor.white
        
        morePhotoView.translatesAutoresizingMaskIntoConstraints = false
        morePhotoView.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        morePhotoView.addSubview(remainingPhotoLabel)
        
        let horizontalConstraint = NSLayoutConstraint(item: remainingPhotoLabel, attribute: .centerX, relatedBy: .equal, toItem: morePhotoView, attribute: .centerX, multiplier: 1, constant: 0)
        let verticalConstraint = NSLayoutConstraint(item: remainingPhotoLabel, attribute: .centerY, relatedBy: .equal, toItem: morePhotoView, attribute: .centerY, multiplier: 1, constant: 0)
        morePhotoView.addConstraint(horizontalConstraint)
        morePhotoView.addConstraint(verticalConstraint)
        
        morePhotoView.isUserInteractionEnabled = true
    }
    
    // MARK: Load photos by url into PhotoGridView
    private func loadPhoto() {
        for (index, photoUrl) in photoUrl.enumerated() {
            if index > 4 {
                return
            }
            
            // update new photos
//            (self.subviews[index] as? UIImageView)?.sd_setImage(with: photoUrl, completed: nil)
            ImageLoader.sharedLoader.imageForUrl(url: photoUrl) { (image, urlString, networkErr) in
                (self.subviews[index] as? UIImageView)?.image = image
            }
        }
        // clear unnecessary photos
        if self.photoUrl.count < 5 {
            for i in stride(from: 5, to: self.photoUrl.count, by: -1) {
                (self.subviews[i-1] as? UIImageView)?.image = nil
            }
        }
    }
    
    private func setMorePhotoViewAppearance() {
        if photoUrl.count > 5 {
            morePhotoView.isHidden = false
        } else {
            morePhotoView.isHidden = true
        }
    }
    
    private func setFrameHeight(frame: inout CGRect) {
        var photoViewHeight: CGFloat = self.frame.width
        switch photoUrl.count {
        case 1, 3, 4:
            break
        case 2:
            photoViewHeight = (self.frame.width - kPhotoPadding) / 2
        default:
            let firstRowPhotoHeight = (self.frame.width - kPhotoPadding) / 2
            let secondRowPhotoHeight = (self.frame.width - kPhotoPadding * 2) / 3
            photoViewHeight = firstRowPhotoHeight + secondRowPhotoHeight + kPhotoPadding
            
        }
        frame = CGRect(x: self.frame.origin.x, y: self.frame.origin.y, width: self.frame.width, height: photoViewHeight)
    }
    
    // MARK: Start setup constraint
    private func setupConstraint() {
        
        for index in 0..<photoUrl.count {
            if index > 4 {
                break
            }
            // photo size for each photo
            let currentPhotoSize = photoSize(photoPosition: index)
            let metric = ["w": currentPhotoSize.width, "h": currentPhotoSize.height, "padding": kPhotoPadding]
            
            // setup constraint for each photo
            switch self.photoUrl.count {
            case 1:
                constraintForViewHasOnePhoto(metric)
            case 2:
                constraintForViewHasTwoPhoto(index, metric)
            case 3:
                constraintForViewHasThreePhoto(index, metric)
            case 4:
                constraintForViewHasFourPhoto(index, metric)
            default:
                constraintForViewHasFivePhoto(index, metric)
            }
        }
    }
    
    // MARK: Constraint photos
    private func constraintForViewHasOnePhoto(_ metric: [String: CGFloat]) {
        horizontalConstraints = NSLayoutConstraint.constraints(withVisualFormat: "H:|[img(w)]", options: [], metrics: metric, views: ["img": imageView0])
        verticalConstraints = NSLayoutConstraint.constraints(withVisualFormat: "V:|[img(h)]", options: [], metrics: metric, views: ["img": imageView0])
        collectConstraints(horizontalConstraints)
        collectConstraints(verticalConstraints)
    }
    
    private func constraintForViewHasTwoPhoto(_ index: Int, _ metric: [String: CGFloat]) {
        switch index {
        case 0:
            // left photo
            horizontalConstraints = NSLayoutConstraint.constraints(withVisualFormat: "H:|[imgLeft(w)]", options: [], metrics: metric, views: ["imgLeft": imageView0])
            verticalConstraints = NSLayoutConstraint.constraints(withVisualFormat: "V:|[imgLeft(h)]", options: [], metrics: metric, views: ["imgLeft": imageView0])
        case 1:
            // right photo
            horizontalConstraints = NSLayoutConstraint.constraints(withVisualFormat: "H:[img0]-padding-[imgRight(w)]", options: [], metrics: metric, views: ["img0": imageView0, "imgRight": imageView1])
            verticalConstraints = NSLayoutConstraint.constraints(withVisualFormat: "V:|[imgRight(h)]", options: [], metrics: metric, views: ["imgRight": imageView1])
        default:
            break
        }
        collectConstraints(horizontalConstraints)
        collectConstraints(verticalConstraints)
    }
    
    private func constraintForViewHasThreePhoto(_ index: Int, _ metric: [String: CGFloat]) {
        switch index {
        case 0:
            // top photo
            horizontalConstraints = NSLayoutConstraint.constraints(withVisualFormat: "H:|[imgTop(w)]", options: [], metrics: metric, views: ["imgTop": imageView0])
            verticalConstraints = NSLayoutConstraint.constraints(withVisualFormat: "V:|[imgTop(h)]", options: [], metrics: metric, views: ["imgTop": imageView0])
        case 1:
            // bottom left photo
            horizontalConstraints = NSLayoutConstraint.constraints(withVisualFormat: "H:|[imgBotLeft(w)]", options: [], metrics: metric, views: ["imgBotLeft": imageView1])
            verticalConstraints = NSLayoutConstraint.constraints(withVisualFormat: "V:[imgTop]-padding-[imgBotLeft(h)]", options: [], metrics: metric, views: ["imgTop": imageView0, "imgBotLeft": imageView1])
        case 2:
            // bottom right photo
            horizontalConstraints = NSLayoutConstraint.constraints(withVisualFormat: "H:[imgBotLeft]-padding-[imgBotRight(w)]", options: [], metrics: metric, views: ["imgBotLeft": imageView1, "imgBotRight": imageView2])
            verticalConstraints = NSLayoutConstraint.constraints(withVisualFormat: "V:[imgTop]-padding-[imgBotRight(h)]", options: [], metrics: metric, views: ["imgTop": imageView0, "imgBotRight": imageView2])
        default:
            break
        }
        collectConstraints(horizontalConstraints)
        collectConstraints(verticalConstraints)
    }
    
    private func constraintForViewHasFourPhoto(_ index: Int, _ metric: [String: CGFloat]) {
        switch index {
        case 0:
            // top left photo
            horizontalConstraints = NSLayoutConstraint.constraints(withVisualFormat: "H:|[imgTopLeft(w)]", options: [], metrics: metric, views: ["imgTopLeft": imageView0])
            verticalConstraints = NSLayoutConstraint.constraints(withVisualFormat: "V:|[imgTopLeft(h)]", options: [], metrics: metric, views: ["imgTopLeft": imageView0])
        case 1:
            // top right photo
            horizontalConstraints = NSLayoutConstraint.constraints(withVisualFormat: "H:[imgTopLeft]-padding-[imgTopRight(w)]", options: [], metrics: metric, views: ["imgTopLeft": imageView0, "imgTopRight": imageView1])
            verticalConstraints = NSLayoutConstraint.constraints(withVisualFormat: "V:|[imgTopRight(h)]", options: [], metrics: metric, views: ["imgTopRight": imageView1])
        case 2:
            // bottom left photo
            horizontalConstraints = NSLayoutConstraint.constraints(withVisualFormat: "H:|[imgBotLeft(w)]", options: [], metrics: metric, views: ["imgBotLeft": imageView2])
            verticalConstraints = NSLayoutConstraint.constraints(withVisualFormat: "V:[imgTopLeft]-padding-[imgBotLeft(h)]", options: [], metrics: metric, views: ["imgTopLeft": imageView0, "imgBotLeft": imageView2])
        case 3:
            // bottom right photo
            horizontalConstraints = NSLayoutConstraint.constraints(withVisualFormat: "H:[imgBotLeft]-padding-[imgBotRight(w)]", options: [], metrics: metric, views: ["imgBotLeft": imageView2, "imgBotRight": imageView3])
            verticalConstraints = NSLayoutConstraint.constraints(withVisualFormat: "V:[imgTopRight]-padding-[imgBotRight(h)]", options: [], metrics: metric, views: ["imgTopRight": self.subviews[1], "imgBotRight": imageView3])
        default:
            break
        }
        collectConstraints(horizontalConstraints)
        collectConstraints(verticalConstraints)
    }
    
    private func constraintForViewHasFivePhoto(_ index: Int, _ metric: [String: CGFloat]) {
        switch index {
        case 0:
            // top left photo
            horizontalConstraints = NSLayoutConstraint.constraints(withVisualFormat: "H:|[imgTopLeft(w)]", options: [], metrics: metric, views: ["imgTopLeft": imageView0])
            verticalConstraints = NSLayoutConstraint.constraints(withVisualFormat: "V:|[imgTopLeft(h)]", options: [], metrics: metric, views: ["imgTopLeft": imageView0])
        case 1:
            // top right photo
            horizontalConstraints = NSLayoutConstraint.constraints(withVisualFormat: "H:[imgTopLeft]-padding-[imgTopRight(w)]", options: [], metrics: metric, views: ["imgTopLeft": imageView0, "imgTopRight": imageView1])
            verticalConstraints = NSLayoutConstraint.constraints(withVisualFormat: "V:|[imgTopRight(h)]", options: [], metrics: metric, views: ["imgTopRight": imageView1])
        case 2:
            // bottom left photo
            horizontalConstraints = NSLayoutConstraint.constraints(withVisualFormat: "H:|[imgBotLeft(w)]", options: [], metrics: metric, views: ["imgBotLeft": imageView2])
            verticalConstraints = NSLayoutConstraint.constraints(withVisualFormat: "V:[imgTopLeft]-padding-[imgBotLeft(h)]", options: [], metrics: metric, views: ["imgTopLeft": imageView0, "imgBotLeft": imageView2])
        case 3:
            // bottom middle photo
            horizontalConstraints = NSLayoutConstraint.constraints(withVisualFormat: "H:[imgBotLeft]-padding-[imgBotMid(w)]", options: [], metrics: metric, views: ["imgBotLeft": imageView2, "imgBotMid": imageView3])
            verticalConstraints = NSLayoutConstraint.constraints(withVisualFormat: "V:[imgTopLeft]-padding-[imgBotMid(h)]", options: [], metrics: metric, views: ["imgTopLeft": imageView0, "imgBotMid": imageView3])
        case 4:
            // bottom right photo
            horizontalConstraints = NSLayoutConstraint.constraints(withVisualFormat: "H:[imgBotMid]-padding-[imgBotRight(w)]", options: [], metrics: metric, views: ["imgBotMid": imageView3, "imgBotRight": imageView4])
            verticalConstraints = NSLayoutConstraint.constraints(withVisualFormat: "V:[imgTopRight]-padding-[imgBotRight(h)]", options: [], metrics: metric, views: ["imgTopRight": imageView1, "imgBotRight": imageView4])
            
            if self.photoUrl.count > 5 {
                // add "morePhotoRemaining" layer into last photo's view
                constraintForMorePhotoView(metric)
            }
        default:
            break
        }
        collectConstraints(horizontalConstraints)
        collectConstraints(verticalConstraints)
    }
    
    private func constraintForMorePhotoView(_ metric: [String: CGFloat]) {
        let morePhotoView = self.morePhotoView(width: metric["w"]!, height: metric["h"]!, numberOfRemainingPhoto: self.photoUrl.count - 5)
        
        // set constraint for this view
        let horizontalConstraint = NSLayoutConstraint.constraints(withVisualFormat: "H:[imgBotMid]-padding-[remainPhotoView(w)]", options: [], metrics: metric, views: ["imgBotMid": imageView3, "remainPhotoView": morePhotoView])
        let verticalConstraint = NSLayoutConstraint.constraints(withVisualFormat: "V:[imgTopRight]-padding-[remainPhotoView(h)]", options: [], metrics: metric, views: ["imgTopRight": imageView1, "remainPhotoView": morePhotoView])
        collectConstraints(horizontalConstraint)
        collectConstraints(verticalConstraint)
    }
    
    // MARK: ImageView Options
    private func setupImageViewOption(_ imgView: UIImageView) {
        imgView.isUserInteractionEnabled = true
        imgView.translatesAutoresizingMaskIntoConstraints = false
        imgView.contentMode = .scaleAspectFill
        imgView.clipsToBounds = true
    }
    
    // MARK: Calculate photo size
    private func photoSize(photoPosition: Int) -> CGSize {
        let contentWidth = self.frame.width
        switch self.photoUrl.count {
        // 1 photo
        case 1:
            return CGSize(width: contentWidth, height: contentWidth)
        // 2 photos
        case 2:
            return CGSize(width: (contentWidth - kPhotoPadding) / 2, height: (contentWidth - kPhotoPadding) / 2)
        // 3 photos
        case 3:
            return getPhotoSizeByPositionForThreePhotos(contentWidth, photoPosition)
        // 4 photos
        case 4:
            return getPhotoSizeByPositionForFourPhotos(contentWidth, photoPosition)
        // more than or equal 5 photos
        default:
            return getPhotoSizeByPositionForFivePhotos(contentWidth, photoPosition)
        }
    }
    
    private func getPhotoSizeByPositionForThreePhotos(_ width: CGFloat, _ position: Int) -> CGSize {
        switch position {
        case 0:
            return CGSize(width: width, height: (width - kPhotoPadding) / 2)
        default:
            return CGSize(width: (width - kPhotoPadding) / 2, height: (width - kPhotoPadding) / 2)
        }
    }
    
    private func getPhotoSizeByPositionForFourPhotos(_ width: CGFloat, _ position: Int) -> CGSize {
        switch position {
        case 0, 3:
            let topLeftPhotoWidth = (width - kPhotoPadding) * kImageSizeRatio
            return CGSize(width: topLeftPhotoWidth, height: (width - kPhotoPadding) / 2)
        default:
            let topLeftPhotoWidth = (width - kPhotoPadding) * kImageSizeRatio
            return CGSize(width: width - topLeftPhotoWidth - kPhotoPadding, height: (width - kPhotoPadding) / 2)
        }
    }
    
    private func getPhotoSizeByPositionForFivePhotos(_ width: CGFloat, _ position: Int) -> CGSize {
        switch position {
        case 0, 1:
            return CGSize(width: (width - kPhotoPadding) / 2, height: (width - kPhotoPadding) / 2)
        default:
            let contentHeight = width * kRectPhotoGridViewHeightRatio
            let bottomPhotoHeight = contentHeight - (width - kPhotoPadding) / 2 - kPhotoPadding
            return CGSize(width: bottomPhotoHeight, height: bottomPhotoHeight)
        }
    }
    
    // MARK: MorePhotoView
    private func morePhotoView(width: CGFloat, height: CGFloat, numberOfRemainingPhoto: Int) -> UIView {
        // number of remaining photo
        remainingPhotoLabel.text = "+\(String.init(describing: numberOfRemainingPhoto))"
        
        // uiview that contain number of remaining photo's label
        let frame = CGRect(x: 0, y: 0, width: width, height: height)
        morePhotoView.frame = frame
        
        return morePhotoView
    }
}

protocol PhotoGridDelegate: class {
    func didSelect(index: Int, imageView: UIImageView)
}

