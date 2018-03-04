//
//  Settings.swift
//  ConArtist
//
//  Created by Cameron Eldridge on 2018-03-01.
//  Copyright © 2018 Cameron Eldridge. All rights reserved.
//

struct Settings {
    let currency: CurrencyCode

    static let `default` = Settings()

    private init() {
        currency = .CAD
    }

    init?(graphQL settings: SettingsFragment) {
        currency = CurrencyCode(rawValue: settings.currency) ?? Settings.default.currency
    }
}
