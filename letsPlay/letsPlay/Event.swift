//
//  Event.swift
//  letsPlay
//
//  Created by Sebastian Leon on 29.11.2021.
//

import Foundation

public struct Event: Hashable {
    public let id: UUID
    public let name: String
    public let startDate: Date
    public let endDate: Date

    public init(id: UUID, name: String, startDate: Date, endDate: Date) {
        self.id = id
        self.name = name
        self.startDate = startDate
        self.endDate = endDate
    }
}

public struct RemoteEvent: Codable {
    public let id: UUID
    public let name: String
    public let startDate: Date
    public let endDate: Date
}
