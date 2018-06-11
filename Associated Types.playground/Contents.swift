import Foundation
import UIKit

/// Rows `Interface`
protocol Row {
    /// PAT Placeholder for unknown Concrete Type `Model`
    associatedtype Model
    /// Recieves a parameter of Concrete Type `Model`
    func configure(with model: Model)
}
/// Concrete Type `Product`
struct Product { }
/// Concrete Type `Item`
struct Item { }
/// Concrete Type `ProductDetail`
struct ProductDetail { }

//MARK: - Constrained Type Erasure

/// Wrapper `AnyRow`
struct AnyRow<I>: Row {
    private let configureClosure: (I) -> Void
    /// Initialiser guaratees that `Model`
    /// should be a `Type` of `I`
    init<T: Row>(_ row: T) where T.Model == I {
        /// Matches the row `configure` func
        /// to the private the `configureClosure`
        configureClosure = row.configure
    }
    /// Conforming to `Row` protocol
    func configure(with model: I) {
        configureClosure(model)
    }
}
/// `ProductCell`
class ProductCell: Row {
    typealias Model = Product
    let name: String

    init(name: String) {
        self.name = name
    }
    /// Conforming to `Row` protocol
    func configure(with model: Model) {
        print("PATs PlaceHolder is now `Product` Concrete Type)")
        print("This will now be configured based on \(type(of: self))")
    }
}
/// `ProductDetailsCell`
class ProductDetailsCell: Row {
    typealias Model = Product
    let name: String
    let category: String

    init(name: String, category: String) {
        self.name = name
        self.category = category
    }
    /// Conforming to `Row` protocol
    func configure(with model: Model) {
        print("PATs PlaceHolder is now `Product` Concrete Type)")
        print("This will now be configured based on \(type(of: self))")
    }
}
/// Usage of PAT for Homogeneous Requirement
let productCell = ProductCell(name: "product-name")
let productDetailsCell = ProductDetailsCell(name: "product-name", category: "ABC-HT")
/// We only get a Homogeneous collection Type
let cells: [AnyRow<Product>] = [AnyRow(productCell), AnyRow(productDetailsCell)]
let product = Product()
cells.forEach { cell in cell.configure(with: product) }

//MARK: - Unconstra Type Erasure

/// Heterogeneous Requirement and Dynamic dispatch availability
/// Generic Wrapper `AnyCellRow` to match Heterogeneous Types + Dynamic Dispatch
struct AnyCellRow: Row {
    private let configureClosure: (Any) -> Void

    init<T: Row>(_ row: T) {
        configureClosure = { object in
            /// Asserting that `object` received is `type` of `T.Model`
            guard let model = object as? T.Model else { return }
            /// call the `T.configure` function on success
            row.configure(with: model)
        }
    }
    /// Conforming to `Row` protocol
    func configure(with model: Any) {
        configureClosure(model)
    }
}
/// `ItemCell`
class ItemCell: Row {
    typealias Model = Item
    let id: String

    init(id: String) {
        self.id = id
    }
    /// Conforming to `Row` protocol
    func configure(with model: Item) {
        print("PATs PlaceHolder is now `Item` Concrete Type)")
        print("This will now be configured based on \(type(of: self))")
    }
}
/// Usage of PAT for Heterogenous Requirement + Dynamic dispatch
let item = Item()
let itemCell = ItemCell(id: "an-itemCell")
/// We get a `Heterogenous`collection Type
let allCells = [AnyCellRow(productCell),
                AnyCellRow(productDetailsCell),
                AnyCellRow(itemCell)]

for (index, cell) in allCells.enumerated() {
    index <= 1 ? cell.configure(with: product) : cell.configure(with: item)
}

//MARK: - `Shadowed` Protocol Based Type Erasure

/// `shadow` protocol
protocol TableRow {
    /// - Recieves a parameter of Concrete Type `Any`
    func configure(with model: Any)
}
/// `AssociatedTableRow` To be shadowed.
protocol AssociatedTableRow: TableRow {
    associatedtype Model
    /// - Recieves a parameter of Concrete Type `Model`
    func configure(with model: Model)
}
/// `extension` to conform to `TableRow`
extension TableRow {
    /// TableRow - conformation
    func configure(with model: Any) {
        /// Just throw a fatalError
        /// because we don't need it.
        fatalError()
    }
}
/// `ProductDetailsCellRow`
class ProductDetailsCellRow: AssociatedTableRow {
    typealias Model = ProductDetail
    /// Conforming to `TableRow` protocol
    func configure(with model: ProductDetail) {
        print("AssociatedTableRow and Model is `ProductDetail`, Self is  \(type(of: self))")
    }
}

/// `ItemCellRow`
class ItemCellRow: AssociatedTableRow {
    typealias Model = Item
    /// Conforming to `TableRow` protocol
    func configure(with model: Item) {
        print("AssociatedTableRow and Model is `Item`, Self is  \(type(of: self))")
    }
}

class ProductCellRow: AssociatedTableRow {
    typealias Model = Product
    /// Conforming to `TableRow` protocol
    func configure(with model: Product) {
        print("AssociatedTableRow and Model is `Product`, Self is  \(type(of: self))")
    }
}
let productDetail = ProductDetail()
/// Usage of shadowed protocol styled type erasure
let associatedTableRows: [TableRow] = [ProductCellRow(), ProductDetailsCellRow(), ItemCellRow()]

for row in associatedTableRows {
    if let cell = row as? ProductCellRow {
        cell.configure(with: product)
    }

    if let cell = row as? ProductDetailsCellRow {
        cell.configure(with: productDetail)
    }

    if let cell = row as? ItemCellRow {
        cell.configure(with: item)
    }
}
