import UIKit

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
