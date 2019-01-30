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
        cell.detailTextLabel?.text = "Testtest"
        return cell
    }
 }
 
 class DetailViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let label = UILabel(frame: CGRect.zero)
        label.text = "Sam's photo"
        let tableView = UITableView(frame: CGRect.zero, style: .plain)
        let dataSource = SampleTableDataSource()
        tableView.dataSource = dataSource
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "PlainCell")
        let button = UIButton(type: .system)
        button.setTitle("Expose", for: .normal)
        
        view.backgroundColor = UIColor.white
        
        view.addSubview(label)
        view.addSubview(tableView)
        view.addSubview(button)
        
        label.translatesAutoresizingMaskIntoConstraints = false
        tableView.translatesAutoresizingMaskIntoConstraints = false
        button.translatesAutoresizingMaskIntoConstraints = false
        
        label.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        label.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        button.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        button.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        tableView.topAnchor.constraint(equalTo: label.bottomAnchor).isActive = true
        tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: button.topAnchor).isActive = true
        
        tableView.reloadData()
    }
 }
 
 class MasterViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let label = UILabel(frame: CGRect.zero)
        label.text = "Sam's photo"
        let imageView = UIImageView(image: nil)
        let button = UIButton(type: .system)
        button.setTitle("Expose", for: .normal)
        
        view.backgroundColor = UIColor.white
        
        view.addSubview(label)
        view.addSubview(imageView)
        view.addSubview(button)
        
        label.translatesAutoresizingMaskIntoConstraints = false
        imageView.translatesAutoresizingMaskIntoConstraints = false
        button.translatesAutoresizingMaskIntoConstraints = false
        
        label.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        label.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        button.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        button.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        imageView.topAnchor.constraint(equalTo: label.bottomAnchor).isActive = true
        imageView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        imageView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        imageView.bottomAnchor.constraint(equalTo: button.topAnchor).isActive = true
    }
    
    @objc func buttonTapped() {
        
    }
    /*var animators: UIViewPropertyAnimator!
     var circle: UIView!
     var progressWhenInterrupted: CGFloat = 0
     
     func animateTransitionIfNeeded(duration: TimeInterval) {
     if animator == nil {
     animator = UIViewPropertyAnimator(duration: duration, curve: .easeOut) {
     self.circle.frame = self.circle.frame.offsetBy(dx: self.view.frame.width, dy: 0)
     }
     animator.pausesOnCompletion = true
     }
     }
     
     override func viewDidLoad() {
     circle = UIView(frame: CGRect(x: 20.0, y: 20.0, width: 40.0, height: 40.0))
     circle.backgroundColor = UIColor.red
     view.addSubview(circle)
     
     let panRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handlePan))
     circle.addGestureRecognizer(panRecognizer)
     }
     
     @objc func handlePan(recognizer: UIPanGestureRecognizer) {
     switch recognizer.state {
     case .began:
     print("began")
     animateTransitionIfNeeded(duration: 15.0)
     animator.pauseAnimation()
     progressWhenInterrupted = animator.fractionComplete
     case .changed:
     print("changed")
     let translation = recognizer.translation(in: circle)
     animator.fractionComplete = (translation.x / view.frame.width) + progressWhenInterrupted
     case .ended:
     print("ended")
     let timing = UICubicTimingParameters(animationCurve: .easeOut)
     animator.continueAnimation(withTimingParameters: timing, durationFactor: 0)
     default:
     break
     }
     }*/
 }
 
 let vc = DetailViewController()
 
 PlaygroundPage.current.liveView = vc
 PlaygroundPage.current.needsIndefiniteExecution = true
