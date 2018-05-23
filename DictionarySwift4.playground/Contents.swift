//: A UIKit based Playground for presenting user interface
  
import RxSwift
import UIKit
import PlaygroundSupport

enum Nationality: String {
    case german
    case italian
    case chinese
    case nigerian
    case british
}

class MyViewController : UIViewController {

    let bag = DisposeBag()
    override func loadView() {
        let view = UIView()
        view.backgroundColor = .white

        let label = UILabel()
        label.frame = CGRect(x: 150, y: 200, width: 200, height: 20)
        label.text = "Hello World!"
        label.textColor = .black
        
        view.addSubview(label)
        self.view = view
    }
}
// Present the view controller in the Live View window
PlaygroundPage.current.liveView = MyViewController()
