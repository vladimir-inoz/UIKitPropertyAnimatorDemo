import UIKit

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


class ViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let master = MasterViewController()
        let detail = DetailViewController()
        
        addChild(master)
        master.addChild(detail)
        
        view.addSubview(master.view)
        master.view.translatesAutoresizingMaskIntoConstraints = false
        master.view.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        master.view.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        master.view.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor).isActive = true
        master.view.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor).isActive = true
        
        master.view.addSubview(detail.view)
        detail.view.frame = master.view.bounds.offsetBy(dx: 0.0, dy: master.view.frame.height - 100)
        
        let collapsing = {
            detail.view.frame = master.view.frame.offsetBy(dx: 0.0, dy: master.view.frame.height - 100)
            master.effectView.effect = nil
        }
        let expanding = {
            detail.view.frame = master.view.frame
            let blurEffect = UIBlurEffect(style: .prominent)
            master.effectView.effect = blurEffect
        }
        
        let coordinator = AnimationCoordinator(withMasterVC: master, andDetailVC: detail, withInitialOffset: 100, expandingAnimation: expanding, collapsingAnimation: collapsing)
        master.coordinator = coordinator
        detail.coordinator = coordinator
    }
    
    
}

