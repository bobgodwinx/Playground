//: Playground - noun: a place where people can play

import RxSwift
import RxCocoa
import MBProgressHUD
import SwiftGifOrigin

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

//MARK: Completable
extension ObservableType {
    func asCompletable() -> Completable {
        return ignoreElements()
    }
}

protocol ViewModelType {
    var source: Driver<UIImage?> {get}
    var finished: Completable {get}
}

class ViewModel: ViewModelType {
    let source: Driver<UIImage?>
    let finished: Completable

    init() {
        let url = URL(string: "https://media.giphy.com/media/5z08WdHr0h9SHZekve/giphy.gif")!
        let request = URLRequest(url: url)

        let datasource = URLSession.shared.rx
            .response(request: request)
            .map { UIImage.gif(data: $0.data) }
            .share(replay: 1, scope: .forever)

        self.source = datasource.asDriver(onErrorJustReturn: nil)
        self.finished = datasource.observeOn(MainScheduler.asyncInstance).take(1).asCompletable()
    }
}
