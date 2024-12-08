import UIKit

class MovieQuizPresenter {
    let questionsAmount: Int = 10
    var currentQuestionIndex = 0
    var correctAnswers = 0
    var currentQuestion: QuizQuestion?
    var questionFactory: QuestionFactoryProtocol?
    var statisticService: StatisticService?
    
    weak var viewController: MovieQuizViewController?
    init(viewController: MovieQuizViewController) {
        self.viewController = viewController
        self.statisticService = StatisticServiceImplementation()
        self.questionFactory = QuestionFactory(
            moviesLoader: MoviesLoader(),
            delegate: self
        )
        self.questionFactory?.loadData()
    }
}

extension MovieQuizPresenter {
    func userAnswerYes() {
        let answer = true
        guard let currentQuestion else { return }
        let correctAnswer = currentQuestion.correctAnswer
        viewController?.showAnswerResult(isCorrect: answer == correctAnswer)
    }
    func userAnswerNo() {
        let answer = false
        guard let currentQuestion else { return }
        let correctAnswer = currentQuestion.correctAnswer
        viewController?.showAnswerResult(isCorrect: answer == correctAnswer)
    }
    func convert(model: QuizQuestion) -> QuizStepViewModel {
        let total = questionsAmount
        let questionNumber = "\(currentQuestionIndex + 1)/\(total)"
        return .init(
            image: UIImage(data: model.image),
            question: model.text,
            questionNumber: questionNumber
        )
    }
}

// MARK: - QuestionFactoryDelegate
extension MovieQuizPresenter: QuestionFactoryDelegate {
    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question else {
            return
        }
        currentQuestion = question
        let viewModel = convert(model: question)
        DispatchQueue.main.async { [weak self] in
            self?.viewController?.show(quiz: viewModel)
        }
    }
    func didFailToLoadData(with error: Error) {
        viewController?.showNetworkError(message: error.localizedDescription)
    }
    func didLoadDataFromServer() {
        questionFactory?.requestNextQuestion()
        viewController?.hideLoadingIndicator()
    }
}
