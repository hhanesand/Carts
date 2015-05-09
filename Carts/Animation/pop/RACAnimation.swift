//
//  RACAnimation.swift
//  Carts
//
//  Created by Hakon Hanesand on 5/9/15.
//  Copyright (c) 2015 Hakon Hanesand. All rights reserved.

import ReactiveCocoa

extension POPAnimation {
    
    var completionSignal: SignalProducer<POPAnimation, NoError> {
        return SignalProducer { observer, disposable in
            if self.completionBlock {
                println("WARNING : Overriding completion block on POPAnimation \(description)")
            }
            
            self.completionBlock = { animation, done in
                if done {
                    sendNext(observer, animation)
                    sendCompleted(observer)
                }
            }
        }
    }
}