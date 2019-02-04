import UIKit

protocol DetailViewControllerDelegate: AnyObject {
    func handleTap()
    func handlePan(gestureState: UIGestureRecognizer.State, translation: CGPoint, velocity: CGPoint)
}

class DetailViewController: UIViewController {
    private lazy var dataSource = {
        return SampleTableDataSource()
    }()
    private lazy var topView: UIView = {
        let containerView = UIView(frame: CGRect.zero)
        containerView.backgroundColor = UIColor.white
        
        let labelSmall = UILabel(frame: CGRect.zero)
        labelSmall.text = "Comments"
        labelSmall.textColor = UIColor.blue
        labelSmall.sizeToFit()
        containerView.addSubview(labelSmall)
        
        labelSmall.translatesAutoresizingMaskIntoConstraints = false
        labelSmall.centerXAnchor.constraint(equalTo: containerView.centerXAnchor).isActive = true
        labelSmall.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        
        let labelBig = UILabel(frame: CGRect.zero)
        labelBig.text = "Comments"
        labelBig.font = UIFont.systemFont(ofSize: 30.0)
        labelBig.sizeToFit()
        containerView.addSubview(labelBig)
        labelBig.alpha = 0.0
        let ratio: CGFloat = (labelBig.bounds.height / labelSmall.bounds.height) * 0.971
        labelBig.transform = CGAffineTransform(scaleX: 1/ratio, y: 1/ratio)
        
        labelBig.translatesAutoresizingMaskIntoConstraints = false
        labelBig.centerXAnchor.constraint(equalTo: containerView.centerXAnchor).isActive = true
        labelBig.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        
        //adding two gesture recognizers
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        containerView.addGestureRecognizer(tapGestureRecognizer)
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handlePan))
        containerView.addGestureRecognizer(panGestureRecognizer)
        
        
        
        //setting animating closures
        expandTopView = {
            labelBig.transform = .identity
            labelSmall.transform = CGAffineTransform(scaleX: ratio, y: ratio).concatenating(CGAffineTransform(translationX: 0, y: 0))
            
            labelBig.alpha = 1.0
            labelSmall.alpha = 0.0
        }
        collapseTopView = {
            labelBig.transform = CGAffineTransform(scaleX: 1/ratio, y: 1/ratio).concatenating(CGAffineTransform(translationX: 0, y: -0))
            labelSmall.transform = .identity
            
            labelBig.alpha = 0.0
            labelSmall.alpha = 1.0
        }
        return containerView
    }()
    private lazy var tableView: UITableView = {
        let table = UITableView(frame: CGRect.zero, style: .plain)
        table.dataSource = dataSource
        table.register(UITableViewCell.self, forCellReuseIdentifier: "PlainCell")
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
}
