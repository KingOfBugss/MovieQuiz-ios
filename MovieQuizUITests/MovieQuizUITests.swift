//
//  MovieQuizUITests.swift
//  MovieQuizUITests
//
//  Created by Ilya Shirokov on 25.01.2024.
//

import XCTest
@testable import MovieQuiz

final class MovieQuizUITests: XCTestCase {
    
    var app: XCUIApplication!

    override func setUpWithError() throws {
        try super.setUpWithError()
        
        app = XCUIApplication()
        app.launch()
        
        continueAfterFailure = false
    }

    override func tearDownWithError() throws {
        try super.tearDownWithError()
        
        app.terminate()
        app = nil
    }
    
    func testYesButton() {
        sleep(3)
        
        let firstPoster = app.images["Poster"]
        let firstPosterScreenshot = firstPoster.screenshot().pngRepresentation
        
        app.buttons["Yes"].tap()
        sleep(3)
        
        let secondPoster = app.images["Poster"]
        let secondPosterScreenshot = secondPoster.screenshot().pngRepresentation
        
        let indexLable = app.staticTexts["Index"]
        
        XCTAssertNotEqual(firstPosterScreenshot, secondPosterScreenshot)
        XCTAssertEqual(indexLable.label, "2/10")
    }
    
    func testNoButton() {
        sleep(3)
        
        let firstPoster = app.images["Poster"]
        let firstPosterScreenshot = firstPoster.screenshot().pngRepresentation
        
        app.buttons["No"].tap()
        sleep(3)
        
        let secondPoster = app.images["Poster"]
        let secondPosterScreenshot = secondPoster.screenshot().pngRepresentation
        
        let indexLable = app.staticTexts["Index"]
        
        XCTAssertNotEqual(firstPosterScreenshot, secondPosterScreenshot)
        XCTAssertEqual(indexLable.label, "2/10")
    }
    
    func testAlertFinish() {
        for _ in 1...10 {
            app.buttons["No"].tap()
            sleep(2)
        }
        
        let alert = app.alerts["Alert"]
        
        XCTAssertTrue(alert.exists)
        XCTAssertTrue(alert.label == "Этот раунд окончен!")
        XCTAssertTrue(alert.buttons.firstMatch.label == "Сыграть ещё раз")
    }
    
    func testAlertAppeared() {
        for _ in 1...10 {
            app.buttons["Yes"].tap()
            sleep(2)
        }
        
        let alert = app.alerts["Alert"]
        alert.buttons.firstMatch.tap()
        
        sleep(2)
        
        let indexLable = app.staticTexts["Index"]
        
        XCTAssertFalse(alert.exists)
        XCTAssertTrue(indexLable.label == "1/10")
    }
}
