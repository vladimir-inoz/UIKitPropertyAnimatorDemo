import UIKit


class SampleTableDataSource: NSObject, UITableViewDataSource {
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
        var arrayStrings = [String]()
        for i in 0..<100 {
            arrayStrings.append(data.randomElement()!)
        }
        return arrayStrings
    }()
    
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
