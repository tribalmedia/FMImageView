//
//  FMDelegateProtocol.swift
//  FMImageView
//
//  Created by Hoang Trong Anh on 7/5/18.
//  Copyright © 2018 Hoang Trong Anh. All rights reserved.
//

import Foundation

struct TypeName {
    enum Scroll {
        case sc_disable
        case sc_enable
    }
    
    enum Modal {
        case md_dismiss
    }
    
    enum Swipe {
        case enable
        case disable
    }
    
    enum Elasticity {
        case elasticity_in
        case elasticity_out
    }
}

protocol ImagePreviewFMDelegate: class {
    func notificationHandlingModal(type: TypeName.Modal)
    func notificationHandlingSwipe(type: TypeName.Swipe)
    func notificationHandlingElasticityOfTopViewAndBottomView(type: TypeName.Elasticity)
    
}

extension ImagePreviewFMDelegate {
    // set optional func of delegate
}

protocol ImageSlideFMDelegate: class {
    func handlingModal(type: TypeName.Modal)
    func handlingSwipe(type: TypeName.Swipe)
    func handlingElasticityOfTopViewAndBottomView(type: TypeName.Elasticity)
}

extension ImageSlideFMDelegate {
    // set optional func of delegate
}
