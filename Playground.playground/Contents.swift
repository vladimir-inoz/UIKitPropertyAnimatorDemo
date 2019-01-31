 import UIKit
 import PlaygroundSupport
 
 class SampleTableDataSource: NSObject, UITableViewDataSource {
    let stringData = [
        "Vestibulum dignissim, orci at bibendum",
        "Cras mollis risus finibus diam.",
        "sed porta neque congue id",
        "consectetur adipiscing elit",
        "Mauris scelerisque metus eget libero",
        "Maecenas dolor orci, euismod id",
        "vestibulum tincidunt, sagittis ac",
        "Aliquam sit amet lacus eget",
        "Maecenas dolor orci"
    ]
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return stringData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PlainCell", for: indexPath)
        cell.textLabel?.text = stringData[indexPath.row]
        return cell
    }
 }
 
 class AnimationCoordinator {
    weak var masterViewController: MasterViewController?
    weak var detailViewController: DetailViewController?
    //track all running animators
    private var runningAnimators = [UIViewPropertyAnimator]()
    private var progressWhenInterrupted = [UIViewPropertyAnimator : CGFloat]()
    
    enum State {
        case collapsed, expanded
        var inversed: State {
            switch self {
            case .collapsed:
                return .expanded
            case .expanded:
                return .collapsed
            }
        }
    }
    private var state: State = .collapsed
    
    init(withMasterVC master: MasterViewController, andDetailVC detail: DetailViewController) {
        masterViewController = master
        detailViewController = detail
    }
    
    //Perform all animations with animators if not already running
    func animateTransitionIfNeeded(state: State, duration: TimeInterval) {
        guard let master = masterViewController, let detail = detailViewController else {return}
        if runningAnimators.isEmpty {
            let frameAnimator = UIViewPropertyAnimator(duration: duration, dampingRatio: 1) {
                switch state {
                case .expanded:
                    detail.view.frame = master.view.frame.offsetBy(dx: 0.0, dy: master.view.frame.height - 50)
                case .collapsed:
                    detail.view.frame = master.view.frame
                }
            }
            frameAnimator.addCompletion {
                position in
                if position == UIViewAnimatingPosition.end {
                    self.state = self.state.inversed
                    self.runningAnimators = self.runningAnimators.filter{$0 !== frameAnimator}
                }
            }
            frameAnimator.startAnimation()
            runningAnimators.append(frameAnimator)
        }
    }
    
    //Starts transition if necessary or recerses it on tap
    func animateOrReverseRunningTransition(state: State, duration: TimeInterval) {
        if runningAnimators.isEmpty {
            animateTransitionIfNeeded(state: state, duration: duration)
        } else {
            for animator in runningAnimators {
                animator.isReversed = !animator.isReversed
            }
        }
    }
    
    func startInteractiveTransition(state: State, duration: TimeInterval) {
        if runningAnimators.isEmpty {
            animateTransitionIfNeeded(state: state, duration: duration)
        }
        
        for animator in runningAnimators {
            animator.pauseAnimation()
            progressWhenInterrupted[animator] = animator.fractionComplete
        }
    }
    
    func updateInteractiveTransition(fractionComplete: CGFloat) {
        print("fraction is \(fractionComplete)")
        for animator in runningAnimators {
            animator.fractionComplete = fractionComplete
        }
    }
    
    func continueInteractiveTransition(cancel: Bool) {
        for animator in runningAnimators {
            let timing = UICubicTimingParameters(animationCurve: .easeIn)
            animator.continueAnimation(withTimingParameters: timing, durationFactor: 0)
        }
    }
    
    func handleTap(recognizer: UITapGestureRecognizer) {
        animateOrReverseRunningTransition(state: state, duration: 5.0)
    }
    
    func handlePan(gestureState: UIGestureRecognizer.State, translation: CGPoint) {
        guard let master = masterViewController else {
            return
        }
        
        switch gestureState {
        case .began:
            startInteractiveTransition(state: state, duration: 0.5)
        case .changed:
            switch state {
            case .collapsed:
                let fractionComplete = (-translation.y + 50.0) / master.view.frame.height
                updateInteractiveTransition(fractionComplete: fractionComplete)
            case .expanded:
                let fractionComplete = (translation.y + 50.0) / master.view.frame.height
                updateInteractiveTransition(fractionComplete: fractionComplete)
            }
        case .ended:
            continueInteractiveTransition(cancel: false)
        default:
            break
        }
    }
 }
 
 class DetailViewController: UIViewController {
    private lazy var dataSource = {
       return SampleTableDataSource()
    }()
    private lazy var topView: UIView = {
        let containerView = UIView(frame: CGRect.zero)
        containerView.backgroundColor = UIColor.red
        
        let label = UILabel(frame: CGRect.zero)
        label.text = "Detail view controller"
        containerView.addSubview(label)
        
        label.translatesAutoresizingMaskIntoConstraints = false
        label.centerXAnchor.constraint(equalTo: containerView.centerXAnchor).isActive = true
        label.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        
        //adding two gesture recognizers
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        containerView.addGestureRecognizer(tapGestureRecognizer)
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handlePan))
        containerView.addGestureRecognizer(panGestureRecognizer)
        return containerView
    }()
    private lazy var tableView: UITableView = {
        let table = UITableView(frame: CGRect.zero, style: .plain)
        table.dataSource = dataSource
        table.register(UITableViewCell.self, forCellReuseIdentifier: "PlainCell")
        return table
    }()
    public var coordinator: AnimationCoordinator?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.white
        view.addSubview(topView)
        view.addSubview(tableView)
    
        setupConstraints()
    }
    
    func setupConstraints() {
        topView.translatesAutoresizingMaskIntoConstraints = false
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        topView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        topView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor).isActive = true
        topView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor).isActive = true
        topView.heightAnchor.constraint(equalToConstant: 50.0).isActive = true
        
        tableView.topAnchor.constraint(equalTo: topView.bottomAnchor).isActive = true
        tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor).isActive = true
        tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
    }
    
    @objc func handleTap(recognizer: UITapGestureRecognizer) {
        if let coordinator = self.coordinator {
            coordinator.handleTap(recognizer: recognizer)
        }
    }
    
    @objc func handlePan(recognizer: UIPanGestureRecognizer) {
        if let coordinator = self.coordinator {
            coordinator.handlePan(gestureState: recognizer.state, translation: recognizer.translation(in: view))
        }
    }
 }
 
 class MasterViewController: UIViewController {
    lazy var label: UILabel = {
        let label = UILabel(frame: CGRect.zero)
        label.text = "Master view controller"
        return label
    }()
    
    lazy var imageView: UIImageView = {
        let view = UIImageView(image: nil)
        return view
    }()
    public var coordinator: AnimationCoordinator?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.white
        
        view.addSubview(label)
        view.addSubview(imageView)
        
        setupConstraints()
    }
    
    func setupConstraints() {
        label.translatesAutoresizingMaskIntoConstraints = false
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        label.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        label.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        imageView.topAnchor.constraint(equalTo: label.bottomAnchor).isActive = true
        imageView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        imageView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
    }
 }
 
 let master = MasterViewController()
 
 PlaygroundPage.current.liveView = master
 PlaygroundPage.current.needsIndefiniteExecution = true
 
 let detail = DetailViewController()
 master.addChild(detail)
 //master.view.addSubview(detail.view)
 detail.view.frame = master.view.frame.offsetBy(dx: 0.0, dy: master.view.frame.height - 50)
 let coordinator = AnimationCoordinator(withMasterVC: master, andDetailVC: detail)
 master.coordinator = coordinator
 detail.coordinator = coordinator
