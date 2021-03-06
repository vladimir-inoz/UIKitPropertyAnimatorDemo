import UIKit

///Controller which glues master and detail view controllers
///And contains all animation coordinators
class ViewController: UIViewController, DetailViewControllerDelegate {
    
    var coordinator: AnimationCoordinator!
    lazy var master = MasterViewController()
    lazy var detail = DetailViewController()
    let detailViewOffset: CGFloat = 50.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        detail.delegate = self
        
        addChild(master)
        master.addChild(detail)
        
        view.addSubview(master.view)
        master.view.translatesAutoresizingMaskIntoConstraints = false
        master.view.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        master.view.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        master.view.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor).isActive = true
        master.view.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor).isActive = true
        
        master.view.addSubview(detail.view)
        
        setupCoordinators()
    }
    
    override func viewDidLayoutSubviews() {
        //setting up initial frame of detailViewController here because bounds of masterViewController are valid only here
        detail.view.frame = master.view.bounds.offsetBy(dx: 0.0, dy: master.view.bounds.height - detailViewOffset)
    }
    
    func setupCoordinators() {
        let springTimingParameters = UISpringTimingParameters(dampingRatio: 2.0)
        let customCollapsingTimingParameters = UICubicTimingParameters(controlPoint1: CGPoint(x: 0.1, y: 0.75),
                                                                      controlPoint2: CGPoint(x: 0.25, y: 0.9))
        let customExpandingTimingParameters = UICubicTimingParameters(controlPoint1: CGPoint(x: 0.75, y: 0.1),
                                                                      controlPoint2: CGPoint(x: 0.9, y: 0.25))
        let easeInTimingParameters = UICubicTimingParameters(animationCurve: .easeIn)
        let easeOutTimingParameters = UICubicTimingParameters(animationCurve: .easeOut)
        
        let collapsing = {
            [unowned self, unowned detail = self.detail, unowned master = self.master] in
            detail.view.frame = master.view.bounds.offsetBy(dx: 0.0, dy: master.view.bounds.height - self.detailViewOffset)
        }
        let expanding = {
            [unowned detail = self.detail, unowned master = self.master] in
            detail.view.frame = master.view.bounds
        }
        let blur = {
            [unowned master = self.master] in
            let blurEffect = UIBlurEffect(style: .prominent)
            master.effectView.effect = blurEffect
        }
        let noBlur = {
            [unowned master = self.master] in
            master.effectView.effect = nil
        }
        
        let panParameters = AnimationParameters(expandingAnimation: expanding, collapsingAnimation: collapsing, scrubsLinearly: true, expandingTimeParameters: springTimingParameters, collapsingTimeParameters: springTimingParameters)
        let blurParameters = AnimationParameters(expandingAnimation: blur, collapsingAnimation: noBlur, scrubsLinearly: false, expandingTimeParameters: customExpandingTimingParameters, collapsingTimeParameters: customCollapsingTimingParameters)
        let detailHeadParameters = AnimationParameters(expandingAnimation: detail.expandTopView, collapsingAnimation: detail.collapseTopView, scrubsLinearly: false, expandingTimeParameters: easeOutTimingParameters, collapsingTimeParameters: easeInTimingParameters)
        
        coordinator = AnimationCoordinator(withMasterViewHeight: master.view.bounds.height, andDetailViewOffset: detailViewOffset, duration: 1.0, animationParameters: [panParameters, blurParameters, detailHeadParameters])
    }
    
    //MARK: - Detail view controller delegate
    func handleTap() {
        coordinator.handleTap()
    }
    
    func handlePan(gestureState: UIGestureRecognizer.State, translation: CGPoint, velocity: CGPoint) {
        coordinator.handlePan(gestureState: gestureState, translation: translation, velocity: velocity)
    }
    
}

