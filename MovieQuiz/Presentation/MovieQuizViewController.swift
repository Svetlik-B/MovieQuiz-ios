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
        setImageBorder(color: nil)
        activityIndicator.hidesWhenStopped = true
        
        movieQuizPresenter = MovieQuizPresenter(viewController: self)
    }
    func showAnswerResult(isCorrect: Bool) {
        showLoadingIndicator()
        if isCorrect {
            movieQuizPresenter.correctAnswers += 1
            setImageBorder(color: UIColor(named: "YP Green"))
        } else {
            setImageBorder(color: UIColor(named: "YP Red"))
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            self?.hideLoadingIndicator()
            self?.showNextQuestionOrResults()
        }
    }
}

private extension MovieQuizViewController {
    @IBAction func yesButtonClicked(_ sender: UIButton) {
        movieQuizPresenter.userAnswerYes()
    }
    @IBAction func noButtonClicked(_ sender: UIButton) {
        movieQuizPresenter.userAnswerNo()
    }
    func showLoadingIndicator() {
        activityIndicator.startAnimating()
        yesButton.isEnabled = false
        noButton.isEnabled = false
    }
    func hideLoadingIndicator() {
        activityIndicator.stopAnimating()
    }
    func showNetworkError(message: String) {
        hideLoadingIndicator()
        let model = AlertModel(
            title: "Ошибка",
            message: message,
            buttonText: "Попробовать еще раз"
        ) { [weak self] in
            guard let self = self else { return }
            self.movieQuizPresenter.currentQuestionIndex = 0
            self.movieQuizPresenter.correctAnswers = 0
            self.movieQuizPresenter.questionFactory?.requestNextQuestion()
        }
        let alertPresenter = ResultAlertPresenter(model: model)
        alertPresenter.present(on: self)
    }
    func setImageBorder(color: UIColor?) {
        guard let color else {
            imageView.layer.borderColor = UIColor.clear.cgColor
            return
        }
        imageView.layer.borderColor = color.cgColor
    }
    func showNextQuestionOrResults() {
        if movieQuizPresenter.currentQuestionIndex == movieQuizPresenter.questionsAmount - 1 {
            self.movieQuizPresenter.statisticService?.store(
                correct: self.movieQuizPresenter.correctAnswers,
                total: self.movieQuizPresenter.questionsAmount
            )
            let text = """
                Ваш результат \(movieQuizPresenter.correctAnswers)/\(movieQuizPresenter.questionsAmount)
                Количество сыгранных квизов: \(self.movieQuizPresenter.statisticService?.gamesCount ?? 0)
                Рекорд: \(self.movieQuizPresenter.statisticService?.bestGame.description ?? "")
                Средняя точность: \(String(format: "%.2f", self.movieQuizPresenter.statisticService?.totalAccuracy ?? 0))%
                """
            let viewModel = QuizResultsViewModel(
                title: "Этот раунд окончен!",
                text: text,
                buttonText: "Сыграть ещё раз"
            )
            show(quiz: viewModel)
        } else {
            setImageBorder(color: nil)
            movieQuizPresenter.currentQuestionIndex += 1
            movieQuizPresenter.questionFactory?.requestNextQuestion()
        }
    }
    func show(quiz step: QuizStepViewModel) {
        counterLabel.text = step.questionNumber
        imageView.image = step.image
        textLabel.text = step.question
        yesButton.isEnabled = true
        noButton.isEnabled = true
    }
    func show(quiz result: QuizResultsViewModel) {
        let model = AlertModel(
            title: result.title,
            message: result.text,
            buttonText: result.buttonText
        ) { [weak self] in
            self?.setImageBorder(color: nil)
            self?.movieQuizPresenter.correctAnswers = 0
            self?.movieQuizPresenter.currentQuestionIndex = 0
            self?.movieQuizPresenter.questionFactory?.requestNextQuestion()
        }
        let alertPresenter = ResultAlertPresenter(model: model)
        alertPresenter.present(on: self)
    }
}

// MARK:  QuestionFactoryDelegate
extension MovieQuizViewController: QuestionFactoryDelegate {
    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question else {
            return
        }
        movieQuizPresenter.currentQuestion = question
        let viewModel = movieQuizPresenter.convert(model: question)
        DispatchQueue.main.async { [weak self] in
            self?.show(quiz: viewModel)
        }
    }
    func didFailToLoadData(with error: Error) {
        showNetworkError(message: error.localizedDescription)
    }
    func didLoadDataFromServer() {
        movieQuizPresenter.questionFactory?.requestNextQuestion()
        activityIndicator.stopAnimating()
    }
}

