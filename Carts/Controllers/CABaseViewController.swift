//
//  CABaseViewController.swift
//  Carts
//
//  Created by Hakon Hanesand on 4/26/15.
//  Copyright (c) 2015 Hakon Hanesand. All rights reserved.

import UIKit

class CABaseViewController: UIViewController {
    
    lazy var animationStack: CAAnimationStack = {
        return CAAnimationStack()
    }()
}
