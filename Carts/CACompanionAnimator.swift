//
//  CACompanionAnimator.swift
//  Carts
//
//  Created by Hakon Hanesand on 4/26/15.
//  Copyright (c) 2015 Hakon Hanesand. All rights reserved.
//

protocol CACompanionAnimator {
    var forwardsAction: (() -> ())? {get set}
    var backwardsAction: (() -> ())? {get set}
}