import XCTest

import xcodebuild_to_roundupTests

var tests = [XCTestCaseEntry]()
tests += xcodebuild_to_roundupTests.allTests()
XCTMain(tests)
