//
//  APITests.swift
//  MonitorizareVotTests
//
//  Created by Cristi Habliuc on 17/10/2019.
//  Copyright © 2019 Code4Ro. All rights reserved.
//

import XCTest
@testable import Dosarul_Digital

class APITests: XCTestCase {

    var sut: APIManagerType?

    let email = "andrei.bouariu@gmail.com"
    let password = "Testing1!"

    override func setUp() {
        sut = APIMock.shared
    }

    override func tearDown() {
        sut = nil
    }
    
    func testLogin() {
        var waiter = expectation(description: "Login Success")
        sut?.expectedStatusCode = 200
        sut?.login(email: email, password: password) { (response, error) in
            XCTAssertNil(error)
            waiter.fulfill()
        }
        wait(for: [waiter], timeout: 10)
        
        let wrongPassword = "password"
        
        waiter = expectation(description: "Login Bad Request")
        sut?.expectedStatusCode = 400
        sut?.login(email: email, password: wrongPassword) { (response, error) in
            XCTAssertNotNil(error)
            waiter.fulfill()
        }
        wait(for: [waiter], timeout: 10)
        
        waiter = expectation(description: "Login Unauthorized")
        sut?.expectedStatusCode = 401
        sut?.login(email: email, password: wrongPassword) { (response, error) in
            XCTAssertNotNil(error)
            waiter.fulfill()
        }
        wait(for: [waiter], timeout: 10)
        
        waiter = expectation(description: "Login Teapot")
        sut?.expectedStatusCode = 418
        sut?.login(email: email, password: wrongPassword) { (response, error) in
            XCTAssertNotNil(error)
            waiter.fulfill()
        }
        wait(for: [waiter], timeout: 10)
        
        waiter = expectation(description: "Login Internal Server Error")
        sut?.expectedStatusCode = 500
        sut?.login(email: email, password: wrongPassword) { (response, error) in
            XCTAssertNotNil(error)
            waiter.fulfill()
        }
        wait(for: [waiter], timeout: 10)
    }
    
    func test2FA() {
        var waiter = expectation(description: "2FA 200 Success")
        sut?.expectedStatusCode = 200
        sut?.expectedIndex = 0
        sut?.verify2FA(code: "") { (response, error) in
            XCTAssertNil(error)
            XCTAssertNotNil(response)
            XCTAssertTrue(response!.success)
            waiter.fulfill()
        }
        wait(for: [waiter], timeout: 10)
        
        waiter = expectation(description: "2FA 200 Failure")
        sut?.expectedIndex = 1
        sut?.verify2FA(code: "") { (response, error) in
            XCTAssertNil(error)
            XCTAssertNotNil(response)
            XCTAssertFalse(response!.success)
            waiter.fulfill()
        }
        wait(for: [waiter], timeout: 10)
        
        waiter = expectation(description: "2FA Bad Request")
        sut?.expectedStatusCode = 400
        sut?.expectedIndex = 0
        sut?.verify2FA(code: "") { (response, error) in
            XCTAssertNotNil(error)
            XCTAssertNil(response)
            waiter.fulfill()
        }
        wait(for: [waiter], timeout: 10)
        
        waiter = expectation(description: "2FA Unauthorized")
        sut?.expectedStatusCode = 401
        sut?.verify2FA(code: "") { (response, error) in
            XCTAssertNotNil(error)
            XCTAssertNil(response)
            waiter.fulfill()
        }
        wait(for: [waiter], timeout: 10)
        
        waiter = expectation(description: "2FA Internal Server Error")
        sut?.expectedStatusCode = 500
        sut?.verify2FA(code: "") { (response, error) in
            XCTAssertNotNil(error)
            XCTAssertNil(response)
            waiter.fulfill()
        }
        wait(for: [waiter], timeout: 10)
    }
    
