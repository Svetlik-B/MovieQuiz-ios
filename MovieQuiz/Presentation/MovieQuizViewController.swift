import UIKit


final class MovieQuizViewController: UIViewController {
    // MARK: - Lifecycle
    
    @IBOutlet private var imageView: UIImageView!
    @IBOutlet private var textLabel: UILabel!
    @IBOutlet private var counterLabel: UILabel!
    
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
            let viewModel = QuizResultsViewModel(
                title: "Этот раунд окончен!",
                text: "Ваш результат \(correctAnswers)/\(questionsAmount)",
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
        
        questionFactory = QuestionFactory(delegate: self)
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
        )
        let alertPresenter = AlertPresenter(model: model, delegate: self)
        alertPresenter.present(on: self)
    }

    private var currentQuestionIndex = 0
    private var correctAnswers = 0
    private let questionsAmount: Int = 10
    private var questionFactory: QuestionFactoryProtocol?
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

// MARK: AlertPresenterDelegate
extension MovieQuizViewController: AlertPresenterDelegate {
    func onButtonTapped() {
        setImageBorder(color: nil)
        correctAnswers = 0
        currentQuestionIndex = 0
        questionFactory?.requestNextQuestion()

    }
}
