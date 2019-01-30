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
 
 class DetailViewController: UIViewController {
    lazy var dataSource = {
       return SampleTableDataSource()
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let label = UILabel(frame: CGRect.zero)
        label.text = "Sam's photo"
        let tableView = UITableView(frame: CGRect.zero, style: .plain)
        tableView.dataSource = dataSource
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "PlainCell")
        
        view.backgroundColor = UIColor.white
        
        view.addSubview(label)
        view.addSubview(tableView)
        
        label.translatesAutoresizingMaskIntoConstraints = false
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        label.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        label.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        tableView.topAnchor.constraint(equalTo: label.bottomAnchor).isActive = true
        tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor).isActive = true
        tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        
        tableView.reloadData()
    }
 }
 
 class MasterViewController: UIViewController {
    lazy var detailViewController: DetailViewController = {
        let vc = DetailViewController(nibName: nil, bundle: nil)
        vc.view.frame = view.frame.offsetBy(dx: 0.0, dy: view.frame.height - 50.0)
        return vc
    }()
    
    lazy var label: UILabel = {
        let label = UILabel(frame: CGRect.zero)
        label.text = "Sam's photo"
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
    
    @objc func buttonTapped() {
        UIView.animate(withDuration: 0.5) {
            [weak detailView = self.detailViewController.view, weak view = self.view] in
            if let frame = view?.frame {
                detailView?.frame = frame
            }
        }
    }
 }
 
 let vc = MasterViewController()
 
 PlaygroundPage.current.liveView = vc
 PlaygroundPage.current.needsIndefiniteExecution = true