    func testResend2FA() {
        var waiter = expectation(description: "2FA Retry Success")
        sut?.expectedStatusCode = 200
        sut?.verify2FA(code: "") { (response, error) in
            XCTAssertNil(error)
            XCTAssertNotNil(response)
            XCTAssertTrue(response!.success)
            waiter.fulfill()
        }
        wait(for: [waiter], timeout: 10)
        
        waiter = expectation(description: "2FA Retry Bad Request")
        sut?.expectedStatusCode = 400
        sut?.verify2FA(code: "") { (response, error) in
            XCTAssertNotNil(error)
            XCTAssertNil(response)
            waiter.fulfill()
        }
        wait(for: [waiter], timeout: 10)
        
        waiter = expectation(description: "2FA Retry Unauthorized")
        sut?.expectedStatusCode = 401
        sut?.verify2FA(code: "") { (response, error) in
            XCTAssertNotNil(error)
            XCTAssertNil(response)
            waiter.fulfill()
        }
        wait(for: [waiter], timeout: 10)
        
        waiter = expectation(description: "2FA Retry Internal Server Error")
        sut?.expectedStatusCode = 500
        sut?.verify2FA(code: "") { (response, error) in
            XCTAssertNotNil(error)
            XCTAssertNil(response)
            waiter.fulfill()
        }
        wait(for: [waiter], timeout: 10)
    }
    
    func testResetPassword() {
        var waiter = expectation(description: "Reset Password Success")
        sut?.expectedStatusCode = 200
        sut?.resetPassword(password: "", confirmPassword: "") { (error) in
            XCTAssertNil(error)
            waiter.fulfill()
        }
        wait(for: [waiter], timeout: 10)
        
        waiter = expectation(description: "Reset Password Bad Request")
        sut?.expectedStatusCode = 400
        sut?.resetPassword(password: "", confirmPassword: "") { (error) in
            XCTAssertNotNil(error)
            waiter.fulfill()
        }
        wait(for: [waiter], timeout: 10)
        
        waiter = expectation(description: "Reset Password Unauthorized")
        sut?.expectedStatusCode = 401
        sut?.resetPassword(password: "", confirmPassword: "") { (error) in
            XCTAssertNotNil(error)
            waiter.fulfill()
        }
        wait(for: [waiter], timeout: 10)
        
        waiter = expectation(description: "Reset Password Internal Server Error")
        sut?.expectedStatusCode = 500
        sut?.resetPassword(password: "", confirmPassword: "") { (error) in
            XCTAssertNotNil(error)
            waiter.fulfill()
        }
        wait(for: [waiter], timeout: 10)
    }
    
    func testFetchCounties() {
        var waiter = expectation(description: "Fetch Counties Success")
        sut?.expectedStatusCode = 200
        sut?.fetchCounties() { (counties, error) in
            XCTAssertNil(error)
            XCTAssertNotNil(counties)
            XCTAssert(counties!.count > 0)
            waiter.fulfill()
        }
        wait(for: [waiter], timeout: 10)
        
        waiter = expectation(description: "Fetch Counties Bad Request")
        sut?.expectedStatusCode = 400
        sut?.fetchCounties() { (counties, error) in
            XCTAssertNotNil(error)
            XCTAssertNil(counties)
            waiter.fulfill()
        }
        wait(for: [waiter], timeout: 10)
        
        waiter = expectation(description: "Fetch Counties Unauthorized")
        sut?.expectedStatusCode = 401
        sut?.fetchCounties() { (counties, error) in
            XCTAssertNotNil(error)
            XCTAssertNil(counties)
            waiter.fulfill()
        }
        wait(for: [waiter], timeout: 10)
        
        waiter = expectation(description: "Fetch Counties Internal Server Error")
        sut?.expectedStatusCode = 500
        sut?.fetchCounties() { (counties, error) in
            XCTAssertNotNil(error)
            XCTAssertNil(counties)
            waiter.fulfill()
        }
        wait(for: [waiter], timeout: 10)
    }
    
    func testFetchCities() {
        var waiter = expectation(description: "Fetch Cities Success")
        sut?.expectedStatusCode = 200
        sut?.fetchCities(countyId: 1) { (cities, error) in
            XCTAssertNil(error)
            XCTAssertNotNil(cities)
            XCTAssert(cities!.count > 0)
            waiter.fulfill()
        }
        wait(for: [waiter], timeout: 10)
        
        waiter = expectation(description: "Fetch Cities Bad Request")
        sut?.expectedStatusCode = 400
        sut?.fetchCities(countyId: 1) { (cities, error) in
            XCTAssertNotNil(error)
            XCTAssertNil(cities)
            waiter.fulfill()
        }
        wait(for: [waiter], timeout: 10)
        
        waiter = expectation(description: "Fetch Cities Unauthorized")
        sut?.expectedStatusCode = 401
        sut?.fetchCities(countyId: 1) { (cities, error) in
            XCTAssertNotNil(error)
            XCTAssertNil(cities)
            waiter.fulfill()
        }
        wait(for: [waiter], timeout: 10)
        
        waiter = expectation(description: "Fetch Cities Internal Server Error")
        sut?.expectedStatusCode = 500
        sut?.fetchCities(countyId: 1) { (cities, error) in
            XCTAssertNotNil(error)
            XCTAssertNil(cities)
            waiter.fulfill()
        }
        wait(for: [waiter], timeout: 10)
    }

