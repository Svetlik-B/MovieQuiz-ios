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
        let question = questions[currentQuestionIndex]
        let correctAnswer = question.correctAnswer
        showAnswerResult(isCorrect: answer == correctAnswer)
    }
    
    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        let answer = true
        let question = questions[currentQuestionIndex]
        let correctAnswer = question.correctAnswer
        showAnswerResult(isCorrect: answer == correctAnswer)
    }
    
    private func showAnswerResult(isCorrect: Bool) {
        if isCorrect {
            correctAnswers += 1
            setImageBorder(color: UIColor(named: "YP Green"))
        } else {
            setImageBorder(color: UIColor(named: "YP Red"))
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
           self.showNextQuestionOrResults()
        }
    }
    
    private func setImageBorder(color: UIColor?) {
        guard let color else {
            imageView.layer.borderWidth = 0
            imageView.layer.borderColor = nil
            imageView.layer.cornerRadius = 0
            return
        }
        imageView.layer.borderWidth = 8
        imageView.layer.borderColor = color.cgColor
        imageView.layer.cornerRadius = 20
    }
    
    private func showNextQuestionOrResults() {
        if currentQuestionIndex == questions.count - 1 {
            let viewModel = QuizResultsViewModel(
                title: "Этот раунд окончен!",
                text: "Ваш результат \(correctAnswers)/\(questions.count)",
                buttonText: "Сыграть ещё раз"
            )
            show(quiz: viewModel)
        } else {
            setImageBorder(color: nil)
            currentQuestionIndex += 1
            show(
                quiz: convert(
                    model: questions[currentQuestionIndex]
                )
            )
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        show(
            quiz: convert(
                model: questions[currentQuestionIndex]
            )
        )
    }
    struct QuizResultsViewModel {
      let title: String
      let text: String
      let buttonText: String
    }
    
    struct QuizQuestion {
        let image: String
        let text: String
        let correctAnswer: Bool
    }
    
    struct QuizStepViewModel {
      let image: UIImage?
      let question: String
      let questionNumber: String
    }
    
    private func convert(model: QuizQuestion) -> QuizStepViewModel {
        let total = questions.count
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
    }
    
    private func show(quiz result: QuizResultsViewModel) {
        let alert = UIAlertController(
            title: result.title,
            message: result.text,
            preferredStyle: .alert
        )
        let action = UIAlertAction(
            title: result.buttonText,
            style: .default
        ) { _ in
            self.setImageBorder(color: nil)
            self.correctAnswers = 0
            self.currentQuestionIndex = 0
            self.show(
                quiz: self.convert(
                    model: self.questions[self.currentQuestionIndex]
                )
            )
        }
        
        alert.addAction(action)

        self.present(alert, animated: true, completion: nil)

    }

    private let questions: [QuizQuestion] = [
        QuizQuestion(
            image: "The Godfather",
            text: "Рейтинг этого фильма больше чем 6?",
            correctAnswer: true),
        QuizQuestion(
            image: "The Dark Knight",
            text: "Рейтинг этого фильма больше чем 6?",
            correctAnswer: true),
        QuizQuestion(
            image: "Kill Bill",
            text: "Рейтинг этого фильма больше чем 6?",
            correctAnswer: true),
        QuizQuestion(
            image: "The Avengers",
            text: "Рейтинг этого фильма больше чем 6?",
            correctAnswer: true),
        QuizQuestion(
            image: "Deadpool",
            text: "Рейтинг этого фильма больше чем 6?",
            correctAnswer: true),
        QuizQuestion(
            image: "The Green Knight",
            text: "Рейтинг этого фильма больше чем 6?",
            correctAnswer: true),
        QuizQuestion(
            image: "Old",
            text: "Рейтинг этого фильма больше чем 6?",
            correctAnswer: false),
        QuizQuestion(
            image: "The Ice Age Adventures of Buck Wild",
            text: "Рейтинг этого фильма больше чем 6?",
            correctAnswer: false),
        QuizQuestion(
            image: "Tesla",
            text: "Рейтинг этого фильма больше чем 6?",
            correctAnswer: false),
        QuizQuestion(
            image: "Vivarium",
            text: "Рейтинг этого фильма больше чем 6?",
            correctAnswer: false)
    ]
    private var currentQuestionIndex = 0
    private var correctAnswers = 0
}
