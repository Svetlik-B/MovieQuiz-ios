import UIKit


final class MovieQuizViewController: UIViewController {
    // MARK: - Lifecycle
    
    @IBOutlet private var imageView: UIImageView!
    @IBOutlet private var textLabel: UILabel!
    @IBOutlet private var counterLabel: UILabel!
    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    @IBOutlet private weak var noButton: UIButton!
    @IBOutlet private weak var yesButton: UIButton!
    
    private var movieQuizPresenter: MovieQuizPresenter!
}
 
extension MovieQuizViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        movieQuizPresenter = MovieQuizPresenter(view: self)
        
        imageView.layer.cornerRadius = 20
        imageView.layer.borderWidth = 8
        showLoadingIndicator()
        setImageBorder(color: nil)
        activityIndicator.hidesWhenStopped = true
        
        self.movieQuizPresenter.statisticService = StatisticServiceImplementation()
        self.movieQuizPresenter.questionFactory = QuestionFactory(
            moviesLoader: MoviesLoader(),
            delegate: self
        )
        self.movieQuizPresenter.questionFactory?.loadData()
    }

    @IBAction private func noButtonClicked(_ sender: UIButton) {
        let answer = false
        guard let currentQuestion = movieQuizPresenter.currentQuestion
        else {
            return
        }
        let correctAnswer = currentQuestion.correctAnswer
        showAnswerResult(isCorrect: answer == correctAnswer)
    }
    
    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        let answer = true
        guard let currentQuestion = movieQuizPresenter.currentQuestion
        else {
            return
        }
        let correctAnswer = currentQuestion.correctAnswer
        showAnswerResult(isCorrect: answer == correctAnswer)
    }
    
    private func showLoadingIndicator() {
        activityIndicator.startAnimating()
        yesButton.isEnabled = false
        noButton.isEnabled = false
    }
    
    private func hideLoadingIndicator() {
        activityIndicator.stopAnimating()
    }
    
    private func showNetworkError(message: String) {
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
    
    private func showAnswerResult(isCorrect: Bool) {
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
    
    private func setImageBorder(color: UIColor?) {
        guard let color else {
            imageView.layer.borderColor = UIColor.clear.cgColor
            return
        }
        imageView.layer.borderColor = color.cgColor
    }
    
    private func showNextQuestionOrResults() {
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
        
    private func convert(model: QuizQuestion) -> QuizStepViewModel {
        let total = movieQuizPresenter.questionsAmount
        let questionNumber = "\(movieQuizPresenter.currentQuestionIndex + 1)/\(total)"
        return .init(
            image: UIImage(data: model.image),
            question: model.text,
            questionNumber: questionNumber
        )
    }
    
    private func show(quiz step: QuizStepViewModel) {
        counterLabel.text = step.questionNumber
        imageView.image = step.image
        textLabel.text = step.question
        yesButton.isEnabled = true
        noButton.isEnabled = true
    }
    
    private func show(quiz result: QuizResultsViewModel) {
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
        let viewModel = convert(model: question)
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

