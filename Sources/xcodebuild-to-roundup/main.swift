import Foundation
import XCResultKit

let arguments = CommandLineArguments.parseOrExit()

let derivedData = DerivedData()
derivedData.location = URL(fileURLWithPath: arguments.derivedDataFolder)
guard let resultKit = derivedData.recentResultFile() else {
    print("Unable to find XCResult file!")
    exit(1)
}

guard let invocationRecord = resultKit.getInvocationRecord() else {
    print("Unable to find invocation record in XCResult file!")
    exit(1)
}

var testRunSummaries: [ActionTestPlanRunSummary] = []
for action in invocationRecord.actions {
    if let testRef = action.actionResult.testsRef {
        if let runSummaries = resultKit.getTestPlanRunSummaries(id: testRef.id) {

            let tests = gatherTests(summaries: runSummaries.summaries)
            for test in tests {
                if let testID = test.summaryRef?.id {

                    print("test id: \(testID)")

                    if let testSummary = resultKit.getActionTestSummary(id: testID) {
                        for asummary in testSummary.activitySummaries {
                            for attachment in asummary.attachments {
                                print("filename: \(attachment.filename)")
                                print("name: \(attachment.name)")
                            }
                        }
                    }
                }
            }
        }
    }
}

func gatherTests(summaries: [ActionTestPlanRunSummary]) -> [ActionTestMetadata] {
    var foundTests = [ActionTestMetadata]()
    for summary in summaries {
        for testableSummary in summary.testableSummaries {
            for testGroup in testableSummary.tests {
                foundTests += gatherTests(group: testGroup)
            }
        }
    }
    return foundTests
}

func gatherTests(group: ActionTestSummaryGroup) -> [ActionTestMetadata] {
    var tests = group.subtests
    for group in group.subtestGroups {
        tests += gatherTests(group: group)
    }
    return tests
}


//let testSummary = gatherTestSummary(from: resultKit)
//
//let jsonEncoder = JSONEncoder()
//do {
//    let encodedData = try jsonEncoder.encode(testSummary)
//    try encodedData.write(to: URL(fileURLWithPath: arguments.output))
//} catch {
//    print("Error encoding the json output")
//}
//
