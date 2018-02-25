//
//  Sequence+Helpers.swift
//  ConArtist
//
//  Created by Cameron Eldridge on 2018-01-28.
//  Copyright © 2018 Cameron Eldridge. All rights reserved.
//

import Foundation

extension Sequence {
    func filterMap<T>(_ transform: (Element) -> T?) -> [T] {
        return map(transform).filter { $0 != nil } as! [T]
    }

    func count(where predicate: (Element) -> Bool) -> Int {
        return reduce(0) { count, element in count + (predicate(element) ? 1 : 0) }
    }
}

extension Sequence where Self.Element: Equatable {
    func count(ocurrencesOf instance: Element) -> Int {
        return count { $0 == instance }
    }
}