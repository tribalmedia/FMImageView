//
//  ImageSlideViewController.swift
//  FMImageView
//
//  Created by Hoang Trong Anh on 6/27/18.
//  Copyright © 2018 Hoang Trong Anh. All rights reserved.
//

import UIKit

public class ImageSlideViewController: UIViewController {

    // ***********************************************
    // MARK: Custom variables
    // ***********************************************
    
    var images: [UIImage] = []
    
    var imageURLs: [URL] = []
    
    var startIndex = 0
    
    var topView: UIView?
    
    var bottomView: HorizontalStackView?
    
    public var subAreaBottomView: [FMTuple] = []
    
    var pageViewController: UIPageViewController?
    
    var scrollView: ImageZoomView!
    
    weak var mDelegate: Move?
    
    // outlets
    private var dismissButton: UIButton!
    private var numberImageLabel: UILabel!
    
    private var fromImageView: UIImageView?
    
    private var topConstrainTopView: NSLayoutConstraint?
    private var bottomConstraintStackView: NSLayoutConstraint?
    
    public var swipeInteractionController: FMPhotoInteractionAnimator?
    
    public init(urls: [URL], fromImageView: UIImageView?, startIndex: Int = 0) {
        self.imageURLs = urls
        self.fromImageView = fromImageView
        self.startIndex = startIndex
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override public func viewDidLoad() {
        super.viewDidLoad()
        
        // step 1
        self.configurePageViewController()
        // step 2
        self.createFirstScreen()
        // step 3
        self.configureSwipeInteractionController()
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let window = UIApplication.shared.delegate?.window as? UIWindow {
            window.windowLevel = UIWindowLevelStatusBar + 1
        }
        
        view.frame = UIScreen.main.bounds
        
        self.displayTabBar()
    }
    
    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if let window = UIApplication.shared.delegate?.window as? UIWindow {
            window.windowLevel = UIWindowLevelNormal
        }
        
        self.displayTabBar()
    }
    
    private func displayTabBar() {
        guard let _ = self.tabBarController?.tabBar else {
            return
        }
        
        if self.tabBarController!.tabBar.isHidden {
            self.tabBarController?.tabBar.isHidden = false
        } else {
            self.tabBarController?.tabBar.isHidden = true
        }
    }
    
