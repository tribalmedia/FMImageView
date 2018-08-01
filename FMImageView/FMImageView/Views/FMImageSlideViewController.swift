//
//  ImageSlideViewController.swift
//  FMImageView
//
//  Created by Hoang Trong Anh on 6/27/18.
//  Copyright © 2018 Hoang Trong Anh. All rights reserved.
//

import UIKit

public class FMImageSlideViewController: UIViewController {
    
    // ***********************************************
    // MARK: Custom variables
    // ***********************************************
    
    // public
    public var subAreaBottomView: [FMTuple] = []
    
    // internal
    var topView: UIView?
    
    var bottomView: HorizontalStackView?
    
    var pageViewController: UIPageViewController?
    
    var scrollView: ImageZoomView!
    
    var config: Config!
    
    var datasource: FMImageDataSource!
    
    var tupleColorBacground: [(pageIndex: Int, hexColor: String)] = []
    
    // private
    private var currentPage: Int = 0 {
        didSet {
            _ = self.setBgColorHexInTupleColorBackground()
        }
    }

    weak var mDelegate: Move?
    
    // outlets
    private var dismissButton: UIButton!
    private var numberImageLabel: UILabel!
    
    private var topConstrainTopView: NSLayoutConstraint?
    private var bottomConstraintStackView: NSLayoutConstraint?
    
    public var swipeInteractionController: FMPhotoInteractionAnimator?
    
    // default init
    public init(config: Config) {
        self.config = config
        super.init(nibName: nil, bundle: nil)
    }
    
    // custom init
    public convenience init(datasource: FMImageDataSource, config: Config) {
        self.init(config: config)
        self.datasource = datasource
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        if !self.config.isBackgroundColorByExtraColorImage {
            self.view.backgroundColor = Constants.Color.cBackgroundColor
        }
        
        // step 1
        self.configurePageViewController()
        // step 2
        self.createFirstScreen()
        // step 3
        self.configureSwipeInteractionController()
        
        // setup alert delegate
        FMAlert.shared.delegate = self
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // hide status bar
        if let window = UIApplication.shared.delegate?.window as? UIWindow {
            window.windowLevel = UIWindowLevelStatusBar + 1
        }
        
        view.frame = UIScreen.main.bounds
        
        self.displayTabBar()
    }
    
    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // show status bar
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
        
        // setup top view when hide status bar
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
        
        self.pageViewController?.view.backgroundColor = .clear
        
        self.addChildViewController(self.pageViewController!)
        self.view.addSubview(pageViewController!.view)
        self.view.sendSubview(toBack: pageViewController!.view)
        
