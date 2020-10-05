import Foundation
import XCResultKit

let arguments = CommandLineArguments.parseOrExit()

let derivedData = DerivedData()
derivedData.location = URL(fileURLWithPath: arguments.derivedDataFolder)
guard let resultKit = derivedData.recentResultFile() else {
    print("Unable to find XCResult file!")
    exit(1)
}

// Collect a list of all the attachments in this XCResult file
let attachments = resultKit.gatherAttachments(arguments: arguments)

// Now try to upload them to the RoundUp server
let uploadedAttachments: [TestAttachment] = []


// Write out our final list of uploaded files
let jsonEncoder = JSONEncoder()
do {
    let encodedData = try jsonEncoder.encode(uploadedAttachments)
    try encodedData.write(to: URL(fileURLWithPath: arguments.output))
} catch {
    print("Error encoding the json output")
}