    override public func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if #available(iOS 11, *) {
            // safe area constraints already set
            additionalSafeAreaInsets = UIEdgeInsets(top: -UIApplication.shared.statusBarFrame.height, left: 0, bottom: 0, right: 0)
        } else {
            self.view.topAnchor.constraint(equalTo: topLayoutGuide.topAnchor, constant: 0).isActive = true
        }
    }
    
    private func configurePageViewController() {
        self.pageViewController = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: [UIPageViewControllerOptionInterPageSpacingKey: 16.0])
        self.pageViewController!.dataSource = self
        self.pageViewController!.delegate = self
        
        self.pageViewController?.view.backgroundColor = .black
        
        self.addChildViewController(self.pageViewController!)
        self.view.addSubview(pageViewController!.view)
        self.view.sendSubview(toBack: pageViewController!.view)
        
        self.pageViewController!.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.pageViewController!.didMove(toParentViewController: self)
    }
    
    private func createFirstScreen() {
        // Create the first screen
        if let startingViewController = self.getItemController(startIndex) {
            self.pageViewController?.setViewControllers([startingViewController], direction: .forward, animated: true) { (completed) in
                self.prepareNumbersImageLabel()
                self.prepareDismissButton()
                
                self.configSubviewViewController()
            }
        }
    }
    
    private func configureSwipeInteractionController() {
        guard let _ = self.fromImageView else { return }
        // init animation transition
        self.swipeInteractionController = FMPhotoInteractionAnimator(viewController: self, fromImageView: self.fromImageView!)
        
        self.transitioningDelegate = self.swipeInteractionController
        self.modalPresentationStyle = .custom
        self.modalPresentationCapturesStatusBarAppearance = true
    }
    
    private func prepareNumbersImageLabel() {
        self.numberImageLabel = UILabel()
        self.numberImageLabel.textColor = .white
        self.numberImageLabel.font = UIFont.systemFont(ofSize: 20.0, weight: .bold)
    }
    
    private func prepareDismissButton() {
        self.dismissButton = UIButton(type: .custom)
        self.dismissButton.setImage(UIImage(named: "icn_close", in: Bundle(for: self.classForCoder), compatibleWith: nil), for: .normal)
        self.dismissButton.clipsToBounds = true
        self.dismissButton.addTarget(self, action: #selector(self.dismissTargetButton(_:)), for: .touchUpInside)
    }
    
    @objc func dismissTargetButton(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    private func configSubviewViewController() {
        setupTopSubView()
        
        if !self.subAreaBottomView.isEmpty {
            setupBottomSubView()
        }
    }
    
    private func setupTopSubView() {
        self.updateUINumberImageLabel(numerator: self.startIndex)
        topView = UIView()
        topView?.translatesAutoresizingMaskIntoConstraints = false
        
        self.view.addSubview(topView!)
        
        self.topView?.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: Constants.Layout.cLeadingTV).isActive = true
        self.topView?.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: Constants.Layout.cTrainingTV).isActive = true
        self.topConstrainTopView = self.topView?.topAnchor.constraint(equalTo: self.view.topAnchor, constant: Constants.Layout.cTopTV)
        self.topConstrainTopView?.isActive = true
        self.topView?.heightAnchor.constraint(equalToConstant: Constants.Layout.cHeightTV).isActive = true
        
        let subviews: [UIView] = [ numberImageLabel, dismissButton ]
        
        for v in subviews {
            v.translatesAutoresizingMaskIntoConstraints = false
            topView!.addSubview(v)
        }
        
        NSLayoutConstraint.activate(
            [NSLayoutConstraint(item: dismissButton, attribute: .left, relatedBy: .equal, toItem: topView, attribute: .left, multiplier: 1, constant: Constants.Layout.leadingDismissButton)] +
            [NSLayoutConstraint(item: dismissButton,attribute: .top, relatedBy: .equal, toItem: topView,attribute: .top, multiplier: 1, constant: Constants.Layout.cHeightTV / 2)] +
            [NSLayoutConstraint(item: numberImageLabel,attribute: .centerX, relatedBy: .equal, toItem: topView, attribute: .centerX, multiplier: 1, constant: 0)] +
            [NSLayoutConstraint( item: numberImageLabel, attribute: .top, relatedBy: .equal, toItem: topView, attribute: .top, multiplier: 1, constant: Constants.Layout.cHeightTV / 2)]
        )
        
    }
    
    func  runDelegate(_ sender: UIPanGestureRecognizer) {
        self.mDelegate?.moving(sender)
        
        switch sender.state {
        case .began:
            self.handlingElasticityOfTopViewAndBottomView(type: .elasticity_out)
        case .changed:
            UIView.animate(withDuration: 0.3, animations: {
                self.pageViewController?.view.backgroundColor = UIColor.black.withAlphaComponent(0)
            }, completion: { _ in
                
            })
        case .ended, .cancelled, .failed:
            UIView.animate(withDuration: 0.3, animations: {
                self.pageViewController?.view.backgroundColor = UIColor.black.withAlphaComponent(1)
            })
            self.handlingElasticityOfTopViewAndBottomView(type: .elasticity_in)
        default:
            break
        }
        
    }
    
    private func setupBottomSubView() {
        self.bottomView = HorizontalStackView(items: self.subAreaBottomView)

        self.view.addSubview(self.bottomView!)
        
        self.bottomView!.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 0).isActive = true
        self.bottomView!.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: 0).isActive = true
        self.bottomConstraintStackView = self.bottomView!.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: 0)
        self.bottomConstraintStackView?.isActive = true
    }
    
    private func updateUINumberImageLabel(numerator: Int?) {
        if self.imageURLs.isEmpty {
            return
        }
        
        numberImageLabel.text = numerator == nil ? "1/\(imageURLs.count)" : "\(numerator! + 1)/\(imageURLs.count)"
    }
    
    // ***********************************************
    // MARK: UIPageViewController
    // ***********************************************
    
    fileprivate func getItemController(_ itemIndex: Int) -> UIViewController? {
        
        if itemIndex < self.imageURLs.count {
            
            let result = ImagePreviewViewController()
            
            result.itemIndex = itemIndex
            
            if let fromImage = self.fromImageView?.image, itemIndex == self.startIndex {
                result.image = fromImage
            } else {
                result.imageURL = self.imageURLs[itemIndex]
            }
            if result.scrollView == nil {
                result.scrollView = self.scrollView
            }
            
            result._delegate = self
            
            result.parentVC = self
            
            return result
        }
        
        return nil
    }
}
extension ImageSlideViewController: UIPageViewControllerDataSource {
    public func pageViewController(_ pageViewController: UIPageViewController,
                                   viewControllerBefore viewController: UIViewController) -> UIViewController? {
        
        let itemController = viewController as! ImagePreviewViewController
        
        if itemController.itemIndex > 0 {
            return getItemController(itemController.itemIndex-1)
        }
        
        return nil
    }
    
