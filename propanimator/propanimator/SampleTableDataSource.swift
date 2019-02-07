import UIKit

fileprivate func getImageWithColor(color: UIColor, size: CGSize) -> UIImage {
    let rect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
    UIGraphicsBeginImageContextWithOptions(size, false, 0)
    color.setFill()
    UIRectFill(rect)
    let image: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
    UIGraphicsEndImageContext()
    return image
}

class SampleTableDataSource: NSObject, UITableViewDataSource {
    let authorsData: [String] = {
        let authors = ["John", "Doug", "Mel", "Mike"]
        return (0..<100).map{_ in return authors.randomElement()!}
    }()
    let stringData: [String] = {
        let data = [
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
        return (0..<100).map{_ in return data.randomElement()!}
    }()
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return stringData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PlainCell", for: indexPath)
        if cell.imageView?.image == nil {
            cell.imageView?.image = getImageWithColor(color: UIColor(red: 0.6, green: 0.6, blue: 0.6, alpha: 1.0), size: CGSize(width: 40.0, height: 40.0))
        }
        cell.textLabel?.numberOfLines = 0
        let attributedText = NSMutableAttributedString(string: "\(authorsData[indexPath.row])\n", attributes: [NSAttributedString.Key.font:UIFont.boldSystemFont(ofSize: 17.0)])
        attributedText.append(NSAttributedString(string: stringData[indexPath.row]))
        cell.textLabel?.attributedText = attributedText
        return cell
    }
}
