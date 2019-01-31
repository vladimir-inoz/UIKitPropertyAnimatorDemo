import UIKit

class MasterViewController: UIViewController {
    lazy var effectView: UIVisualEffectView = {
        let view = UIVisualEffectView(effect: nil)
        return view
    }()
    lazy var label: UILabel = {
        let label = UILabel(frame: CGRect.zero)
        label.text = "Master view controller"
        return label
    }()
    
    lazy var imageView: UIImageView = {
        let image = UIImage(named: "MasterImage")
        let view = UIImageView(image: image)
        view.contentMode = .scaleAspectFill
        return view
    }()
    public var coordinator: AnimationCoordinator?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.white
        view.addSubview(label)
        view.addSubview(imageView)
        view.addSubview(effectView)
        effectView.frame = view.bounds
        
        setupConstraints()
    }
    
    func setupConstraints() {
        effectView.translatesAutoresizingMaskIntoConstraints = false
        label.translatesAutoresizingMaskIntoConstraints = false
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        label.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        label.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        imageView.topAnchor.constraint(equalTo: label.bottomAnchor).isActive = true
        imageView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        imageView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
    }
}
