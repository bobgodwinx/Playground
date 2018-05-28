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
struct Person: Hashable {
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
        /// In your App you should be using the storyboard to dequeue different cells
        /// If so then you can dequeue the cell as follows
        /// let cell = tableView.dequeueReusableCell(withIdentifier: item.cellId, for: indexPath)
        /// item.configuredCell(item.cellId, cell)
        /// for this example we going to use only `PersonCell` so we pass a `nil`
        /// and let the `TableRow` take care of it. hope you get the trick!
        return item.configuredCell(item.cellId, nil)
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        guard section < _model.count else { return nil }
        return _model[section].title
    }
}
/// `TableRow`
protocol TableRow {
    var configuredCell: (_ id: String, _ cell: UITableViewCell?) -> UITableViewCell { get }
    static var cellIdentifier: String {get}
}

extension TableRow {
    var cellId: String { return Self.cellIdentifier }
}

/// `PersonCell`
class PersonCell: UITableViewCell {

    override init(style: UITableViewCellStyle = .value2, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func prepareForReuse() {
        super.prepareForReuse()
    }

    func bind(_ model: Person) {
        self.textLabel?.text = model.firstName
        self.detailTextLabel?.text = model.lastName
        self.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        self.selectionStyle = .none
    }
}
/// `PersonRow`
struct PersonRow: TableRow {
    static var cellIdentifier: String { return "PersonRowCell" }
    let configuredCell: (_ id: String, _ cell: UITableViewCell?) -> UITableViewCell

    init(_ model: Person) {
        configuredCell = { id, cell in
            guard let cell = cell as? PersonCell else {
                let cell = PersonCell(style: .value2, reuseIdentifier: id)
                cell.bind(model)
                return cell
            }
            cell.bind(model)
            return cell
        }
    }
}
/// `ContactProviderType` = `Model` requirement
protocol ContactProviderType {
    /// Set that contains `Person`
    var contacts: Observable<Set<Person>> {get}
}
/// `ContactProvider` = `Model`
class ContactProvider: ContactProviderType {
    let contacts: Observable<Set<Person>>

    init() {
        /// Only Leader and the richest
        /// Disclaimer this data is just
        /// for example purposes. I am not
        /// responsible for any incorrect
        /// information. I hereby declare
        /// that I should not be held liable.
        self.contacts = Observable.of([
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
            ])
    }
}

/// `Contactable` = `ViewModel` requirement
protocol Contactable {
    var datasource: Driver<[TableDatasource.Section]> {get}
}
/// `ContactViewModel` = `ViewModel`
class ContactViewModel: Contactable {

    let datasource: Driver<[TableDatasource.Section]>
    /// `dependency inversion`
    init(_ provider: ContactProviderType) {
        self.datasource = provider
            .contacts
            .map { items -> [TableDatasource.Section] in
                 /// groupedByNationality = [Nationality: [Person]]` ///new feature in swift 4.x
                 /// let groupedByNationality  = Dictionary(grouping: items) { $0.nationality }
                /// For this example we are going to use the `LastName`
                /// `grouped = [Character: [Person]]` ///new feature in swift 4.x
                let grouped = Dictionary(grouping: items) { $0.lastName.first! }
                let keys = grouped.keys.sorted()
                return keys.map { key -> TableDatasource.Section in
                    let rows = grouped[key]?.compactMap(PersonRow.init) ?? []
                    return TableDatasource.Section(title: String(key), rows: rows)
                }
            }
            .asDriver(onErrorJustReturn: [])
    }
}

/// `ContactViewController` = `View`
class ContactViewController: UIViewController {
    private let bag = DisposeBag()
    let viewModel: Contactable
    
    /// `dependency inversion`
    init(_ viewModel: Contactable) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        configure()
    }

    required init?(coder aDecoder: NSCoder) { fatalError("Please initialise programmatically") }

    private func configure() {
        let tableView = UITableView(frame: CGRect(x: 0, y: 0, width: 768, height: 1024), style: .plain)
        tableView.register(PersonCell.self, forCellReuseIdentifier: PersonRow.cellIdentifier)
        /// Here goes the magical binding
        viewModel
            .datasource
            .drive(tableView.rx.items(dataSource: TableDatasource()))
            .disposed(by: bag)
        /// Adding the `UITableView` as subview
        view.addSubview(tableView)
    }
}

/// Now composing our `MVVM`
/// just like a plug and play

/// `Model`
let provider = ContactProvider()
/// `ViewModel`
let viewModel = ContactViewModel(provider)
/// `View`
let viewController = ContactViewController(viewModel)

// Present the view controller in the Live View window
PlaygroundPage.current.liveView = viewController
