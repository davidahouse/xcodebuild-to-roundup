//
//  File.swift
//  
//
//  Created by David House on 10/5/20.
//

import Foundation

class RoundupServer {

    public struct MultipartFormElement {
        let name: String
        let fileName: String?
        let contentType: String?
        let data: Data

        public init(name: String, value: String) {
            self.name = name
            self.fileName = nil
            self.contentType = nil
            self.data = value.data(using: .utf8) ?? Data()
        }

        public init(name: String, fileName: String, contentType: String, data: Data) {
            self.name = name
            self.fileName = fileName
            self.contentType = contentType
            self.data = data
        }
    }

    let session: URLSession
    let hostURL: String
    
    init(hostURL: String) {
        self.hostURL = hostURL
        session = URLSession(configuration: URLSessionConfiguration.default)
    }
    
    func upload(_ file: URL, name: String, fileName: String, contentPath: String) -> TestAttachment? {
        guard let uploadURL = URL(string: hostURL) else {
            return nil
        }

        var request = URLRequest(url: uploadURL.appendingPathComponent("/api/upload"))
        request.httpMethod = "POST"

        let boundary = "Boundary-" + UUID().uuidString.replacingOccurrences(of: "-", with: "")
        request.addValue("multipart/form-data; boundary=" + boundary, forHTTPHeaderField: "Content-Type")
        var formData = Data()
        let fileData: Data? = {
            do {
                let fileData = try Data(contentsOf: file)
                return fileData
            } catch {
                return nil
            }
        }()

        guard let rawData = fileData else {
            return nil
        }

        let elements = [
            MultipartFormElement(name: "fileName", value: fileName),
            MultipartFormElement(name: "contentPath", value: contentPath),
            MultipartFormElement(name: "file", fileName: "file", contentType: "image/png", data: rawData)
        ]

        for element in elements {
            formData.appendString("--" + boundary + "\r\n")
            if element.fileName != nil {
                formData.appendString("Content-Disposition: form-data; name=\"\(element.name)\"; filename=\"\(element.fileName ?? "")\"\r\n")
            } else {
                formData.appendString("Content-Disposition: form-data; name=\"\(element.name)\"\r\n")
            }

            if element.contentType != nil {
                formData.appendString("Content-Type: \"\(element.contentType ?? "")\"\r\n")
            }

            formData.appendString("\r\n")
            formData.append(element.data)
            formData.appendString("\r\n")
        }

        formData.appendString("--" + boundary + "--")
        print("body length: \(formData.count)")
        request.httpBody = formData

        print("Uploading \(fileName)")
        let semaphore = DispatchSemaphore(value: 0)
        let task = session.dataTask(with: request as URLRequest) { (data, response, error) in
            if let error = error {
                print("Error from server: \(error.localizedDescription)")
            }
            if let data = data, let stringRepresentation = String(data: data, encoding: .utf8) {
                print(stringRepresentation)
            }
            semaphore.signal()
        }
        task.resume()
        _ = semaphore.wait(timeout: .distantFuture)
        let uploaded = TestAttachment(title: name, fileName: fileName, url: uploadURL.appendingPathComponent(contentPath + "/" + fileName).absoluteString)
        return uploaded
    }
}

extension Data {

    mutating func appendString(_ string: String) {

        if let data = string.data(using: .utf8) {
            append(data)
        }
    }
}
