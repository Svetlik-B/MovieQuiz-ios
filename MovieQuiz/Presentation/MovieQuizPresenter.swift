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
        showAnswerResult(isCorrect: answer == correctAnswer)
    }
    func userAnswerNo() {
        let answer = false
        guard let currentQuestion else { return }
        let correctAnswer = currentQuestion.correctAnswer
        showAnswerResult(isCorrect: answer == correctAnswer)
    }
    func convert(model: QuizQuestion) -> QuizStepViewModel {
        let total = questionsAmount
        let questionNumber = "\(currentQuestionIndex + 1)/\(total)"
        return .init(
            imageData: model.imageData,
            question: model.text,
            questionNumber: questionNumber
        )
    }
    func showAnswerResult(isCorrect: Bool) {
        viewController?.showLoadingIndicator()
        if isCorrect {
            correctAnswers += 1
            viewController?.setImageBorder(color: UIColor(named: "YP Green"))
        } else {
            viewController?.setImageBorder(color: UIColor(named: "YP Red"))
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            self?.viewController?.hideLoadingIndicator()
            self?.showNextQuestionOrResults()
        }
    }
    func showNextQuestionOrResults() {
        if currentQuestionIndex == questionsAmount - 1 {
            statisticService?.store(
                correct: correctAnswers,
                total: questionsAmount
            )
            let text = """
                Ваш результат \(correctAnswers)/\(questionsAmount)
                Количество сыгранных квизов: \(statisticService?.gamesCount ?? 0)
                Рекорд: \(statisticService?.bestGame.description ?? "")
                Средняя точность: \(String(format: "%.2f", statisticService?.totalAccuracy ?? 0))%
                """
            let viewModel = QuizResultsViewModel(
                title: "Этот раунд окончен!",
                text: text,
                buttonText: "Сыграть ещё раз"
            )
            show(quiz: viewModel)
        } else {
            viewController?.setImageBorder(color: nil)
            currentQuestionIndex += 1
            questionFactory?.requestNextQuestion()
        }
    }
    func show(quiz result: QuizResultsViewModel) {
        let model = AlertModel(
            title: result.title,
            message: result.text,
            buttonText: result.buttonText
        ) { [weak self] in
            self?.viewController?.setImageBorder(color: nil)
            self?.correctAnswers = 0
            self?.currentQuestionIndex = 0
            self?.questionFactory?.requestNextQuestion()
        }
        if let viewController {
            let alertPresenter = ResultAlertPresenter(model: model)
            alertPresenter.present(on: viewController)
        }
    }
    func showNetworkError(message: String) {
        viewController?.hideLoadingIndicator()
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
        if let viewController {
            let alertPresenter = ResultAlertPresenter(model: model)
            alertPresenter.present(on: viewController)
        }
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
        showNetworkError(message: error.localizedDescription)
    }
    func didLoadDataFromServer() {
        questionFactory?.requestNextQuestion()
        viewController?.hideLoadingIndicator()
    }
}
