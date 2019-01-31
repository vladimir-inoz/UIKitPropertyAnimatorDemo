import UIKit

final class AnimationCoordinator {
    weak var masterViewController: MasterViewController?
    weak var detailViewController: DetailViewController?
    //track all running animators
    private var animator: UIViewPropertyAnimator?
    //progress of animation when user 'captured' it with pan gesture
    private var progressWhenInterrupted: CGFloat = 0.0
    //starting and enging offsets
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
    //stored animations
    let expandingAnimation: () -> Void
    let collapsingAnimation: () -> Void
    
    init(withMasterVC master: MasterViewController, andDetailVC detail: DetailViewController, withInitialOffset offset: CGFloat, expandingAnimation: @escaping () -> Void, collapsingAnimation: @escaping () -> Void) {
        masterViewController = master
        detailViewController = detail
        startingOffset = offset
        self.expandingAnimation = expandingAnimation
        self.collapsingAnimation = collapsingAnimation
    }
    
    //Perform all animations with animators if not already running
    func animateTransitionIfNeeded(state: DetailControllerState, duration: TimeInterval) {
        if animator == nil {
            var animatorFunction: () -> Void
            switch state {
            case .expanded:
                animatorFunction = collapsingAnimation
            case .collapsed:
                animatorFunction = expandingAnimation
            }
            animator = UIViewPropertyAnimator(duration: duration, dampingRatio: 1, animations: animatorFunction)
            animator!.addCompletion {
                [unowned self] (position) -> Void in
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
                self.animator = nil
            }
            animator!.startAnimation()
        }
    }
    
    //Starts transition if necessary or recerses it on tap
    func animateOrReverseRunningTransition(state: DetailControllerState, duration: TimeInterval) {
        if let animator = self.animator {
            animator.isReversed = !animator.isReversed
        } else {
            animateTransitionIfNeeded(state: state, duration: duration)
        }
    }
    
    func startInteractiveTransition(state: DetailControllerState, duration: TimeInterval) {
        if let animator = self.animator {
            progressWhenInterrupted = animator.fractionComplete
        } else {
            animateTransitionIfNeeded(state: state, duration: duration)
        }
        animator!.pauseAnimation()
    }
    
    //update animation when user pans
    //initialDetailOffset - how much points of detail view controller is visible from start
    func updateInteractiveTransition(translation: CGPoint, velocity: CGPoint) {
        guard let animator = self.animator,
            let masterHeight = masterViewController?.view.bounds.height
            else { return }
        
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
    
    //finish animation when user finished pan
    func continueInteractiveTransition(translation: CGPoint, velocity: CGPoint) {
        guard let animator = self.animator,
        let masterHeight = masterViewController?.view.bounds.height
            else {return}
        
        //checking whether user moved detail view less than 50%
        let fractionComplete: CGFloat = abs(translation.y / (masterHeight - startingOffset))
        let gestureIsIncomplete = fractionComplete < 0.5
        
        //user panned finger in opposite direction
        let isOpposite = initialAnimationDirection.isOppositeVelocity(velocity: velocity)
        
        //reversing animator is user panned finger in opposite direction or if detail view
        //moved less than 50%
        if (isOpposite || gestureIsIncomplete) && !animator.isReversed {
            animator.isReversed = !animator.isReversed
            animator.fractionComplete = 1.0 - animator.fractionComplete
        } else if !isOpposite && !gestureIsIncomplete && animator.isReversed {
            animator.isReversed = !animator.isReversed
            animator.fractionComplete = 1.0 - animator.fractionComplete
        }
        let timing = UICubicTimingParameters(animationCurve: .easeIn)
        animator.continueAnimation(withTimingParameters: timing, durationFactor: 0)
    }
    
    //MARK: - Gesture recognizers handler
    
    func handleTap(recognizer: UITapGestureRecognizer) {
        animateOrReverseRunningTransition(state: state, duration: 1.0)
    }
    
    func handlePan(gestureState: UIGestureRecognizer.State, translation: CGPoint, velocity: CGPoint) {
        switch gestureState {
        case .began:
            startInteractiveTransition(state: state, duration: 1.0)
        case .changed:
            updateInteractiveTransition(translation: translation, velocity: velocity)
        case .ended:
            continueInteractiveTransition(translation: translation, velocity: velocity)
        default:
            break
        }
    }
}
