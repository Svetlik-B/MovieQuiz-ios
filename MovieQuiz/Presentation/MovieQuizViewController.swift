import UIKit


final class MovieQuizViewController: UIViewController {
    @IBOutlet private var imageView: UIImageView!
    @IBOutlet private var textLabel: UILabel!
    @IBOutlet private var counterLabel: UILabel!
    @IBOutlet private var activityIndicator: UIActivityIndicatorView!
    @IBOutlet private weak var noButton: UIButton!
    @IBOutlet private weak var yesButton: UIButton!
    
    private var movieQuizPresenter: MovieQuizPresenter!
}
 
extension MovieQuizViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imageView.layer.cornerRadius = 20
        imageView.layer.borderWidth = 8
        showLoadingIndicator()
        removeAnswerCorrectnessIndication()
        activityIndicator.hidesWhenStopped = true
        
        movieQuizPresenter = MovieQuizPresenter(viewController: self)
    }
    func show(quiz step: QuizStepViewModel) {
        var image: UIImage? = nil
        if let data = step.imageData {
            image = UIImage(data: data)
        }
        counterLabel.text = step.questionNumber
        imageView.image = image
        textLabel.text = step.question
        yesButton.isEnabled = true
        noButton.isEnabled = true
    }
    func showLoadingIndicator() {
        activityIndicator.startAnimating()
        yesButton.isEnabled = false
        noButton.isEnabled = false
    }
    func hideLoadingIndicator() {
        activityIndicator.stopAnimating()
    }
    func indicateWrongAnswer() {
        imageView.layer.borderColor = UIColor(named: "YP Red")?.cgColor
    }
    func indicateCorrectAnswer() {
        imageView.layer.borderColor = UIColor(named: "YP Green")?.cgColor
    }
    func removeAnswerCorrectnessIndication() {
        imageView.layer.borderColor = UIColor.clear.cgColor
    }
}

private extension MovieQuizViewController {
    @IBAction func yesButtonClicked(_ sender: UIButton) {
        movieQuizPresenter.set(answer: true)
    }
    @IBAction func noButtonClicked(_ sender: UIButton) {
        movieQuizPresenter.set(answer: false)
    }
}
