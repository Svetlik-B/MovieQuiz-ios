import Foundation

final class StatisticServiceImplementation {
    private let storage: UserDefaults = .standard
}

extension StatisticServiceImplementation: StatisticService {
    var gamesCount: Int {
        get {
            self.storage.integer(forKey: Keys.gamesCount.rawValue)
        }
        set {
            self.storage.set(newValue, forKey: Keys.gamesCount.rawValue)
        }
    }
    var bestGame: GameResult {
        get {
            return GameResult(
                correct: self.storage.integer(
                    forKey: Keys.bestGame.rawValue + ".correct"
                ),
                total: self.storage.integer(
                    forKey: Keys.bestGame.rawValue + ".total"
                ),
                date: self.storage.object(
                    forKey: Keys.bestGame.rawValue + ".date"
                ) as? Date ?? Date()
            )
        }
        set {
            self.storage.set(
                newValue.correct,
                forKey: Keys.bestGame.rawValue + ".correct"
            )
            self.storage.set(
                newValue.total,
                forKey: Keys.bestGame.rawValue + ".total"
            )
            self.storage.set(
                newValue.date,
                forKey: Keys.bestGame.rawValue + ".date"
            )
        }
    }
    var totalAccuracy: Double {
        let total = self.gamesCount * 10
        guard total > 0 else { return 0 }
        return Double(self.correct * 100) / Double(total)
    }
    func store(correct count: Int, total amount: Int) {
        self.gamesCount += 1
        self.correct += count
        let currentGame = GameResult(correct: count, total: amount, date: Date())
        if currentGame.isBetterThan(self.bestGame) {
            self.bestGame = currentGame
        }
    }
}

private extension StatisticServiceImplementation {
    enum Keys: String {
        case correct
        case bestGame
        case gamesCount
    }
    var correct: Int {
        get {
            self.storage.integer(forKey: Keys.correct.rawValue)
        }
        set {
            self.storage.set(newValue, forKey: Keys.correct.rawValue)
        }
    }
}