        self.pageViewController!.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.pageViewController!.didMove(toParentViewController: self)
    }
    
    private func createFirstScreen() {
        // Create the first screen
        if let config = self.config, let startingViewController = self.getItemController(config.initIndex) {
            self.pageViewController?.setViewControllers([startingViewController], direction: .forward, animated: true) { (completed) in
                self.prepareNumbersImageLabel()
                self.prepareDismissButton()
                
                self.configSubviewViewController()
            }
        }
    }
    
    private func configureSwipeInteractionController() {
        guard let _ = self.config else { return }
        // init animation transition
        self.swipeInteractionController = FMPhotoInteractionAnimator(viewController: self, fromImageView: self.config!.initImageView)
        
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
        self.updateUINumberImageLabel(numerator: self.config.initIndex)
        
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
    
    func runDelegate(_ sender: UIPanGestureRecognizer) {
        switch sender.state {
        case .began:
            self.handlingElasticityOfTopViewAndBottomView(type: .elasticity_out)
        case .ended, .cancelled, .failed:
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
        guard let numerator = numerator else {
            self.numberImageLabel.text = "1/\(self.datasource.total())"
            return
        }
        
        numberImageLabel.text = "\(numerator + 1)/\(self.datasource.total())"
    }
    
    // ***********************************************
    // MARK: UIPageViewController
    // ***********************************************
    
    private func setBgColorHexInTupleColorBackground() -> Bool {
        if self.tupleColorBacground.contains(where: { ($0.pageIndex == self.currentPage) }) {
            for value in self.tupleColorBacground {
                if value.pageIndex == self.currentPage {
                    
                    self.setBackgroundColorViewController(byHex: value.hexColor)

                    return true
                }
            }
            
            return false
        }
        
        return false
    }
    
    private func setTupleColorBackgroundAndChangeBackgroundView(pageIndex: Int, hexColor: String?) {
        guard let extraColor = hexColor else { return }
        
        if self.tupleColorBacground.count < self.datasource.total() {
            self.tupleColorBacground.append((pageIndex: pageIndex, hexColor: extraColor))
        }
        
        if !self.setBgColorHexInTupleColorBackground() && pageIndex == self.currentPage {
            self.setBackgroundColorViewController(byHex: extraColor)
        }
        
    }
    
    private func setBackgroundColorViewController(byHex hex: String) {
        if self.config.isBackgroundColorByExtraColorImage {
            if let bg = self.view.backgroundColor {
                if bg.toHexString() == hex { return }
            }
            
            UIView.animate(withDuration: Constants.AnimationDuration.defaultDuration, animations: {
                self.view.backgroundColor = UIColor(hexString: hex, alpha: 1.0)
            }, completion: { (success) in
                
            })
        }
    }
    
    fileprivate func getItemController(_ itemIndex: Int) -> UIViewController? {
        
        if itemIndex < self.datasource.total() {
            
            let result = FMImagePreviewViewController()
            
            result.itemIndex = itemIndex
            
            if let fromImage = self.config?.initImageView, itemIndex == self.config?.initIndex {
                result.image = fromImage.image
            } else {
                if self.datasource.useURLs {
                    result.imageURL = self.datasource.selectImageURL(index: itemIndex)
                    
                    self.loadImage(forVC: result)
                } else {
                    result.image = self.datasource.selectImage(index: itemIndex)
                }
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
    
    private func loadImage(forVC vc: FMImagePreviewViewController) {
        DispatchQueue.main.async {
            if vc.slideStatus == .completed {
                FMLoadingView.shared.show(inView: self.view)
            }
        }
    
        vc.image?.fm_setImage(url: vc.imageURL, completed: { (image, error, extraColor) in
            if let image = image {
                vc.update(image: image)
                
                self.setTupleColorBackgroundAndChangeBackgroundView(pageIndex: vc.itemIndex, hexColor: extraColor)
            } else {
                DispatchQueue.main.async {
                    self.swipeInteractionController?.disable()
                    
                    FMAlert.shared.show(inView: self.view, message: "Whoops! Something went wrong.\nPlease try again!")
                }
            }
            
            DispatchQueue.main.async {
                FMLoadingView.shared.hide()
                self.swipeInteractionController?.enable()
            }
        })
    }
    
    private func fadeOut(with duration: TimeInterval = Constants.AnimationDuration.defaultDuration) {
        guard let bottomView = self.bottomView, let topView = self.topView else {
            return
        }
        
        self.topConstrainTopView?.constant = -(self.topView!.frame.height / 2)
        self.bottomConstraintStackView?.constant = bottomView.heightStackView / 2
        
        UIView.animate(withDuration: duration) {
            topView.alpha = 0
            bottomView.alpha = 0
            self.view.layoutIfNeeded()
        }
    }
    
    private func fadeIn(with duration: TimeInterval = Constants.AnimationDuration.defaultDuration) {
        guard let bottomView = self.bottomView, let topView = self.topView else {
            return
        }
        
        self.topConstrainTopView?.constant = Constants.Layout.cTopTV
        self.bottomConstraintStackView?.constant = Constants.Layout.cBottomBV
        
        UIView.animate(withDuration: duration) {
            topView.alpha = 1
            bottomView.alpha = 1
            self.view.layoutIfNeeded()
        }
    }
}

// ***********************************************
// MARK: UIPageViewControllerDataSource
// ***********************************************

extension FMImageSlideViewController: UIPageViewControllerDataSource {
    public func pageViewController(_ pageViewController: UIPageViewController,
                                   viewControllerBefore viewController: UIViewController) -> UIViewController? {
        
        let itemController = viewController as! FMImagePreviewViewController
        
        if itemController.itemIndex > 0 {
            return getItemController(itemController.itemIndex - 1)
        }
        
        return nil
    }
    
    public func pageViewController(_ pageViewController: UIPageViewController,
                                   viewControllerAfter viewController: UIViewController) -> UIViewController? {
        
        let itemController = viewController as! FMImagePreviewViewController
        
        if itemController.itemIndex + 1 < self.datasource.total() {
            return getItemController(itemController.itemIndex + 1)
        }
        
        return nil
        
    }
}

// ***********************************************
// MARK: UIPageViewControllerDelegate
// ***********************************************

extension FMImageSlideViewController: UIPageViewControllerDelegate {
    public func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if let vc = pageViewController.viewControllers?.first as? FMImagePreviewViewController {
            self.updateUINumberImageLabel(numerator: vc.itemIndex)
            vc.slideStatus = .completed
            
            self.currentPage = vc.itemIndex
        }
    }
    
    public func pageViewController(_ pageViewController: UIPageViewController, willTransitionTo pendingViewControllers: [UIViewController]) {
        if let vc = pageViewController.viewControllers?.first as? FMImagePreviewViewController {
            vc.slideStatus = .pendding
        }
    }
}

extension FMImageSlideViewController: ImageSlideFMDelegate {
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
        if type == .elasticity_out {
            self.fadeOut()
        } else {
            self.fadeIn()
        }
    }
}

extension FMImageSlideViewController: RefreshProtocol {
    func refreshHandling() {
        DispatchQueue.main.async {
            FMAlert.shared.hide()
        }
        
        if let vc = self.pageViewController?.viewControllers?.first as? FMImagePreviewViewController {
            self.loadImage(forVC: vc)
        }
    }
}