    public func pageViewController(_ pageViewController: UIPageViewController,
                                   viewControllerAfter viewController: UIViewController) -> UIViewController? {
        
        let itemController = viewController as! ImagePreviewViewController
        
        if itemController.itemIndex+1 < self.imageURLs.count {
            return getItemController(itemController.itemIndex+1)
        }
        
        return nil
        
    }
}

extension ImageSlideViewController: UIPageViewControllerDelegate {
    public func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if let vc = pageViewController.viewControllers?.first as? ImagePreviewViewController {
            self.updateUINumberImageLabel(numerator: vc.itemIndex)
            vc.slideStatus = .completed
        }
    }
    
    public func pageViewController(_ pageViewController: UIPageViewController, willTransitionTo pendingViewControllers: [UIViewController]) {
        if let vc = pageViewController.viewControllers?.first as? ImagePreviewViewController {
            vc.slideStatus = .pendding
        }
    }
}

extension ImageSlideViewController: ImageSlideFMDelegate {
    func handlingModal(type: TypeName.Modal) {
        if type == .md_dismiss {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    func handlingSwipe(type: TypeName.Swipe) {
        guard let scrollView = self.pageViewController!.view.subviews.filter({$0.isKind(of: UIScrollView.self)}).first as? UIScrollView else { return }
        
        if type == .enable {
            swipeInteractionController?.enable()
            scrollView.isScrollEnabled = true
        } else {
            swipeInteractionController?.disable()
            scrollView.isScrollEnabled = false
        }
    }
    
    func handlingElasticityOfTopViewAndBottomView(type: TypeName.Elasticity) {
        guard let _ = self.bottomView, let _ = self.bottomConstraintStackView else { return }
        
        self.bottomConstraintStackView?.isActive = false
        
        if self.bottomConstraintStackView?.constant == Constants.Layout.cBottomBV && type == .elasticity_out {
            self.bottomConstraintStackView?.constant = self.bottomView!.heightStackView
        } else {
            self.bottomConstraintStackView?.constant = Constants.Layout.cBottomBV
        }
        
        self.topConstrainTopView?.isActive = false
        if self.topConstrainTopView?.constant == Constants.Layout.cTopTV && type == .elasticity_out {
            self.topConstrainTopView?.constant = -self.topView!.frame.height
        } else {
           self.topConstrainTopView?.constant = Constants.Layout.cTopTV
        }
        
        UIView.animate(withDuration: 0.3) {
            self.topConstrainTopView?.isActive = true
            self.bottomConstraintStackView?.isActive = true
            self.view.layoutIfNeeded()
        }
    }
}
