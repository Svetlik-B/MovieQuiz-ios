import Foundation

struct GameResult {
    let correct: Int
    let total: Int
    let date: Date
}

extension GameResult {
    func isBetterThan(_ another: GameResult) -> Bool {
        correct > another.correct
    }
}
