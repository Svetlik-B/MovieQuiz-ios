import Foundation

protocol MoviesLoading {
    func loadMovies(handler: @escaping (Result<MostPopularMovies, Error>) -> Void)
}

private var mostPopularMoviesUrl = URL(
    string: "https://tv-api.com/en/API/Top250Movies/k_zcuw1ytf"
)!

private enum ResponseError: Error {
    case message(String)
}

struct MoviesLoader: MoviesLoading {
    private let networkClient = NetworkClient()
    func loadMovies(handler: @escaping (Result<MostPopularMovies, Error>) -> Void) {
        networkClient.fetch(url: mostPopularMoviesUrl) { result in
            switch result {
            case .success(let data):
                do {
                    let mostPopularMovies = try JSONDecoder().decode(MostPopularMovies.self, from: data)
                    guard mostPopularMovies.errorMessage == ""
                    else {
                        throw ResponseError.message(
                            mostPopularMovies.errorMessage
                        )
                    }
                    handler(.success(mostPopularMovies))
                } catch {
                    handler(.failure(error))
                }
            case .failure(let error):
                handler(.failure(error))
            }
        }
    }}