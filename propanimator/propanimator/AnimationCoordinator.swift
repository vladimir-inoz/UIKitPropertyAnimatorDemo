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
    private var currentAnimationDirection: AnimationDirection = .undefined
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
    
    init(withMasterVC master: MasterViewController, andDetailVC detail: DetailViewController, withInitialOffset offset: CGFloat) {
        masterViewController = master
        detailViewController = detail
        startingOffset = offset
    }
    
    //Perform all animations with animators if not already running
    func animateTransitionIfNeeded(state: DetailControllerState, duration: TimeInterval) {
        guard let master = masterViewController, let detail = detailViewController else {return}
        if animator == nil {
            var animatorFunction: () -> Void
            switch state {
            case .expanded:
                animatorFunction = {
                    [unowned self] in
                    detail.view.frame = master.view.frame.offsetBy(dx: 0.0, dy: master.view.frame.height - self.startingOffset)
                }
            case .collapsed:
                animatorFunction = {
                    detail.view.frame = master.view.frame
                }
            }
            animator = UIViewPropertyAnimator(duration: duration, dampingRatio: 1, animations: animatorFunction)
            animator!.addCompletion {
                [unowned self, currentAnimationDirection = self.currentAnimationDirection] (position) -> Void in
                if position == UIViewAnimatingPosition.end {
                    //checking current animation velocity
                    //this is case when there were no pan gesture, just tap gesture
                    if currentAnimationDirection == .undefined {
                        self.state = self.state.inversed
                    }
                    //if we were at collapsed state, then panned up, then panned down
                    //the state should be the same
                    //otherwise if we were at .collapsed state, then just panned up
                    //the state should become .expanded
                    if self.state == .collapsed && currentAnimationDirection == .up {
                        self.state = .expanded
                    }
                    if self.state == .expanded && currentAnimationDirection == .down {
                        self.state = .collapsed
                    }
                    //nulling directions
                    self.initialAnimationDirection = .undefined
                    self.currentAnimationDirection = .undefined
                    //nulling animator
                    self.animator = nil
                }
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
        currentAnimationDirection = AnimationDirection(fromVelocity: velocity)
        
        var fractionComplete: CGFloat = 0.0
        
        switch initialAnimationDirection {
        case .up:
            fractionComplete = -translation.y / (masterHeight - startingOffset)
        case .down:
            fractionComplete = translation.y / (masterHeight - startingOffset)
        case .undefined:
            break
        }
        
        print("\(translation.y), \(masterHeight - startingOffset)")
        
        //substracting the fraction if the animator is reversed
        if animator.isReversed {fractionComplete *= -1}
        animator.fractionComplete = fractionComplete + progressWhenInterrupted
    }
    
    //finish animation when user finished pan
    func continueInteractiveTransition(velocity: CGPoint) {
        guard let animator = self.animator else {return}
        if abs(velocity.y) < 1E-3 {
            let timing = UICubicTimingParameters(animationCurve: .easeIn)
            animator.continueAnimation(withTimingParameters: timing, durationFactor: 0)
            return
        }
        
        let isOpposite = initialAnimationDirection.isOppositeVelocity(velocity: velocity)
        if isOpposite && !animator.isReversed {
            animator.isReversed = !animator.isReversed
        } else if !isOpposite && animator.isReversed {
            animator.isReversed = !animator.isReversed
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
            continueInteractiveTransition(velocity: velocity)
        default:
            break
        }
    }
}
