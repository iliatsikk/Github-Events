//
//  NetworkLogger.swift
//  Networking
//
//  Created by Ilia Tsikelashvili on 11.04.25.
//

import Foundation
import Alamofire

final class NetworkLogger: EventMonitor {
  func requestDidResume(_ request: Request) {
    print("🚀 Request Started: \(request.description)")

    if let url = request.request?.url?.absoluteString {
      print("🔗 Endpoint: \(url)")
    }

    if let bodyData = request.request?.httpBody, let bodyString = String(data: bodyData, encoding: .utf8) {
      print("📦 Body: \(bodyString)")
    } else {
      print("📦 Body: No Body")
    }
  }

  func request<Value>(_ request: DataRequest, didParseResponse response: DataResponse<Value, AFError>) {
    if let headers = request.request?.allHTTPHeaderFields {
      print("📋 Headers: \(headers)")
    }

    if let statusCode = response.response?.statusCode {
      print("✅ Response Received: \(statusCode)")
    }

    if let data = response.data, let dataString = String(data: data, encoding: .utf8) {
      print("📝 Response Data: \(dataString)")
    } else {
      print("📝 Response Data: No Data")
    }

    if let error = response.error {
      logError(error)
    }
  }

  private func logError(_ error: AFError) {
    print("❌ Error: \(error.localizedDescription)")
  }
}
