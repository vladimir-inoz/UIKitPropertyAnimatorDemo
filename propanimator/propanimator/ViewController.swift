import UIKit

///Controller which glues master and detail view controllers
///And contains all animation coordinators
class ViewController: UIViewController, DetailViewControllerDelegate {
    
    var coordinators = [AnimationCoordinator]()
    lazy var master = MasterViewController()
    lazy var detail = DetailViewController()
    let detailViewOffset:CGFloat = 100
    
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
        
        detail.view.frame = master.view.bounds.offsetBy(dx: 0.0, dy: master.view.frame.height - detailViewOffset)
        
        setupCoordinators()
    }
    
    func setupCoordinators() {
        let collapsing = {
            [unowned self, unowned detail = self.detail, unowned master = self.master] in
            detail.view.frame = master.view.frame.offsetBy(dx: 0.0, dy: master.view.frame.height - self.detailViewOffset)
        }
        let expanding = {
            [unowned detail = self.detail, unowned master = self.master] in
            detail.view.frame = master.view.frame
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
        
        let positionCoordinator = AnimationCoordinator(withMasterViewHeight: master.view.bounds.height, andDetailViewOffset: detailViewOffset, expandingAnimation: expanding, collapsingAnimation: collapsing)
        coordinators.append(positionCoordinator)
        let blurCoordinator = AnimationCoordinator(withMasterViewHeight: master.view.bounds.height, andDetailViewOffset: detailViewOffset, expandingAnimation: blur, collapsingAnimation: noBlur)
        coordinators.append(blurCoordinator)
    }
    
    //MARK: - Detail view controller delegate
    func handleTap() {
        for coordinator in coordinators {
            coordinator.handleTap()
        }
    }
    
    func handlePan(gestureState: UIGestureRecognizer.State, translation: CGPoint, velocity: CGPoint) {
        for coordinator in coordinators {
            coordinator.handlePan(gestureState: gestureState, translation: translation, velocity: velocity)
        }
    }
    
}

