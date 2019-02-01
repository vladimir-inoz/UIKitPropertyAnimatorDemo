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
    //our controlled animator
    private var animators = [UIViewPropertyAnimator]()
    //progress of animation when user 'captured' it with pan gesture
    private var progressWhenInterrupted: CGFloat = 0.0
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
        //whether current speed is opposite to self
        func isOppositeVelocity(velocity: CGPoint) -> Bool {
            switch self {
            case .up:
                return velocity.y > 0
            case .down:
                return velocity.y < 0
            case .undefined:
                return false
            }
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
    private let animationParameters: AnimationParameters
    
    init(withMasterViewHeight height: CGFloat, andDetailViewOffset offset: CGFloat, animationParameters: AnimationParameters) {
        masterHeight = height
        startingOffset = offset
        self.animationParameters = animationParameters
    }
    
    //Overall animators completion closure
    private lazy var animatorCompletion = {
        [unowned self] (position: UIViewAnimatingPosition) -> Void in
        switch position {
        case .start:
            //guess animation is reversed and we returned to starting state
            //so just do nothing
            break
        case .end:
            //just switchng self state
            self.state = self.state.inversed
        default:
            break
        }
        //nulling directions
        self.initialAnimationDirection = .undefined
        //erasing progress when interrupted
        self.progressWhenInterrupted = 0.0
        //nulling animator
        self.animators.removeAll(keepingCapacity: true)
    }
    
    //Perform animation with animator if not already running
    func animateTransitionIfNeeded(state: DetailControllerState) {
        if animators.isEmpty {
            var animatorFunction: () -> Void
            var timingParameters: UITimingCurveProvider
            switch state {
            case .expanded:
                animatorFunction = animationParameters.expandingAnimation
                timingParameters = animationParameters.expandingTimeParameters
            case .collapsed:
                animatorFunction = animationParameters.collapsingAnimation
                timingParameters = animationParameters.collapsingTimeParameters
            }
            let animator = UIViewPropertyAnimator(duration: animationParameters.duration, timingParameters: timingParameters)
            animator.scrubsLinearly = animationParameters.scrubsLinearly
            animator.addAnimations(animatorFunction)
            animator.addCompletion(animatorCompletion)
            
            animators.append(animator)
            
            animator.startAnimation()
        }
    }
    
    //Starts transition if necessary or recerses it on tap
    func animateOrReverseRunningTransition(state: DetailControllerState, duration: TimeInterval) {
        if animators.isEmpty {
            animateTransitionIfNeeded(state: state)
        } else {
            for animator in animators {
                animator.isReversed = !animator.isReversed
            }
        }
    }
    
    func startInteractiveTransition(state: DetailControllerState, duration: TimeInterval) {
        if animators.isEmpty {
            animateTransitionIfNeeded(state: state)
        } else {
            progressWhenInterrupted = animators.first!.fractionComplete
        }
        
        for animator in animators {
            animator.pauseAnimation()
        }
    }
    
    //update animation when user pans
    func updateInteractiveTransition(translation: CGPoint, velocity: CGPoint) {
        for animator in animators {
            if initialAnimationDirection == .undefined {
                initialAnimationDirection = AnimationDirection(fromVelocity: velocity)
            }
            
            var fractionComplete: CGFloat = 0.0
            
            switch initialAnimationDirection {
            case .up:
                fractionComplete = -translation.y / (masterHeight - startingOffset)
            case .down:
                fractionComplete = translation.y / (masterHeight - startingOffset)
            case .undefined:
                break
            }
            
            //substracting the fraction if the animator is reversed
            if animator.isReversed {fractionComplete *= -1}
            animator.fractionComplete = fractionComplete + progressWhenInterrupted
        }
    }
    
    //finish animation when user finished pan
    func continueInteractiveTransition(translation: CGPoint, velocity: CGPoint) {
        for animator in animators {
            
            //checking whether user moved detail view less than 50%
            let fractionComplete: CGFloat = abs(translation.y / (masterHeight - startingOffset))
            let gestureIsIncomplete = fractionComplete < 0.5
            
            //user panned finger in opposite direction
            let isOpposite = initialAnimationDirection.isOppositeVelocity(velocity: velocity)
            
            var timingParameters: UITimingCurveProvider!
            func switchAnimator() {
                animator.isReversed = !animator.isReversed
                animator.fractionComplete = 1.0 - animator.fractionComplete
                if animator.timingParameters === animationParameters.expandingTimeParameters {
                    timingParameters = animationParameters.collapsingTimeParameters
                } else {
                    timingParameters = animationParameters.expandingTimeParameters
                }
            }
            
            //reversing animator is user panned finger in opposite direction or if detail view
            //moved less than 50%
            if (isOpposite || gestureIsIncomplete) && !animator.isReversed {
                switchAnimator()
            } else if !isOpposite && !gestureIsIncomplete && animator.isReversed {
                switchAnimator()
            }
            //deciding which timing parameters to use
            animator.continueAnimation(withTimingParameters: timingParameters, durationFactor: 0)
        }
    }
    
    //MARK: - Gesture recognizers handlers
    
    func handleTap() {
        animateOrReverseRunningTransition(state: state, duration: animationParameters.duration)
    }
    
    func handlePan(gestureState: UIGestureRecognizer.State, translation: CGPoint, velocity: CGPoint) {
        switch gestureState {
        case .began:
            startInteractiveTransition(state: state, duration: animationParameters.duration)
        case .changed:
            updateInteractiveTransition(translation: translation, velocity: velocity)
        case .ended:
            continueInteractiveTransition(translation: translation, velocity: velocity)
        default:
            break
        }
    }
}
