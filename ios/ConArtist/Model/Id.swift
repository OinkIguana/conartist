//
//  Id.swift
//  ConArtist
//
//  Created by Cameron Eldridge on 2018-05-10.
//  Copyright © 2018 Cameron Eldridge. All rights reserved.
//

import Foundation

enum Id: Codable, Equatable {
    private enum Cases: String, Codable {
        case temp
        case id
    }
    private enum CodingKeys: String, CodingKey {
        case `case`
        case id
    }

    case temp(Int)
    case id(Int)

    init(from decoder: Decoder) throws {
        let json = try decoder.container(keyedBy: CodingKeys.self)
        switch try json.decode(Cases.self, forKey: .case) {
        case .temp: self = Id.temporary()
        case .id: self = .id(try json.decode(Int.self, forKey: .id))
        }
    }

    var id: Int? {
        guard case .id(let id) = self else {
            return nil
        }
        return id
    }

    var isTemp: Bool {
        switch self {
        case .temp: return true
        default: return false
        }
    }

    private static var tempTicker = 0
    static func temporary() -> Id {
        tempTicker += 1
        return .temp(tempTicker)
    }

    func encode(to encoder: Encoder) throws {
        var json = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .id(let id):
            try json.encode(Cases.id, forKey: .case)
            try json.encode(id, forKey: .id)
        case .temp:
            try json.encode(Cases.temp, forKey: .case)
        }
    }
}
