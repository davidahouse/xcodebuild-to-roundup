//
//  File.swift
//  
//
//  Created by David House on 10/5/20.
//

import Foundation

class RoundupServer {
    
    let session: URLSession
    let hostURL: String
    
    init(hostURL: String) {
        self.hostURL = hostURL
        session = URLSession(configuration: URLSessionConfiguration.default)
    }
    
    func upload(_ file: URL) -> TestAttachment {
        let request = MutableURLRequest(url: file)
        request.httpMethod = "POST"
        
        let task = session.dataTask(with: request) { (data, response, error) in
            
        }
        
    }
}
