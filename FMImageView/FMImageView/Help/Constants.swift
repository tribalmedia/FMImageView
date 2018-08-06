//
//  Constants.swift
//  FMImageView
//
//  Created by Hoang Trong Anh on 7/3/18.
//  Copyright © 2018 Hoang Trong Anh. All rights reserved.
//

import Foundation

struct Constants {
    struct Layout {
        // TV : TopView , BV: BottomView
        static let cTopTV: CGFloat = 0.0
        static let cBottomTV: CGFloat = 0.0
        static let cLeadingTV: CGFloat = 0.0
        static let cTrainingTV: CGFloat = 0.0
        static let cHeightTV: CGFloat = 80.0
        static let cBottomBV: CGFloat = 0.0
        static let cHeightBV: CGFloat = 40.0
        
        // Items in TopView
        static let leadingDismissButton: CGFloat = 20.0
    }
    
    struct Color {
        static let cBackgroundColor: UIColor = UIColor(red: 0, green: 0, blue: 0, alpha: 1)
        static let cBackgroundColorHex: String = "#000000"
    }
    
    // ScrollView
    struct Scale {
        static let cMax: CGFloat = 3.0
        static let cMin: CGFloat = 1.0
    }
    
    struct AnimationDuration {
        static let defaultDuration: Double = 0.375
    }
}
