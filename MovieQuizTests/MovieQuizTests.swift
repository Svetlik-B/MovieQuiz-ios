//
//  MovieQuizTests.swift
//  MovieQuizTests
//
//  Created by Svetlana Bochkareva on 28.11.2024.
//

import XCTest

enum ArithmeticOperations {
    static func addition(num1: Int, num2: Int) -> Int {
        return num1 + num2
    }
    
    static func subtraction(num1: Int, num2: Int) -> Int {
        return num1 - num2
    }
    
    static func multiplication(num1: Int, num2: Int) -> Int {
        return num1 * num2
    }
}

final class MovieQuizTests: XCTestCase {
    func testAddition() {
        XCTAssertEqual(
            ArithmeticOperations.addition(num1: 1, num2: 2),
            3
        )
    }
}
