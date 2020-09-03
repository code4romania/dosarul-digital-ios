//
//  CaseFileUITests.swift
//  CaseFileUITests
//
//  Created by Andrei Bouariu on 01/09/2020.
//  Copyright © 2020 Code4Ro. All rights reserved.
//

import XCTest

class CaseFileUITests: XCTestCase {

    override func setUpWithError() throws {
        continueAfterFailure = false
        let app = XCUIApplication()
        app.launchEnvironment = [
            "env": "test"
        ]
        app.launch()
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testLoginFailure() throws {
        XCUIApplication().buttons["Login"].tap()
        
    }
    
    
    func testExample() throws {
    }
}
