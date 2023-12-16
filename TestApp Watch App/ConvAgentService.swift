//
//  ConvAgentService.swift
//  TestApp Watch App
//
//  Created by Dániel Szabó on 08/12/2023.
//

import Foundation

class ConvAgentService {
    func sendUserMessage(message: String, completion: @escaping ([String: Any]?, Error?) -> Void) {
//        let apiUrl = URL(string: "http://192.168.0.7:3000/webhooks/rest/webhook")!
        let apiUrl = URL(string: "http://192.168.1.32:5005/webhooks/rest/webhook")!
        
        var request = URLRequest(url: apiUrl)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let payload: [String: Any] = [
            "sender": "wearable_user",
            "message": message
        ]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: payload, options: [])
        } catch {
            completion(nil, error)
            return
        }
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            guard let data = data, error == nil else {
                completion(nil, error)
                return
            }
            
            do {
                if let jsonArray = try JSONSerialization.jsonObject(with: data, options: []) as? [[String: Any]] {
                    // Find the first element with the "text" field
                    if let text = jsonArray.first(where: { $0["text"] != nil })?["text"] as? String {
                        completion(["text": text], nil)
                    } else {
                        completion(nil, NSError(domain: "CAS Response missing text field", code: 0, userInfo: nil))
                    }
                } else {
                    completion(nil, NSError(domain: "CAS Response missing text field", code: 0, userInfo: nil))
                }
            } catch {
                completion(nil, error)
            }
        }

        task.resume()

    }
}
