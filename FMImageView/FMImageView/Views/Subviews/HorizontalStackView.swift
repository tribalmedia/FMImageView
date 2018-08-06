//
//  HorizontalStackView.swift
//  FMImageView
//
//  Created by Hoang Trong Anh on 7/3/18.
//  Copyright © 2018 Hoang Trong Anh. All rights reserved.
//

import Foundation

public typealias FMTuple = (button: UIButton, label: UILabel)

public class HorizontalStackView: UIStackView {
    var items: [FMTuple] = []
    
    var _view: UIView?
    
    var heightStackView: CGFloat = Constants.Layout.cHeightBV
    
    init() {
        super.init(frame: CGRect(x: 0, y: UIScreen.main.bounds.height - heightStackView, width: UIScreen.main.bounds.width, height: heightStackView))
    }
    
    public convenience init(items: [FMTuple]) {
        self.init()
        self.items = items
        config()
        
        addItemsToStackView()
    }
    
    public convenience init(view: UIView) {
        self.init()
        self._view = view
        config()
        
        addViewToStackView()
    }
    
    
    required public init(coder: NSCoder) {
        super.init(coder: coder)
        config()
    }
    
    private func config() {
        backgroundColor = .white
        alignment = .center
        distribution = .equalSpacing
        axis = .horizontal
        spacing = 0
        translatesAutoresizingMaskIntoConstraints = false
    }
    
    private func addViewToStackView() {
        guard let view = self._view else {
            return
        }
        
        view.translatesAutoresizingMaskIntoConstraints = false
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        self.addArrangedSubview(view)
        
        view.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
    }
    
    private func addItemsToStackView() {
        
        let kPadding: CGFloat = 10.0
        
        for value in items {
            let stack = UIView()
            
            stack.heightAnchor.constraint(equalToConstant: heightStackView).isActive = true
            stack.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width / CGFloat(self.items.count)).isActive = true
            
            let subStack = UIView()
            subStack.translatesAutoresizingMaskIntoConstraints = false
            subStack.heightAnchor.constraint(equalToConstant: heightStackView / 2).isActive = true
            
            // items of sub view
            // ** Buttons **
            value.button.translatesAutoresizingMaskIntoConstraints = false
            value.button.heightAnchor.constraint(equalToConstant: heightStackView / 2).isActive = true
            value.button.widthAnchor.constraint(equalToConstant: heightStackView / 2).isActive = true
            
            subStack.addSubview(value.button)
            
            // ** Labels **
            value.button.leftAnchor.constraint(equalTo: subStack.leftAnchor, constant: 0).isActive = true
            
            value.label.translatesAutoresizingMaskIntoConstraints = false
            value.label.heightAnchor.constraint(equalToConstant: heightStackView / 2).isActive = true
            value.label.numberOfLines = 1
            value.label.font = UIFont.systemFont(ofSize: 20.0, weight: .bold)
            value.label.textColor = .white
            
            subStack.addSubview(value.label)
            
            // ** Buttons **
            value.button.leadingAnchor.constraint(equalTo: subStack.leadingAnchor, constant: 0).isActive = true
            value.button.centerYAnchor.constraint(equalTo: subStack.centerYAnchor, constant: 0).isActive = true
            
            // ** Labels **
            value.label.trailingAnchor.constraint(equalTo: subStack.trailingAnchor, constant: 0).isActive = true
            value.label.leftAnchor.constraint(equalTo: value.button.rightAnchor, constant: kPadding).isActive = true
            value.label.centerYAnchor.constraint(equalTo: subStack.centerYAnchor, constant: 0).isActive = true
            
            stack.addSubview(subStack)
            
            // ** subview inside stack **
            subStack.centerYAnchor.constraint(equalTo: stack.centerYAnchor, constant: 0).isActive = true
            subStack.centerXAnchor.constraint(equalTo: stack.centerXAnchor, constant: 0).isActive = true
            
            self.addArrangedSubview(stack)
        }
    }
}
