//
//  SwiftClockTests.swift
//  SwiftClockTests
//
//  Created by Joseph Daniels on 06/09/16.
//  Copyright © 2016 Joseph Daniels. All rights reserved.
//

import XCTest

class SwiftClockTests: XCTestCase {
        
    override func setUp() {
        super.setUp()
        
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
        // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
        XCUIApplication().launch()

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        // Use recording to get started writing UI tests.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        let app = XCUIApplication()
        let element = XCUIApplication().children(matching: .Window).elementBoundByIndex(0).childrenMatchingType(.Other).element.childrenMatchingType(.Other).elementBoundByIndex(1)
        element.tap()
        element.tap()
        element.tap()
        element.tap()
        element.tap()
        let fromCoordinate = app.coordinateWithNormalizedOffset(CGVector(dx: 0, dy: 10))
        let toCoordinate = app.coordinateWithNormalizedOffset(CGVector(dx: 0, dy: 20))
        fromCoordinate.pressForDuration(0, thenDragToCoordinate: toCoordinate)
        
    }
    
}
