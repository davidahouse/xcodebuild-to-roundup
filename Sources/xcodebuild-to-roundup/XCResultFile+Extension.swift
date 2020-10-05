//
//  File.swift
//  
//
//  Created by David House on 10/5/20.
//

import Foundation
import XCResultKit

extension XCResultFile {
    
    func gatherAttachments(arguments: CommandLineArguments) -> [ActionTestAttachment] {
        
        guard let invocationRecord = getInvocationRecord() else {
            print("Unable to find invocation record in XCResult file!")
            exit(1)
        }

        var attachments: [ActionTestAttachment] = []
        for action in invocationRecord.actions {
            if let testRef = action.actionResult.testsRef {
                if let runSummaries = getTestPlanRunSummaries(id: testRef.id) {

                    let tests = gatherTests(summaries: runSummaries.summaries)
                    for test in tests {
                        if let testID = test.summaryRef?.id {

                            print("test id: \(testID)")

                            if let testSummary = getActionTestSummary(id: testID) {
                                for asummary in testSummary.activitySummaries {
                                    for attachment in asummary.attachments {
                                        
                                        attachments.append(attachment)
                                        
                                        print("filename: \(attachment.filename ?? "")")
                                        print("name: \(attachment.name ?? "")")
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }

        return attachments
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

}
