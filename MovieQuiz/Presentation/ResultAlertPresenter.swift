import UIKit

struct ResultAlertPresenter {
    var model: AlertModel
    weak var delegate: ResultAlertPresenterDelegate?
}

extension ResultAlertPresenter {
    func present(on viewController: UIViewController) {
        let alert = UIAlertController(
            title: model.title,
            message: model.message,
            preferredStyle: .alert
        )
        let action = UIAlertAction(
            title: model.buttonText,
            style: .default
        ) {  _ in
            delegate?.onButtonTapped()
        }
        alert.addAction(action)
        
        viewController.present(alert, animated: true, completion: nil)
    }
}

