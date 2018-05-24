//: A UIKit based Playground for presenting user interface
  
import RxSwift
import RxCocoa
import UIKit
import PlaygroundSupport
/// `Nationality`
enum Nationality: String {
    case german
    case italian
    case chinese
    case nigerian
    case british
}
/// `Person`
struct Person {
    let firstName: String
    let lastName: String
    let age: Int
    let nationality: Nationality
}
/// `TableDatasource`
class TableDatasource: NSObject, UITableViewDataSource, RxTableViewDataSourceType, SectionedViewDataSourceType, UITableViewDelegate {
    struct Section {
        let title: String
        let rows: [TableRow]

        init(title: String, rows: [TableRow]) {
            self.title = title
            self.rows = rows
        }
    }

    private var _model: [Section] = []

    typealias Element = [Section]
    func tableView(_ tableView: UITableView, observedEvent: Event<[TableDatasource.Section]>) {
        Binder(self) {form, sections in
            form._model = sections
            tableView.reloadData()
            }
            .on(observedEvent)
    }

    func model(at indexPath: IndexPath) throws -> Any {
        return _model[indexPath.section].rows[indexPath.row]
    }
    //MARK: Table View Data Source
    func numberOfSections(in tableView: UITableView) -> Int {
        return _model.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard section < _model.count else { return 0 }
        return _model[section].rows.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = _model[indexPath.section].rows[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: item.cellId, for: indexPath)
        item.configureCell(cell)
        return cell
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        guard section < _model.count else { return nil }
        return _model[section].title
    }
}
/// `TableRow`
protocol TableRow {
    var configureCell: (UITableViewCell) -> Void { get }
    static var cellIdentifier: String {get}
    static var nibName: String { get }
}

extension TableRow {
    var cellId: String { return Self.cellIdentifier }
}

/// `ContactViewController`
class ContactViewController: UITableViewController {

    /// Only Leader and the richest
    /// Disclaimer this data is just
    /// for example purposes. I am not
    /// responsible for any incorrect
    /// information. I hereby declare
    /// that I should not be held liable.
    let contacts = [
        Person(firstName: "Angela", lastName: "Merkel", age: 64, nationality: .german),
        Person(firstName: "Theresa", lastName: "May", age: 61, nationality: .british),
        Person(firstName: "Xi", lastName: "Jinping", age: 65, nationality: .chinese),
        Person(firstName: "Muhammadu", lastName: "Buhari", age: 75, nationality: .nigerian),
        Person(firstName: "Aliko", lastName: "Dangote", age: 61, nationality: .nigerian),
        Person(firstName: "Michele", lastName: "Ferrero", age: 93, nationality: .italian),
        Person(firstName: "Jack", lastName: "Ma", age: 53, nationality: .chinese),
        Person(firstName: "Silvio", lastName: "Berlusconi", age: 81, nationality: .italian),
        Person(firstName: "Richard", lastName: "Brandson", age: 67, nationality: .british),
        Person(firstName: "Georg", lastName: "Schaeffler", age: 53, nationality: .german),
        ]

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
