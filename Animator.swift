//
//  Animator.swift
//  Star Bar
//
//  Created by Alexey Kolyadenko on 30.12.16.
//  Copyright © 2016 dev. All rights reserved.
//

import UIKit


// MARK: - Animator

protocol AnimationEvent {
    var closure: () -> Void { get set }
    var duration: TimeInterval { get set }
}

struct AnimationClosure: AnimationEvent {
    var duration: TimeInterval
    var closure: () -> Void
    
    func closureByAppending(closure: @escaping () -> Void) -> AnimationClosure {
        return AnimationClosure(duration: duration) {
            self.closure()
            closure()
        }
    }
}

extension TimeInterval: AnimationEvent {
    var closure: () -> Void {
        get {
            return { }
        }
        set(value) {
            
        }
    }
    var duration: TimeInterval {
        get {
            return self
        }
        set (value) {
            self = value
        }
    }
}

extension Array where Element: AnimationEvent {
    func delayBetween(delay: TimeInterval) -> [AnimationEvent] {
        var array = [AnimationEvent]()
        for closure in self {
            array.append(closure)
            array.append(delay)
        }
        return array
    }
    
    func shuffled() -> [AnimationEvent] {
        if count < 2 { return self }
        var list = self
        for i in 0..<(list.count - 1) {
            let j = Int(arc4random_uniform(UInt32(list.count - i))) + i
            swap(&list[i], &list[j])
        }
        return list
    }
}



class SequenceAnimator {
    typealias AnimationBlock = (_ view: UIView) -> Void
    
    func prepareViews(_ views: [UIView]..., withBlock preparationBlock: AnimationBlock) {
        views.forEach { (array) in
            array.forEach(preparationBlock)
        }
    }
    
    func generateAnimatedBlocksFrom(collection: [UIView], forDuration duration: TimeInterval, withAnimationBlock animationBlock: @escaping AnimationBlock) -> [AnimationClosure] {
        
        var animationBlocks = [() -> Void]()
        for view in collection {
            let block = {
                animationBlock(view)
            }
            animationBlocks.append(block)
        }
        
        return animationBlocks.map({ (closure) -> AnimationClosure in
            AnimationClosure(duration: duration, closure: closure)
        })
    }
    
    func generateAnimatedBlocksFrom(taggedCollection collection: [UIView], forDuration duration: TimeInterval, withAnimationBlock animationBlock: @escaping AnimationBlock) -> [AnimationClosure] {
        let count = collection.count
        var taggedSortedArrays = [[UIView]]()
        
        for i in 0...count {
            var animatableViewWithTag = [UIView]()
            
            collection.forEach({ (view) in
                if view.tag == i {
                    animatableViewWithTag.append(view)
                }
            })
            if animatableViewWithTag.count > 0 {
                taggedSortedArrays.append(animatableViewWithTag)
            }
        }
        var animationBlocks = [() -> Void]()
        for array in taggedSortedArrays {
            let block = {
                for view in array {
                    animationBlock(view)
                }
            }
            animationBlocks.append(block)
        }
        
        return animationBlocks.map({ (closure) -> AnimationClosure in
            AnimationClosure(duration: duration, closure: closure)
        })
    }
    
    func animateSequence(animationEvents: [AnimationEvent], completion: (() -> Void)?) {
        var animationEvents = animationEvents
        if animationEvents.count > 0 {
            let event = animationEvents.removeFirst()
            var delay: TimeInterval = 0
            if event is TimeInterval {
                delay = event.duration
            }
            let when = DispatchTime.now() + delay
            DispatchQueue.main.asyncAfter(deadline: when) {
                UIView.animate(withDuration: event.duration, delay: delay, options: UIViewAnimationOptions.curveEaseIn, animations: event.closure, completion: { (finished) in
                    if finished {
                            self.animateSequence(animationEvents: animationEvents, completion: completion)
                    }
                })
            }
        }   else {
            completion?()
        }
    }
    
    func animateSequence(animationEvents: [AnimationEvent], interval: TimeInterval, pauseInterval: TimeInterval, completion: (() -> Void)?) {
        var animationEvents = animationEvents
        if animationEvents.count > 0 {
            let event = animationEvents.removeFirst()
            var pauseInterval = pauseInterval
            if event is TimeInterval {
                pauseInterval = pauseInterval + (event as! TimeInterval)
            }
            UIView.animate(withDuration: interval, delay: pauseInterval, options: UIViewAnimationOptions.curveEaseIn, animations: event.closure, completion: { (finished) in
                if finished {
                    self.animateSequence(animationEvents: animationEvents, interval: interval, pauseInterval: pauseInterval, completion: completion)
                }
            })
        }   else {
            completion?()
        }
        
    }
    
    
    
}
