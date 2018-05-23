//: A UIKit based Playground for presenting user interface
  
import RxSwift
import UIKit
import PlaygroundSupport

enum Nationality: String {
    case german
    case italian
    case chinese
    case nigerian
    case british
}

struct Person {
    let firstName: String
    let lastName: String
    let age: Int
    let nationality: Nationality
}


class ContactViewController : UITableViewController {

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .value2, reuseIdentifier: nil)
        cell.textLabel?.text = "firstName: \(indexPath.row)"
        cell.detailTextLabel?.text = "lastName: \(indexPath.row)"
        return cell
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Section \(section)"
    }

}

// Present the view controller in the Live View window
PlaygroundPage.current.liveView = ContactViewController(style: .plain)
