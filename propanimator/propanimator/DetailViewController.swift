import UIKit

protocol DetailViewControllerDelegate: AnyObject {
    func handleTap()
    func handlePan(gestureState: UIGestureRecognizer.State, translation: CGPoint, velocity: CGPoint)
}

class DetailViewController: UIViewController, UIScrollViewDelegate {
    private lazy var dataSource = {
        return SampleTableDataSource()
    }()
    private lazy var labelSmall: UILabel = {
        let labelSmall = UILabel(frame: CGRect.zero)
        labelSmall.text = "Comments"
        labelSmall.textColor = UIColor.blue
        labelSmall.sizeToFit()
        return labelSmall
    }()
    private lazy var labelBig: UILabel = {
        let labelBig = UILabel(frame: CGRect.zero)
        labelBig.text = "Comments"
        labelBig.font = UIFont.systemFont(ofSize: 30.0)
        labelBig.sizeToFit()
        labelBig.alpha = 0.0
        return labelBig
    }()
    private lazy var spinRect: UIView = {
        let view = UIView(frame: CGRect.zero)
        view.layer.borderColor = UIColor.red.cgColor
        view.layer.borderWidth = 1.0
        return view
    }()
    private lazy var topView: UIView = {
        let containerView = UIView(frame: CGRect.zero)
        containerView.backgroundColor = UIColor.white

        containerView.addSubview(labelSmall)
        containerView.addSubview(labelBig)
        containerView.addSubview(spinRect)
        
        //adding two gesture recognizers
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        containerView.addGestureRecognizer(tapGestureRecognizer)
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handlePan))
        view.addGestureRecognizer(panGestureRecognizer)
        
        //setting animating closures
        let ratio: CGFloat = (labelBig.bounds.height / labelSmall.bounds.height) * 0.971
        labelBig.transform = CGAffineTransform(scaleX: 1/ratio, y: 1/ratio)
        expandTopView = {
            [unowned labelBig = self.labelBig, unowned labelSmall = self.labelSmall, unowned spinRect = self.spinRect] in
            labelBig.transform = .identity
            labelSmall.transform = CGAffineTransform(scaleX: ratio, y: ratio).concatenating(CGAffineTransform(translationX: 0, y: 0))
            
            labelBig.alpha = 1.0
            labelSmall.alpha = 0.0
            
            UIView.animateKeyframes(withDuration: 1.0, delay: 0, options: .calculationModeCubic, animations: {
                for i in 0..<10 {
                    if i % 2 == 0 {
                        UIView.addKeyframe(withRelativeStartTime: Double(i)/10.0, relativeDuration: 0.1) {
                            spinRect.transform = spinRect.transform.translatedBy(x: 50.0, y: 0.0)
                        }
                    } else {
                        UIView.addKeyframe(withRelativeStartTime: Double(i)/10.0, relativeDuration: 0.1) {
                            spinRect.transform = spinRect.transform.translatedBy(x: -50.0, y: 0.0)
                        }
                    }
                }
            }, completion: nil)
        }
        collapseTopView = {
            [unowned labelBig = self.labelBig, unowned labelSmall = self.labelSmall, unowned spinRect = self.spinRect] in
            labelBig.transform = CGAffineTransform(scaleX: 1/ratio, y: 1/ratio).concatenating(CGAffineTransform(translationX: 0, y: -0))
            labelSmall.transform = .identity
            
            labelBig.alpha = 0.0
            labelSmall.alpha = 1.0
        }
        return containerView
    }()
    private lazy var tableView: UITableView = {
        let table = UITableView(frame: CGRect.zero, style: .plain)
        table.estimatedRowHeight = 70.0
        table.dataSource = dataSource
        table.panGestureRecognizer.addTarget(self, action: #selector(handlePanFromTableView))
        (table as UIScrollView).delegate = self
        table.register(CommentCell.self, forCellReuseIdentifier: "PlainCell")
        return table
    }()
    public weak var delegate: DetailViewControllerDelegate?
    ///Animating closures
    public private(set) var expandTopView: (() -> Void)!
    public private(set) var collapseTopView: (() -> Void)!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.white
        view.addSubview(topView)
        view.addSubview(tableView)
        view.layer.cornerRadius = 13.0
        view.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
        topView.layer.cornerRadius = 13.0
        topView.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
        
        setupConstraints()
    }
    
    func setupConstraints() {
        labelSmall.translatesAutoresizingMaskIntoConstraints = false
        labelSmall.centerXAnchor.constraint(equalTo: topView.centerXAnchor).isActive = true
        labelSmall.centerYAnchor.constraint(equalTo: topView.centerYAnchor).isActive = true
        
        labelBig.translatesAutoresizingMaskIntoConstraints = false
        labelBig.centerXAnchor.constraint(equalTo: topView.centerXAnchor).isActive = true
        labelBig.centerYAnchor.constraint(equalTo: topView.centerYAnchor).isActive = true
        
        spinRect.translatesAutoresizingMaskIntoConstraints = false
        spinRect.heightAnchor.constraint(equalToConstant: 10.0).isActive = true
        spinRect.widthAnchor.constraint(equalToConstant: 10.0).isActive = true
        spinRect.centerYAnchor.constraint(equalTo: topView.centerYAnchor).isActive = true
        spinRect.leadingAnchor.constraint(equalTo: topView.leadingAnchor, constant: 20.0).isActive = true
        
        topView.translatesAutoresizingMaskIntoConstraints = false
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        topView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        topView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        topView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        topView.heightAnchor.constraint(equalToConstant: 50.0).isActive = true
        
        tableView.topAnchor.constraint(equalTo: topView.bottomAnchor).isActive = true
        tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
    }
    
    @objc func handleTap(recognizer: UITapGestureRecognizer) {
        delegate?.handleTap()
    }
    
    @objc func handlePan(recognizer: UIPanGestureRecognizer) {
        delegate?.handlePan(gestureState: recognizer.state, translation: recognizer.translation(in: view), velocity: recognizer.velocity(in: view))
    }
    
    //if tableView is scrolled to top, we send handle tableView's pan gesture recognizer in delegate
    @objc func handlePanFromTableView(recognizer: UIPanGestureRecognizer) {
        guard tableView.contentOffset.y <= 0.0 else {
            return
        }
        let isCollapsingGesture = (recognizer.velocity(in: tableView).y > 0)
        let frameTransition = (view.frame.origin.y > 5.0)
        //we enable superview animation if:
        //1. tableView is scrolled to top and user continues to swipe downwards
        //2. tableView is scrolled to top, user swipes upwards and view isn't expanded totally
        if (isCollapsingGesture) || (!isCollapsingGesture && frameTransition) {
            delegate?.handlePan(gestureState: recognizer.state, translation: recognizer.translation(in: view), velocity: recognizer.velocity(in: view))
        }
    }
    
   //MARK: - Scroll view delegate
    //Disable bounce on top of scroll
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        scrollView.bounces = (scrollView.contentOffset.y > 0)
    }
}
