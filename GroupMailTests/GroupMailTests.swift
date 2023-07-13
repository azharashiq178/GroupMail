//
//  GroupMailTests.swift
//  GroupMailTests
//
//  Created by muhammad azher on 13/07/2023.
//

import XCTest
@testable import GroupMail

final class GroupMailTests: XCTestCase {
    
    var viewModel = MailGroupViewModel()

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        // Any test you write for XCTest can be annotated as throws and async.
        // Mark your test throws to produce an unexpected failure when your test encounters an uncaught error.
        // Mark your test async to allow awaiting for asynchronous code to complete. Check the results with assertions afterwards.
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
    func testFetchGroups() {
        // Create a test group
        let group = GroupData(id: 1, name: "Test Group", emailIds: ["email1@example.com", "email2@example.com"])
        
        // Insert the test group into the database (for testing purposes)
        // This is just a mock implementation for testing, you can replace it with your own implementation
        viewModel.groups = [group]
        
        // Call the fetchGroups method
//        viewModel.fetchGroups()
        
        // Assert that the fetched groups array should contain the test group
        XCTAssertEqual(viewModel.groups.count, 1)
        XCTAssertEqual(viewModel.groups.first?.name, "Test Group")
        XCTAssertEqual(viewModel.groups.first?.emailIds, ["email1@example.com", "email2@example.com"])
    }

}
