import Foundation
class QuestionFactory {
    private let moviesLoader: MoviesLoading
    weak var delegate: QuestionFactoryDelegate?
    private var movies: [MostPopularMovie] = []
    
    init(moviesLoader: MoviesLoading, delegate: QuestionFactoryDelegate?) {
        self.moviesLoader = moviesLoader
        self.delegate = delegate
    }
}

extension QuestionFactory: QuestionFactoryProtocol {
    func requestNextQuestion() {
        DispatchQueue.global().async { [weak self] in
            guard let movie = self?.movies.randomElement()
            else {
                struct NoMovies: Error {}
                DispatchQueue.main.async {
                    self?.delegate?.didFailToLoadData(with: NoMovies())
                }
                return
            }
            let imageData = try? Data(contentsOf: movie.resizedImageURL)
            if imageData == nil {
                print("Failed to load image")
            }
            let rating = Float(movie.rating) ?? 0
            let text = "Рейтинг этого фильма больше чем 7?"
            let correctAnswer = rating > 7
            let question = QuizQuestion(
                image: imageData ?? Data(),
                text: text,
                correctAnswer: correctAnswer
            )
            DispatchQueue.main.async {
                self?.delegate?.didReceiveNextQuestion(
                    question: question
                )
            }
        }
    }
}
extension QuestionFactory {
    func loadData() {
        moviesLoader.loadMovies { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                switch result {
                case .success(let mostPopularMovies):
                    self.movies = mostPopularMovies.items
                    self.delegate?.didLoadDataFromServer()
                case .failure(let error):
                    self.delegate?.didFailToLoadData(with: error)
                }
            }
        }
    }
}

//private let questions: [QuizQuestion] = [
//    QuizQuestion(
//        image: "The Godfather",
//        text: "Рейтинг этого фильма больше чем 6?",
//        correctAnswer: true),
//    QuizQuestion(
//        image: "The Dark Knight",
//        text: "Рейтинг этого фильма больше чем 6?",
//        correctAnswer: true),
//    QuizQuestion(
//        image: "Kill Bill",
//        text: "Рейтинг этого фильма больше чем 6?",
//        correctAnswer: true),
//    QuizQuestion(
//        image: "The Avengers",
//        text: "Рейтинг этого фильма больше чем 6?",
//        correctAnswer: true),
//    QuizQuestion(
//        image: "Deadpool",
//        text: "Рейтинг этого фильма больше чем 6?",
//        correctAnswer: true),
//    QuizQuestion(
//        image: "The Green Knight",
//        text: "Рейтинг этого фильма больше чем 6?",
//        correctAnswer: true),
//    QuizQuestion(
//        image: "Old",
//        text: "Рейтинг этого фильма больше чем 6?",
//        correctAnswer: false),
//    QuizQuestion(
//        image: "The Ice Age Adventures of Buck Wild",
//        text: "Рейтинг этого фильма больше чем 6?",
//        correctAnswer: false),
//    QuizQuestion(
//        image: "Tesla",
//        text: "Рейтинг этого фильма больше чем 6?",
//        correctAnswer: false),
//    QuizQuestion(
//        image: "Vivarium",
//        text: "Рейтинг этого фильма больше чем 6?",
//        correctAnswer: false)
//]
