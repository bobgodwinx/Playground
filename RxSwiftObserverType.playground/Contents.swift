//: Playground - noun: a place where people can play

import RxSwift
import MBProgressHUD

class RxMBProgressHUD: ObserverType {

    static let shared = RxMBProgressHUD()

    enum State {
        case hide(view: UIView?, animated: Bool)
        case show(view: UIView?, animated: Bool)
    }

    typealias E = RxMBProgressHUD.State

    func on(_ event: Event<State>) {
        guard case .next(let state) = event else { return }
        switch state {
        case .hide(let view, let animated):
            if let view = view {
                MBProgressHUD.hide(for: view, animated: animated)
            }
        case .show(let view, let animated):
            if let view = view {
                MBProgressHUD.showAdded(to:view, animated: animated)
            }
        }
    }
}
