import UIKit

//Struct that stores parameter of one animation
struct AnimationParameters {
    let expandingAnimation: () -> Void
    let collapsingAnimation: () -> Void
    let duration: TimeInterval
    let scrubsLinearly: Bool
    let expandingTimeParameters: UITimingCurveProvider
    let collapsingTimeParameters: UITimingCurveProvider
}

/*
 This class receives events from pan and touch gesture recognizers
 And controls corresponding UIViewPropertyAnimator
 Animation closures are stored in `expandingAnimation` and `collapsingAnimation` properties
 You should provide timing parameters
 */
final class AnimationCoordinator {
    //our controlled animators
    private var animators = [UIViewPropertyAnimator]()
    //progress of animation when user 'captured' it with pan gesture
    private var progressWhenInterrupted = [CGFloat]()
    //height of master view controller
    private let masterHeight: CGFloat
    //visible height of detail view controller from start
    private let startingOffset: CGFloat
    //initial animation direction
    enum AnimationDirection {
        case up, down, undefined
        init(fromVelocity velocity: CGPoint) {
            self = velocity.y < 0 ? .up : .down
        }
    }
    private var initialAnimationDirection: AnimationDirection = .undefined
    //state of detail controller
    enum DetailControllerState {
        case collapsed, expanded
        var inversed: DetailControllerState {
            switch self {
            case .collapsed:
                return .expanded
            case .expanded:
                return .collapsed
            }
        }
    }
    private var state: DetailControllerState = .collapsed
    //stored animation parameters
    private let animationParameters: [AnimationParameters]
    
    init(withMasterViewHeight height: CGFloat, andDetailViewOffset offset: CGFloat, animationParameters: [AnimationParameters]) {
        masterHeight = height
        startingOffset = offset
        self.animationParameters = animationParameters
    }
    
    //Perform animation with animator if not already running
    func initializeAnimators(state: DetailControllerState) {
        //initialize animators
        animators = animationParameters.map {
            var animatorFunction: () -> Void
            var timingParameters: UITimingCurveProvider
            switch state {
            case .collapsed:
                animatorFunction = $0.expandingAnimation
                timingParameters = $0.expandingTimeParameters
            case .expanded:
                animatorFunction = $0.collapsingAnimation
                timingParameters = $0.collapsingTimeParameters
            }
            let animator = UIViewPropertyAnimator(duration: $0.duration, timingParameters: timingParameters)
            animator.scrubsLinearly = $0.scrubsLinearly
            animator.addAnimations(animatorFunction)
            return animator
        }
        //add completion to only first animator
        animators.first?.addCompletion {
            [unowned self] (position) -> Void in
            //nulling directions
            self.initialAnimationDirection = .undefined
            //erasing progress when interrupted
            self.progressWhenInterrupted = [CGFloat]()
            //switching position if it was last animator
            switch position {
            case .start:
                //guess animation is reversed and we returned to starting state
                //so just do nothing
                print("completion with .start with state \(self.state)")
                break
            case .end:
                //just switchng self state
                self.state = self.state.inversed
                print("completion with reversed=\(self.animators.first!.isReversed) .end with state \(self.state.inversed) -> \(self.state)")
            case .current:
                print("completion with .current")
            }
            //nulling animators
            self.animators.removeAll()
        }
        
        //don't forget to initialize animation direction
        switch state {
        case .collapsed:
            initialAnimationDirection = .up
        case .expanded:
            initialAnimationDirection = .down
        }
        
        //start animation
        animators.forEach { $0.startAnimation() }
    }
    
    //Starts transition if necessary or recerses it on tap
    func animateOrReverseRunningTransition(state: DetailControllerState, duration: TimeInterval) {
        if !animators.isEmpty {
            animators.forEach {$0.isReversed = !$0.isReversed}
        } else {
            initializeAnimators(state: state)
        }
    }
    
    func startInteractiveTransition(state: DetailControllerState, duration: TimeInterval) {
        if animators.isEmpty {
            initializeAnimators(state: state)
        }
        animators.forEach {$0.pauseAnimation()}
        progressWhenInterrupted = animators.map{return $0.fractionComplete}
    }
    
    //update animation when user pans
    func updateInteractiveTransition(translation: CGPoint, velocity: CGPoint) {
        var fractionComplete: CGFloat = 0.0
        
        switch initialAnimationDirection {
        case .up:
            fractionComplete = -translation.y / (masterHeight - startingOffset)
        case .down:
            fractionComplete = translation.y / (masterHeight - startingOffset)
        case .undefined:
            break
        }
        
        for (index, animator) in animators.enumerated() {
            //substracting the fraction if the animator is reversed
            if animator.isReversed {fractionComplete *= -1}
            animator.fractionComplete = fractionComplete + progressWhenInterrupted[index]
        }
    }
    
    //finish animation when user finished pan
    func continueInteractiveTransition(translation: CGPoint, velocity: CGPoint) {
        //gesture is considered incomplete if user starts swiping up and detail
        //view is moved less than double height of header
        var gestureIsIncomplete: Bool = false
        if self.state == .collapsed && abs(translation.y) < startingOffset * 2.0 {
            gestureIsIncomplete = false
        }
        
        if velocity.y == 0 {
            //no explicit velocity, just continue animations
            animators.forEach({$0.continueAnimation(withTimingParameters: nil, durationFactor: 0)})
            return
        }
        
        for (index, animator) in animators.enumerated() {
            var timingParameters: UITimingCurveProvider!
            func switchAnimator() {
                animator.isReversed = !animator.isReversed
                if animator.timingParameters === animationParameters[index].expandingTimeParameters {
                    timingParameters = animationParameters[index].collapsingTimeParameters
                } else {
                    timingParameters = animationParameters[index].expandingTimeParameters
                }
                animator.continueAnimation(withTimingParameters: timingParameters, durationFactor: 0)
            }
            
            switch state {
            case .collapsed:
                if velocity.y > 0 && !animator.isReversed {print("switch1 \(velocity.y)");switchAnimator();continue}
                if velocity.y < 0 && animator.isReversed {print("switch2 \(velocity.y)");switchAnimator();continue}
                if gestureIsIncomplete {switchAnimator()}
            case .expanded:
                if velocity.y > 0 && animator.isReversed {print("switch3 \(velocity.y)");switchAnimator();continue}
                if velocity.y < 0 && !animator.isReversed {print("switch4 \(velocity.y)");switchAnimator();continue}
            }
            //deciding which timing parameters to use
            animator.continueAnimation(withTimingParameters: nil, durationFactor: 0)
        }
    }
    
    //MARK: - Gesture recognizers handlers
    
    func handleTap() {
        animateOrReverseRunningTransition(state: state, duration: 1.0)
    }
    
    func handlePan(gestureState: UIGestureRecognizer.State, translation: CGPoint, velocity: CGPoint) {
        switch gestureState {
        case .began:
            startInteractiveTransition(state: state, duration: 1.0)
        case .changed:
            updateInteractiveTransition(translation: translation, velocity: velocity)
        case .ended, .cancelled:
            continueInteractiveTransition(translation: translation, velocity: velocity)
        default:
            break
        }
    }
}
