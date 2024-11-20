import UIKit


final class MovieQuizViewController: UIViewController {
    // MARK: - Lifecycle
    
    @IBOutlet private var imageView: UIImageView!
    @IBOutlet private var textLabel: UILabel!
    @IBOutlet private var counterLabel: UILabel!
    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    @IBOutlet private weak var noButton: UIButton!
    @IBOutlet private weak var yesButton: UIButton!
    
    @IBAction private func noButtonClicked(_ sender: UIButton) {
        let answer = false
        guard let currentQuestion else {
            return
        }
        let correctAnswer = currentQuestion.correctAnswer
        showAnswerResult(isCorrect: answer == correctAnswer)
    }
    
    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        let answer = true
        guard let currentQuestion else {
            return
        }
        let correctAnswer = currentQuestion.correctAnswer
        showAnswerResult(isCorrect: answer == correctAnswer)
    }
    
    private func showLoadingIndicator() {
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
    }
    
    private func hideLoadingIndicator() {
        activityIndicator.isHidden = true
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
            self.currentQuestionIndex = 0
            self.correctAnswers = 0
            self.questionFactory?.requestNextQuestion()
        }
        let alertPresenter = ResultAlertPresenter(model: model)
        alertPresenter.present(on: self)
    }
    
    private func showAnswerResult(isCorrect: Bool) {
        if isCorrect {
            correctAnswers += 1
            setImageBorder(color: UIColor(named: "YP Green"))
        } else {
            setImageBorder(color: UIColor(named: "YP Red"))
        }
        noButton.isEnabled = false
        yesButton.isEnabled = false
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
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
        if currentQuestionIndex == questionsAmount - 1 {
            self.statisticService?.store(
                correct: self.correctAnswers,
                total: self.questionsAmount
            )
            let text = """
                Ваш результат \(correctAnswers)/\(questionsAmount)
                Количество сыгранных квизов: \(self.statisticService?.gamesCount ?? 0)
                Рекорд: \(self.statisticService?.bestGame.description ?? "")
                Средняя точность: \(String(format: "%.2f", self.statisticService?.totalAccuracy ?? 0))%
                """
            let viewModel = QuizResultsViewModel(
                title: "Этот раунд окончен!",
                text: text,
                buttonText: "Сыграть ещё раз"
            )
            show(quiz: viewModel)
        } else {
            setImageBorder(color: nil)
            currentQuestionIndex += 1
            questionFactory?.requestNextQuestion()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        imageView.layer.cornerRadius = 20
        imageView.layer.borderWidth = 8
        
        self.statisticService = StatisticServiceImplementation()
        questionFactory = QuestionFactoryImplementation(delegate: self)
        questionFactory?.requestNextQuestion()
    }
    
    private func convert(model: QuizQuestion) -> QuizStepViewModel {
        let total = questionsAmount
        let questionNumber = "\(currentQuestionIndex + 1)/\(total)"
        return .init(
            image: UIImage(named: model.image),
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
            self?.correctAnswers = 0
            self?.currentQuestionIndex = 0
            self?.questionFactory?.requestNextQuestion()
        }
        let alertPresenter = ResultAlertPresenter(model: model)
        alertPresenter.present(on: self)
    }

    private var currentQuestionIndex = 0
    private var correctAnswers = 0
    private let questionsAmount: Int = 10
    private var questionFactory: QuestionFactory?
    private var statisticService: StatisticService?
    private var currentQuestion: QuizQuestion?
    
}

// MARK:  QuestionFactoryDelegate
extension MovieQuizViewController: QuestionFactoryDelegate {
    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question else {
            return
        }
        currentQuestion = question
        let viewModel = convert(model: question)
        DispatchQueue.main.async { [weak self] in
            self?.show(quiz: viewModel)
        }
    }
}
