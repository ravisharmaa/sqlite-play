//
//  QueueService.swift
//  swift-ui-sqlite
//
//  Created by Ravi Bastola on 1/2/21.
//

import Foundation

struct QueueService {
    static let backgroundQueue: DispatchQueue = DispatchQueue(label: "com.gcd.background", qos: .background)
}
