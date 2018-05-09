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
