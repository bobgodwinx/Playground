//: Playground - noun: a place where people can play

import RxSwift
import MBProgressHUD

class RxMBProgressHUD {

    static let shared = RxMBProgressHUD()

    enum State {
        case hide(view: UIView, animated: Bool)
        case show(view: UIView, animated: Bool)
    }
}
