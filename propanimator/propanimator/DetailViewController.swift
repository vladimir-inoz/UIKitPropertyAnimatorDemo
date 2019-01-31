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
        containerView.backgroundColor = UIColor(red: 0.627, green: 0.514, blue: 0.514, alpha: 1.0)
        
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
    public weak var delegate: DetailViewControllerDelegate?
    
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
        delegate?.handleTap()
    }
    
    @objc func handlePan(recognizer: UIPanGestureRecognizer) {
        delegate?.handlePan(gestureState: recognizer.state, translation: recognizer.translation(in: view), velocity: recognizer.velocity(in: view))
    }
}
