import Foundation

/// A URLProtocol subclass that intercepts network requests for testing
class URLProtocolStub: URLProtocol {
    static var stubResponses: [URL: (data: Data?, response: URLResponse?, error: Error?)] = [:]
    static var requestHandler: ((URLRequest) throws -> (HTTPURLResponse, Data))?
    
    override class func canInit(with request: URLRequest) -> Bool {
        return true
    }
    
    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }
    
    override func startLoading() {
        guard let url = request.url else {
            client?.urlProtocol(self, didFailWithError: URLError(.badURL))
            return
        }
        
        // Check for specific stub responses first
        if let stubResponse = URLProtocolStub.stubResponses[url] {
            if let data = stubResponse.data {
                client?.urlProtocol(self, didLoad: data)
            }
            if let response = stubResponse.response {
                client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            }
            if let error = stubResponse.error {
                client?.urlProtocol(self, didFailWithError: error)
            }
            client?.urlProtocolDidFinishLoading(self)
            return
        }
        
        // Use request handler if available
        guard let handler = URLProtocolStub.requestHandler else {
            client?.urlProtocol(self, didFailWithError: URLError(.notConnectedToInternet))
            return
        }
        
        do {
            let (response, data) = try handler(request)
            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            client?.urlProtocol(self, didLoad: data)
            client?.urlProtocolDidFinishLoading(self)
        } catch {
            client?.urlProtocol(self, didFailWithError: error)
        }
    }
    
    override func stopLoading() {
        // No-op
    }
    
    // MARK: - Test Helpers
    
    static func stub(url: URL, data: Data?, response: URLResponse?, error: Error?) {
        stubResponses[url] = (data: data, response: response, error: error)
    }
    
    static func removeAllStubs() {
        stubResponses.removeAll()
        requestHandler = nil
    }
    
    static func setupMockOpenAIResponse(for endpoint: String, jsonData: Data) {
        let url = URL(string: "https://api.openai.com/v1\(endpoint)")!
        let response = HTTPURLResponse(
            url: url,
            statusCode: 200,
            httpVersion: nil,
            headerFields: ["Content-Type": "application/json"]
        )
        stub(url: url, data: jsonData, response: response, error: nil)
    }
}
