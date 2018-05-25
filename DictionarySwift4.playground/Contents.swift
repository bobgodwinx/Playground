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
        /// In your App you should be using the storyboard to dequeue different cells
        /// let cell = tableView.dequeueReusableCell(withIdentifier: item.cellId, for: indexPath)
        /// for this example we going to use only `PersonCell` hope you get the trick
        let _cell = PersonCell(style: .value2, reuseIdentifier: item.cellId)
        item.configureCell(_cell)
        return _cell
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
}

extension TableRow {
    var cellId: String { return Self.cellIdentifier }
}

/// `Contactable`
protocol Contactable {
    var datasource: Driver<[TableDatasource.Section]> {get}
}
/// `ContactViewModel`
class ContactViewModel: Contactable {

    let datasource: Driver<[TableDatasource.Section]>
    /// `init`
    init(_ provider: Observable<[Person]>) {
        self.datasource = provider
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


let provider = Observable.of(contacts)
let viewModel = ContactViewModel(provider)

/// `ContactViewController`
class ContactViewController: UIViewController {
    private let bag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
    }

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

// Present the view controller in the Live View window
PlaygroundPage.current.liveView = ContactViewController()