    func testFetchBeneficiaries() {
        var waiter = expectation(description: "Fetch Beneficiaries Success")
        sut?.expectedStatusCode = 200
        sut?.fetchBeneficiaries() { (beneficiaries, error) in
            XCTAssertNil(error)
            XCTAssertNotNil(beneficiaries)
            XCTAssert(beneficiaries!.count > 0)
            waiter.fulfill()
        }
        wait(for: [waiter], timeout: 10)
        
        waiter = expectation(description: "Fetch Beneficiaries Bad Request")
        sut?.expectedStatusCode = 400
        sut?.fetchBeneficiaries() { (beneficiaries, error) in
            XCTAssertNotNil(error)
            XCTAssertNil(beneficiaries)
            waiter.fulfill()
        }
        wait(for: [waiter], timeout: 10)
        
        waiter = expectation(description: "Fetch Beneficiaries Unauthorized")
        sut?.expectedStatusCode = 401
        sut?.fetchBeneficiaries() { (beneficiaries, error) in
            XCTAssertNotNil(error)
            XCTAssertNil(beneficiaries)
            waiter.fulfill()
        }
        wait(for: [waiter], timeout: 10)
        
        waiter = expectation(description: "Fetch Beneficiaries Internal Server Error")
        sut?.expectedStatusCode = 500
        sut?.fetchBeneficiaries() { (beneficiaries, error) in
            XCTAssertNotNil(error)
            XCTAssertNil(beneficiaries)
            waiter.fulfill()
        }
        wait(for: [waiter], timeout: 10)
    }
    
    func testFetchBeneficiary() {
        var waiter = expectation(description: "Fetch Beneficiary Success")
        sut?.expectedStatusCode = 200
        sut?.fetchBeneficiary(beneficiaryId: 0, completion: { (beneficiary, error) in
            XCTAssertNil(error)
            XCTAssertNotNil(beneficiary)
            waiter.fulfill()
        })
        wait(for: [waiter], timeout: 10)
        
        waiter = expectation(description: "Fetch Beneficiary Bad Request")
        sut?.expectedStatusCode = 400
        sut?.fetchBeneficiary(beneficiaryId: 0, completion: { (beneficiary, error) in
            XCTAssertNotNil(error)
            XCTAssertNil(beneficiary)
            waiter.fulfill()
        })
        wait(for: [waiter], timeout: 10)
        
        waiter = expectation(description: "Fetch Beneficiary Unauthorized")
        sut?.expectedStatusCode = 401
        sut?.fetchBeneficiary(beneficiaryId: 0, completion: { (beneficiary, error) in
            XCTAssertNotNil(error)
            XCTAssertNil(beneficiary)
            waiter.fulfill()
        })
        wait(for: [waiter], timeout: 10)
        
        waiter = expectation(description: "Fetch Beneficiary Internal Server Error")
        sut?.expectedStatusCode = 500
        sut?.fetchBeneficiary(beneficiaryId: 0, completion: { (beneficiary, error) in
            XCTAssertNotNil(error)
            XCTAssertNil(beneficiary)
            waiter.fulfill()
        })
        wait(for: [waiter], timeout: 10)
    }

