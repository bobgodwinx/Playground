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
class AnyRow<I>: Row {
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
