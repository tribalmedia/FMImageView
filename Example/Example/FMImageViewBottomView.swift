//
//  FMImageViewBottomView.swift
//  Example
//
//  Created by Trần Quang Minh on 8/6/18.
//  Copyright © 2018 Hoang Trong Anh. All rights reserved.
//

import UIKit

class FMImageViewBottomView: UIView {
    var stackView: UIStackView?
    
    var subAreaBottomView: [(button: UIButton, label: UILabel)] = []
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    
    func commonInit() {
        let likeButton = UIButton()
        likeButton.setImage(#imageLiteral(resourceName: "icn_like"), for: .normal)
        likeButton.isUserInteractionEnabled = true
        likeButton.addTarget(self, action: #selector(target1(_:)), for: .touchUpInside)
        let label = UILabel()
        label.text = "10"
        
        let button1 = UIButton()
        button1.setImage(#imageLiteral(resourceName: "icn_comment"), for: .normal)
        button1.isUserInteractionEnabled = true
        button1.addTarget(self, action: #selector(target2(_:)), for: .touchUpInside)
        let label1 = UILabel()
        label1.text = "20"
        
        self.subAreaBottomView.append((button: likeButton, label: label))
        self.subAreaBottomView.append((button: button1, label: label1))
        
        self.stackView = UIStackView()
        
        
        self.stackView?.translatesAutoresizingMaskIntoConstraints = false
        self.stackView?.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        self.stackView?.backgroundColor = .red
        self.stackView?.alignment = .center
        self.stackView?.distribution = .equalSpacing
        self.stackView?.axis = .horizontal
        self.stackView?.spacing = 0
        
        self.stackView?.autoresizingMask = [.flexibleWidth, .flexibleHeight, .flexibleBottomMargin]
        
        self.addSubview(self.stackView!)
        
        self.stackView?.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: 0).isActive = true
        self.stackView?.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 0).isActive = true
        self.stackView?.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: 0).isActive = true
        
        for value in subAreaBottomView {
            let stack = UIView()
            
            stack.heightAnchor.constraint(equalToConstant: 40).isActive = true
            stack.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width / CGFloat(self.subAreaBottomView.count)).isActive = true
            
            let subStack = UIView()
            subStack.translatesAutoresizingMaskIntoConstraints = false
            subStack.heightAnchor.constraint(equalToConstant: 40 / 2).isActive = true
            
            // items of sub view
            // ** Buttons **
            value.button.translatesAutoresizingMaskIntoConstraints = false
            value.button.heightAnchor.constraint(equalToConstant: 50).isActive = true
            value.button.widthAnchor.constraint(equalToConstant: 50).isActive = true
            
            subStack.addSubview(value.button)
            
            // ** Labels **
            value.button.leftAnchor.constraint(equalTo: subStack.leftAnchor, constant: 0).isActive = true
            
            value.label.translatesAutoresizingMaskIntoConstraints = false
            value.label.heightAnchor.constraint(equalToConstant: 40 / 2).isActive = true
            value.label.numberOfLines = 1
            value.label.font = UIFont.systemFont(ofSize: 20.0, weight: .bold)
            value.label.textColor = .white
            
            subStack.addSubview(value.label)
            
            // ** Buttons **
            value.button.leadingAnchor.constraint(equalTo: subStack.leadingAnchor, constant: 0).isActive = true
            value.button.centerYAnchor.constraint(equalTo: subStack.centerYAnchor, constant: 0).isActive = true
            
            // ** Labels **
            value.label.trailingAnchor.constraint(equalTo: subStack.trailingAnchor, constant: 0).isActive = true
            value.label.leftAnchor.constraint(equalTo: value.button.rightAnchor, constant: 10).isActive = true
            value.label.centerYAnchor.constraint(equalTo: subStack.centerYAnchor, constant: 0).isActive = true
            
            stack.addSubview(subStack)
            
            // ** subview inside stack **
            subStack.centerYAnchor.constraint(equalTo: stack.centerYAnchor, constant: 0).isActive = true
            subStack.centerXAnchor.constraint(equalTo: stack.centerXAnchor, constant: 0).isActive = true
            
            self.stackView?.addArrangedSubview(stack)
        }
    }
    
    @objc func target1(_ sender: UIButton) {
        print(#function)
    }
    
    @objc func target2(_ sender: UIButton) {
        print(#function)
    }
}
