import Foundation
import UIKit

/// Rows `Interface`
protocol Row {
    ///PAT Placeholder for unknown Concrete Type `Model`
    associatedtype Model
    /// - Recieves a parameter of Concrete Type `Model`
    func configure(with model: Model)
}
/// Concrete Type `Product`
struct Product { }
/// Concrete Type `Item`
struct Item { }
/// Wrapper `AnyRow
struct AnyRow<I>: Row {
    private let configureClosure: (I) -> Void

    init<T: Row>(_ row: T) where T.Model == I {
        configureClosure = row.configure
    }

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

    func configure(with model: Model) {
        print("PATs PlaceHolder is now `Product` Concrete Type)")
        print("This will now be configured based on \(type(of: self))")
    }
}
/// Usage of PAT for Homogeneous Requirement
let productCell = ProductCell(name: "product-name")
let productDetailsCell = ProductDetailsCell(name: "product-name", category: "ABC-HT")
let cells: [AnyRow<Product>] = [AnyRow(productCell), AnyRow(productDetailsCell)]
let product = Product()
cells.forEach { cell in cell.configure(with: product) }

/// Heterogeneous Requirement and Dynamic dispatch availability
/// Generic Wrapper `AnyCellRow` to match Heterogeneous Types + Dynamic Dispatch
struct AnyCellRow: Row {

    private let configureClosure: (Any) -> Void

    init<I: Row>(_ row: I) {
        configureClosure = { object in
            guard let model = object as? I.Model else { return }
            row.configure(with: model)
        }
    }

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

    func configure(with model: Item) {
        print("PATs PlaceHolder is now `Item` Concrete Type)")
        print("This will now be configured based on \(type(of: self))")
    }
}


