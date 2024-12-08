import UIKit

struct MovieQuizPresenter {
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
            delegate: viewController
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
}
