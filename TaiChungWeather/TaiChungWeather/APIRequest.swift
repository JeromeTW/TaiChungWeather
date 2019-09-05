//
//  APIRequest.swift
//  DDTDemo
//
//  Created by Allen Lai on 2019/7/29.
//  Copyright © 2019 Allen Lai. All rights reserved.
//

import Foundation

enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
}

struct HTTPHeader {
    let field: String
    let value: String
}

struct APIRequest {
    var url: URL
    let method: HTTPMethod
    var queryItems: [URLQueryItem]?
    var headers: [HTTPHeader]?
    var body: Data?
  
  init(url: URL, method: HTTPMethod = .get, bodyData: Data? = nil) {
        self.url = url
        self.method = method
        self.body = bodyData
    }
    
    init<JSONObject: Encodable>(url: URL, method: HTTPMethod = .get, jsonObject: JSONObject) throws {
        self.url = url
        self.method = method
        self.body = try JSONEncoder().encode(jsonObject)
    }
}

struct APIResponse<Body> {
    let statusCode: Int
    let body: Body
}

// MARK: - For JSON Object
extension APIResponse where Body == Data? {
    func decode<BodyType: Decodable>(to type: BodyType.Type) throws -> APIResponse<BodyType> {
        guard let data = body else {
            throw APIError.decodingFailure
        }
        let decodeJSON = try JSONDecoder().decode(BodyType.self, from: data)
        return APIResponse<BodyType>(statusCode: self.statusCode, body: decodeJSON)
    }
}

enum APIError: Error {
    case invalidURL
    case requestFailed
    case decodingFailure
    case unknown(error: Error)
}
