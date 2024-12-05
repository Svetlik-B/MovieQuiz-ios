import UIKit

struct MovieQuizPresenter {
    let questionsAmount: Int = 10
    var currentQuestionIndex = 0
    var correctAnswers = 0
    var currentQuestion: QuizQuestion?
    var questionFactory: QuestionFactoryProtocol?
    var statisticService: StatisticService?
}