    func testFetchForms() {
        var waiter = expectation(description: "Fetch Forms Success")
        sut?.expectedStatusCode = 200
        sut?.fetchForms(completion: { (forms, error) in
            XCTAssertNil(error)
            XCTAssertNotNil(forms)
            XCTAssert(forms!.count > 0)
            waiter.fulfill()
        })
        wait(for: [waiter], timeout: 10)
        
        waiter = expectation(description: "Fetch Forms Bad Request")
        sut?.expectedStatusCode = 400
        sut?.fetchForms(completion: { (forms, error) in
            XCTAssertNotNil(error)
            XCTAssertNil(forms)
            waiter.fulfill()
        })
        wait(for: [waiter], timeout: 10)
        
        waiter = expectation(description: "Fetch Forms Unauthorized")
        sut?.expectedStatusCode = 401
        sut?.fetchForms(completion: { (forms, error) in
            XCTAssertNotNil(error)
            XCTAssertNil(forms)
            waiter.fulfill()
        })
        wait(for: [waiter], timeout: 10)
        
        waiter = expectation(description: "Fetch Forms Internal Server Error")
        sut?.expectedStatusCode = 500
        sut?.fetchForms(completion: { (forms, error) in
            XCTAssertNotNil(error)
            XCTAssertNil(forms)
            waiter.fulfill()
        })
        wait(for: [waiter], timeout: 10)
    }
    
    func testFetchForm() {
        var waiter = expectation(description: "Fetch Form id 7 Success")
        sut?.expectedStatusCode = 200
        sut?.fetchForm(formId: 7, completion: { (form, error) in
            XCTAssertNil(error)
            XCTAssertNotNil(form)
            waiter.fulfill()
        })
        wait(for: [waiter], timeout: 10)
        
        waiter = expectation(description: "Fetch Form id 7 Bad Request")
        sut?.expectedStatusCode = 400
        sut?.fetchForm(formId: 7, completion: { (form, error) in
            XCTAssertNotNil(error)
            XCTAssertNil(form)
            waiter.fulfill()
        })
        wait(for: [waiter], timeout: 10)
        
        waiter = expectation(description: "Fetch Form id 7 Unauthorized")
        sut?.expectedStatusCode = 401
        sut?.fetchForm(formId: 7, completion: { (form, error) in
            XCTAssertNotNil(error)
            XCTAssertNil(form)
            waiter.fulfill()
        })
        wait(for: [waiter], timeout: 10)
        
        waiter = expectation(description: "Fetch Form id 7 Internal Server Error")
        sut?.expectedStatusCode = 500
        sut?.fetchForm(formId: 7, completion: { (form, error) in
            XCTAssertNotNil(error)
            XCTAssertNil(form)
            waiter.fulfill()
        })
        wait(for: [waiter], timeout: 10)
    }
    
    func testSendForm() {
        var waiter = expectation(description: "Send Form Response Success")
        sut?.expectedStatusCode = 200
        sut?.expectedIndex = 0
        sut?.sendForm(beneficiaryId: 0, completion: { (success, error) in
            XCTAssert(success)
            XCTAssertNil(error)
            waiter.fulfill()
        })
        wait(for: [waiter], timeout: 10)
        
        waiter = expectation(description: "Send Form Response Failure")
        sut?.expectedStatusCode = 200
        sut?.expectedIndex = 1
        sut?.sendForm(beneficiaryId: 0, completion: { (success, error) in
            XCTAssert(!success)
            XCTAssertNotNil(error)
            waiter.fulfill()
        })
        wait(for: [waiter], timeout: 10)
        
        waiter = expectation(description: "Send Form Bad Request")
        sut?.expectedStatusCode = 400
        sut?.expectedIndex = 0
        sut?.sendForm(beneficiaryId: 0, completion: { (success, error) in
            XCTAssert(!success)
            XCTAssertNotNil(error)
            waiter.fulfill()
        })
        wait(for: [waiter], timeout: 10)
        
        waiter = expectation(description: "Send Form Unauthorized")
        sut?.expectedStatusCode = 401
        sut?.sendForm(beneficiaryId: 0, completion: { (success, error) in
            XCTAssert(!success)
            XCTAssertNotNil(error)
            waiter.fulfill()
        })
        wait(for: [waiter], timeout: 10)
        
        waiter = expectation(description: "Send Form Internal Server Error")
        sut?.expectedStatusCode = 500
        sut?.sendForm(beneficiaryId: 0, completion: { (success, error) in
            XCTAssert(!success)
            XCTAssertNotNil(error)
            waiter.fulfill()
        })
        wait(for: [waiter], timeout: 10)
    }

}
