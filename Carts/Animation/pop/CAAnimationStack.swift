//
//  CAAnimationStack.swift
//  Carts
//
//  Created by Hakon Hanesand on 4/26/15.
//  Copyright (c) 2015 Hakon Hanesand. All rights reserved.
//

import UIKit

class CAAnimationStack: NSObject {
   
    var stack: Array<CAStoredAnimation>
    
    override required init() {
        stack = []
        super.init()
    }
    
    func pushAnimation(animation: POPSpringAnimation, targetObject: AnyObject, description: String) {
        targetObject.pop_addAnimation(animation, forKey: description)
        let reversedAnimation = CAStoredAnimation(spring: animation.reverse(), description: description, targetObject: targetObject)
        self.stack.append(reversedAnimation)
    }
    
    func popAnimation() -> RACSignal {
        let top = self.stack.removeLast()
        top.startAnimation()
        return top.animation.completionSignal()
    }
    
    func popAllAnimation() -> RACSignal {
        let array = NSMutableArray(array: self.stack)

        return array.rac_sequence.signal().doNext({ (next: AnyObject!) -> () in
            let ani = next as! CAStoredAnimation
            ani.startAnimation()
        }).flattenMap({ (next: AnyObject!) -> RACStream! in
            let ani = next as! CAStoredAnimation
            return ani.animation.completionSignal()
        }).doCompleted {
            self.stack.removeAll(keepCapacity: true)
        }
    }
    
    func popAnimationWithTargetObject(targetObject: AnyObject) -> RACSignal {
        let array = NSMutableArray(array: self.stack)
        
        return array.rac_sequence.signal().filter({ (next: AnyObject!) -> Bool in
            let ani = next as! CAStoredAnimation
            return ani.targetObject.isEqual(targetObject)
        }).doNext({ (next: AnyObject!) -> Void in
            let ani = next as! CAStoredAnimation
            ani.startAnimation()
            self.stack.removeAtIndex(find(self.stack, ani)!)
        }).flattenMap({ (next: AnyObject!) -> RACStream! in
            let ani = next as! CAStoredAnimation
            return ani.animation.completionSignal()
        })
    }
}
