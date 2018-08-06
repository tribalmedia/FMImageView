//
//  ImageSlideViewController.swift
//  FMImageView
//
//  Created by Hoang Trong Anh on 6/27/18.
//  Copyright © 2018 Hoang Trong Anh. All rights reserved.
//

import UIKit

typealias TuplePageColor = (pageIndex: Int, hexColor: String?)

public protocol FMInteration: class {
    func resetOriginFrame(imageIndex: Int, view: UIView, indexPath: IndexPath?)
}

public class FMImageSlideViewController: UIViewController {
    
    // ***********************************************
    // MARK: Custom variables
    // ***********************************************
    
    // public
    public var fmInteractionDelegate: FMInteration?
    
    public var tempolaryIndexPath: IndexPath?
    
    // internal
    var topView: UIView?
    
    var bottomView: HorizontalStackView?
    
    var pageViewController: UIPageViewController?
    
    var scrollView: ImageZoomView!
    
    var config: Config!
    
    var datasource: FMImageDataSource!
    
    var tupleColorBacground: [TuplePageColor] = []
    
    // private
    private var currentPage: Int = 0 {
        didSet {
//            _ = self.setBgColorHexInTupleColorBackground()
            
            self.fmInteractionDelegate?.resetOriginFrame(imageIndex: self.currentPage, view: self.view, indexPath: self.tempolaryIndexPath)
        }
    }
    
    fileprivate var pointAreNotDiscolored: CGPoint = CGPoint.zero

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
        
        if let bgColor = self.config.backgroundColor {
            self.view.backgroundColor = bgColor
        }
        
        self.currentPage = self.config.initIndex
        
        // step 1
        self.configurePageViewController()
        // step 2
        self.createFirstScreen()
        // step 3
        self.configureSwipeInteractionController()
    
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
        
        // mark delegate for pageViewController
        self.configScrollDelegate()
    }
    
    private func configScrollDelegate() {
        if let _ = config.backgroundColor { return }
        
        for subView in self.pageViewController!.view.subviews {
            if let scrollView = subView as? UIScrollView {
                scrollView.delegate = self
                
                scrollView.decelerationRate = UIScrollViewDecelerationRateNormal
            }
        }
    }
    
    private func createFirstScreen() {
        
        guard let config = self.config, let startVC = self.getItemController(config.initIndex) as? FMImagePreviewViewController else { return }
        
        if self.currentPage + 1 < self.datasource.total() {
            //Load to the viewController after the starting VC, then go back to the starting VC
            guard let afterVC = self.getItemController(self.currentPage + 1) else { return }
            self.pageViewController?.setViewControllers([afterVC], direction: .forward, animated: true, completion: nil)
            
            self.pageViewController?.setViewControllers([startVC], direction: .reverse, animated: true) { (completed) in
                self.updateViews()
            }
        } else {
            self.pageViewController?.setViewControllers([startVC], direction: .forward, animated: true) { (completed) in
                self.updateViews()
            }
        }
    }
    
    private func updateViews() {
        self.prepareNumbersImageLabel()
        self.prepareDismissButton()
        
        self.configSubviewViewController()
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
        
        setupBottomSubView()
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
        guard let bottomView = self.config.bottomView else {
            return
        }
        
        self.bottomView = bottomView
        self.view.addSubview(self.bottomView!)
        
        // setup layout
        self.bottomView!.heightAnchor.constraint(equalToConstant: Constants.Layout.cHeightBV).isActive = true
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

    func insertToTupleColorBackground(newItem: TuplePageColor) {
        guard let extraColor = newItem.hexColor else { return }
        
        if self.tupleColorBacground.count < self.datasource.total() && !self.tupleColorBacground.contains(where: { ($0.pageIndex == newItem.pageIndex) }) {
            self.tupleColorBacground.insert(TuplePageColor(pageIndex: newItem.pageIndex, hexColor: extraColor), at: 0)
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
    
    private func getHex(by pageIndex: Int) -> String {
        if self.tupleColorBacground.isEmpty {
            return Constants.Color.cBackgroundColorHex
        }
        
        if let pageColor = self.tupleColorBacground.first(where: { $0.pageIndex == pageIndex}) {
            return pageColor.hexColor ?? Constants.Color.cBackgroundColorHex
        }
        
        return self.tupleColorBacground.last?.hexColor ?? Constants.Color.cBackgroundColorHex
    }
    
    private func getScrollDirection(scrollView: UIScrollView) -> ScrollDirection {
        if scrollView.panGestureRecognizer.translation(in: scrollView.superview).x > 0 {
            return ScrollDirection.left
        }
        
        return ScrollDirection.right
    }
    
    private func getFadeColor(direction: ScrollDirection, percentComplete: CGFloat) -> UIColor? {
        var fadeColor: UIColor? = UIColor(hexString: self.getHex(by: self.currentPage), alpha: 1.0)
        
        var toIndex: Int = 0
        
        switch direction {
        case .left:
            toIndex = self.currentPage - 1
            
            if toIndex < 0 {
                toIndex = 0
            }
        case .right:
            toIndex = self.currentPage + 1
            
            if toIndex > self.datasource.total() {
                toIndex = self.datasource.total()
            }
        default: break
            // mark direction is down or up
        }
        
        if self.tupleColorBacground.contains(where: { ($0.pageIndex == toIndex) }) {
            let percent = percentComplete > 1 ? round(percentComplete) : percentComplete
            fadeColor = fadeColor!.fade(to: UIColor(hexString: self.getHex(by: toIndex), alpha: 1.0), withPercentage: percent)
        }
        
        return fadeColor
    }
}

extension FMImageSlideViewController: UIScrollViewDelegate {
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let point = scrollView.contentOffset

        if self.pointAreNotDiscolored == CGPoint.zero {
            self.pointAreNotDiscolored = point
            
            return
        }
        
        let percentComplete: CGFloat = fabs(point.x - self.pageViewController!.view.frame.size.width) / self.pageViewController!.view.frame.size.width
        
        let direction: ScrollDirection = self.getScrollDirection(scrollView: scrollView)
                
        self.view.backgroundColor = self.getFadeColor(direction: direction, percentComplete: percentComplete)
        
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

//extension FMImageSlideViewController: RefreshProtocol {
//    func refreshHandling() {
//        DispatchQueue.main.async {
//            FMAlert.shared.hide()
//        }
//
//        if let vc = self.pageViewController?.viewControllers?.first as? FMImagePreviewViewController {
//            self.loadImage(forVC: vc)
//        }
//    }
//}
