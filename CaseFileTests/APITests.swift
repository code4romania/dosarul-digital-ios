//
//  APITests.swift
//  MonitorizareVotTests
//
//  Created by Cristi Habliuc on 17/10/2019.
//  Copyright © 2019 Code4Ro. All rights reserved.
//

import XCTest
@testable import CaseFile

class APITests: XCTestCase {
    
    let correctPhone = "0722445566"
    let correctPin = "389756"

    var sut: APIManagerType?

    override func setUp() {
        sut = APIManager.shared
    }

    override func tearDown() {
        sut = nil
    }
    
    func testLogin() {
        let knownPhone = correctPhone
        let knownPin = correctPin
        var waiter = expectation(description: "Successful Login")
        sut?.login(email: knownPhone, password: knownPin, completion: { error in
            XCTAssertNil(error)
            waiter.fulfill()
        })
        
        wait(for: [waiter], timeout: 10)
        
        let wrongPhone = "0722777889"
        let wrongPin = "12849"
        waiter = expectation(description: "Unsuccessful Login")
        sut?.login(email: wrongPhone, password: wrongPin, completion: { (error) in
            XCTAssertNotNil(error)
            waiter.fulfill()
        })
        
        wait(for: [waiter], timeout: 10)
    }

    func testGetPollingStations() {
        let knownPhone = correctPhone
        let knownPin = correctPin
        let waiter = expectation(description: "Polling Stations")
        sut?.login(email: knownPhone, password: knownPin, completion: { (error) in
            self.sut?.fetchCounties(then: { (stations, error) in
                XCTAssertNil(error)
                XCTAssertNotNil(stations)
                XCTAssert(stations!.count > 0)
                waiter.fulfill()
            })
        })
        
        wait(for: [waiter], timeout: 10)
    }

    func testGetFormsInFirstSet() {
        let knownPhone = correctPhone
        let knownPin = correctPin
        let waiter = expectation(description: "Forms")
        sut?.login(email: knownPhone, password: knownPin, completion: { (error) in
            self.sut?.fetchForms(diaspora: true, then: { (forms, error) in
                XCTAssertNil(error)
                XCTAssertNotNil(forms)
                XCTAssert(forms!.count > 0)
                waiter.fulfill()
            })
        })
        
        wait(for: [waiter], timeout: 10)
    }

}
