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
