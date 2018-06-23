//: Playground - noun: a place where people can play

import RxSwift
import RxCocoa
import MBProgressHUD
import SwiftGifOrigin
import UIKit
import PlaygroundSupport
/// `Utility`
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

typealias Resource = (response: HTTPURLResponse, data: Data)

protocol ModelType {
    var datasource: Observable<Resource> {get}
}
/// `Model`
struct Model: ModelType {

    let datasource: Observable<Resource>

    init() {
        let url = URL(string: "https://media.giphy.com/media/5z08WdHr0h9SHZekve/giphy.gif")!
        let request = URLRequest(url: url)
        self.datasource = URLSession.shared.rx
            .response(request: request)
            .share(replay: 1, scope: .forever)
    }
}

protocol ViewModelType {
    var source: Driver<UIImage?> {get}
    var finished: Completable {get}
}
/// `ViewModel`
class ViewModel: ViewModelType {
    let source: Driver<UIImage?>
    let finished: Completable

    init(_ model: ModelType = Model()) {
        self.source = model.datasource
            .map { UIImage.gif(data: $0.data) }
            .asDriver(onErrorJustReturn: nil)

        self.finished = model.datasource
            .observeOn(MainScheduler.asyncInstance)
            .take(1)
            .asCompletable()
    }
}
/// `ViewController`
class ViewController: UIViewController {
    private let bag = DisposeBag()
    private let indicator = PublishRelay<RxMBProgressHUD.State>()
    private let viewModel: ViewModelType

    init(_ viewModel: ViewModelType = ViewModel()) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        configure()
    }

    required init?(coder aDecoder: NSCoder) { fatalError("Please initialise programmatically") }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        indicator.accept(RxMBProgressHUD.State.show(view: self.view, animated: true))
        let imageView = configuredImageView()
        view.addSubview(imageView)

        viewModel
            .source
            .drive(imageView.rx.image)
            .disposed(by: bag)
    }

    private func configure() {
        self.view.backgroundColor = .red

        indicator.bind(to: RxMBProgressHUD.shared).disposed(by: bag)
        viewModel.finished
            .subscribe(onCompleted: { self.indicator.accept(RxMBProgressHUD.State.hide(view: self.view, animated: true)) })
            .disposed(by: bag)
    }

    private func configuredImageView() -> UIImageView {
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 375.0, height: 668.0))
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        return imageView
    }
}

// Present the view controller in the Live View window
PlaygroundPage.current.liveView = ViewController()
