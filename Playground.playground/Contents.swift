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
 
 class AnimationCoordinator: NSObject {
 }
 
 class DetailViewController: UIViewController {
    lazy var dataSource = {
       return SampleTableDataSource()
    }()
    lazy var topView: UIView = {
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
    lazy var tableView: UITableView = {
        let table = UITableView(frame: CGRect.zero, style: .plain)
        table.dataSource = dataSource
        table.register(UITableViewCell.self, forCellReuseIdentifier: "PlainCell")
        return table
    }()
    //gesture handlers
    var handleTapFunc: (UITapGestureRecognizer) -> Void = {
        recognizer in
    }
    var handlePanFunc: (UIPanGestureRecognizer) -> Void = {
        recognizer in
    }
    
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
        handleTapFunc(recognizer)
    }
    
    @objc func handlePan(recognizer: UIPanGestureRecognizer) {
        handlePanFunc(recognizer)
    }
 }
 
 class MasterViewController: UIViewController {
    lazy var detailViewController: DetailViewController = {
        let vc = DetailViewController(nibName: nil, bundle: nil)
        vc.view.frame = view.frame.offsetBy(dx: 0.0, dy: view.frame.height/2)
        return vc
    }()
    
    lazy var label: UILabel = {
        let label = UILabel(frame: CGRect.zero)
        label.text = "Master view controller"
        return label
    }()
    
    lazy var imageView: UIImageView = {
        let view = UIImageView(image: nil)
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.white
        
        view.addSubview(label)
        view.addSubview(imageView)
        view.addSubview(detailViewController.view)
        
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
 
 let vc = MasterViewController()
 
 PlaygroundPage.current.liveView = vc
 PlaygroundPage.current.needsIndefiniteExecution = true
