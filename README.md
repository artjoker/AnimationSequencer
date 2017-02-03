# SequenceAnimator

## Usage

* Just create array of instances of AnimationClosure and call animateSequence

```swift 
        let view1 = UIView()
        view1.alpha = 0
        let closure1 = AnimationClosure(duration: 1) {
            view1.alpha = 1
        }

        let view2 = UIView()
        view2.alpha = 0
        let closure1 = AnimationClosure(duration: 1) {
            view2.alpha = 1
        }

        SequenceAnimator().animateSequence(animationEvents: [closure1, 1, closure2], completion: nil)

```

* or call generateAnimatedBlocksFrom. You can also call .shuffled() to shuffle animations

```swift 
        let view = UIView()
        let view2 = UIView()
        let blocks = generateAnimatedBlocksFrom(collection: [view, view2], forDuration: 1) { (view) in
            view.alpha = 0.5
        }
        animateSequence(animationEvents: blocks.shuffled(), completion: nil)
        // OR
        animateSequence(animationEvents: blocks, interval: 1, pauseInterval: 1, completion: nil)
```

* if you want to do some preparation before animation call prepareViews(_ views: [UIView]..., withBlock preparationBlock: AnimationBlock)

```swift 

        let view = UIView()
        let view2 = UIView()

        prepareViews([view, view2]) { (view) in
            view.alpha = 0
        }

```

* if you have tagged collection you want to animate sequently you should look for generateAnimatedBlocksFrom(taggedCollection:  ...)

```swift 
        let blocks = animator.generateAnimatedBlocksFrom(taggedCollection:  giftsImageViews!, forDuration: interval) { (view) in
            view.alpha = 1
            view.transform = CGAffineTransform.init(scaleX: 1, y: 1)
        }
```


## Author

Alexey Kolyadenko, kolyadenko.kks@gmail.com

## License

SequenceAnimator is available under the MIT license. See the LICENSE file for more info.