import Foundation
import XCResultKit

let arguments = CommandLineArguments.parseOrExit()

let derivedData = DerivedData()
derivedData.location = URL(fileURLWithPath: arguments.derivedDataFolder)
guard let resultKit = derivedData.recentResultFile() else {
    print("Unable to find XCResult file!")
    exit(1)
}

let server = RoundupServer(hostURL: arguments.roundupURL)

// Collect a list of all the attachments in this XCResult file
let attachments = resultKit.gatherAttachments(arguments: arguments)

// Now try to upload them to the RoundUp server
var uploadedAttachments: [TestAttachment] = []
for attachment in attachments {
    if let payloadID = attachment.payloadRef?.id, let exportedURL = resultKit.exportPayload(id: payloadID) {
        if let uploaded = server.upload(exportedURL, name: attachment.name ?? "", fileName: attachment.filename ?? "", contentPath: arguments.contentPath) {
            uploadedAttachments.append(uploaded)
        }
    }
}

// Write out our final list of uploaded files
let jsonEncoder = JSONEncoder()
do {
    let encodedData = try jsonEncoder.encode(uploadedAttachments)
    try encodedData.write(to: URL(fileURLWithPath: arguments.output))
} catch {
    print("Error encoding the json output")
}
