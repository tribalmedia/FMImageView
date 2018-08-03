//
//  UIColor.swift
//  FMImageView
//
//  Created by Hoang Trong Anh on 7/30/18.
//  Copyright © 2018 Hoang Trong Anh. All rights reserved.
//

import UIKit

extension UIColor {
    
    convenience init(hexString: String, alpha: CGFloat = 1.0) {
        let hexString: String = hexString.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        let scanner = Scanner(string: hexString)
        if (hexString.hasPrefix("#")) {
            scanner.scanLocation = 1
        }
        var color: UInt32 = 0
        scanner.scanHexInt32(&color)
        let mask = 0x000000FF
        let r = Int(color >> 16) & mask
        let g = Int(color >> 8) & mask
        let b = Int(color) & mask
        let red   = CGFloat(r) / 255.0
        let green = CGFloat(g) / 255.0
        let blue  = CGFloat(b) / 255.0
        self.init(red:red, green:green, blue:blue, alpha:alpha)
    }
    
    func hexString(withAlpha hasAlpha: Bool = false) -> String? {
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        
        getRed(&r, green: &g, blue: &b, alpha: &a)
        
        guard r >= 0 && r <= 1 && g >= 0 && g <= 1 && b >= 0 && b <= 1 else {
            return nil
        }
        
        func makeChannel(with percentage: CGFloat) -> Int {
            return Int(percentage * 255)
        }
        
        guard hasAlpha else {
            return String(format: "#%02X%02X%02X",
                          makeChannel(with: r),
                          makeChannel(with: g),
                          makeChannel(with: b))
        }
        
        return String(format: "#%02X%02X%02X%02X",
                      makeChannel(with: r),
                      makeChannel(with: g),
                      makeChannel(with: b),
                      makeChannel(with: a))
    }
    
    
    // Get darker color variations for a given UIColor
    func darker(by percentage: CGFloat = 30.0) -> UIColor? {
        return self.adjust(by: -1 * abs(percentage) )
    }
    
    func adjust(by percentage: CGFloat = 30.0) -> UIColor? {
        var red: CGFloat = 0, green: CGFloat = 0, blue: CGFloat = 0, alpha: CGFloat = 0
        
        if self.getRed(&red, green: &green, blue: &blue, alpha: &alpha) {
            return UIColor(red: min(red + percentage / 100, 1.0),
                           green: min(green + percentage / 100, 1.0),
                           blue: min(blue + percentage / 100, 1.0),
                           alpha: alpha)
        } else {
            return nil
        }
    }
    
    func add(overlay: UIColor) -> UIColor {
        var bgR: CGFloat = 0, bgG: CGFloat = 0, bgB: CGFloat = 0, bgA: CGFloat = 0
        var fgR: CGFloat = 0, fgG: CGFloat = 0, fgB: CGFloat = 0, fgA: CGFloat = 0
        
        self.getRed(&bgR, green: &bgG, blue: &bgB, alpha: &bgA)
        overlay.getRed(&fgR, green: &fgG, blue: &fgB, alpha: &fgA)
        
        let r = fgA * fgR + (1 - fgA) * bgR
        let g = fgA * fgG + (1 - fgA) * bgG
        let b = fgA * fgB + (1 - fgA) * bgB
        
        return UIColor(red: r, green: g, blue: b, alpha: 1.0)
    }
    
    func fade(to toColor: UIColor?, withPercentage percentage: CGFloat) -> UIColor? {
        // get the RGBA values from the colours
        var fromRed: CGFloat = 0, fromGreen: CGFloat = 0, fromBlue: CGFloat = 0, fromAlpha: CGFloat = 0
        self.getRed(&fromRed, green: &fromGreen, blue: &fromBlue, alpha: &fromAlpha)
        var toRed: CGFloat = 0, toGreen: CGFloat = 0, toBlue: CGFloat = 0, toAlpha: CGFloat = 0
        toColor?.getRed(&toRed, green: &toGreen, blue: &toBlue, alpha: &toAlpha)
        
        //calculate the actual RGBA values of the fade colour
        let red: CGFloat = (toRed - fromRed) * percentage + fromRed,
            green: CGFloat = (toGreen - fromGreen) * percentage + fromGreen,
            blue: CGFloat = (toBlue - fromBlue) * percentage + fromBlue,
            alpha: CGFloat = (toAlpha - fromAlpha) * percentage + fromAlpha
        
        // return the fade colour
        return UIColor(red: red, green: green, blue: blue, alpha: alpha)
    }
}
