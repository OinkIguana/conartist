//
//  URL+Constants.swift
//  ConArtist
//
//  Created by Cameron Eldridge on 2018-12-05.
//  Copyright © 2018 Cameron Eldridge. All rights reserved.
//

import Foundation

extension URL {
    static let conartist: URL = URL(string: Config.retrieve(Config.WebURL.self))!
    static let privacyPolicy: URL = URL(string: Config.retrieve(Config.WebURL.self) + "/privacy")!
    static let termsOfService: URL = URL(string: Config.retrieve(Config.WebURL.self) + "/terms")!
    static func mailto(_ address: String) -> URL {
        return URL(string: "mailto:\(address)")!
    }
}
