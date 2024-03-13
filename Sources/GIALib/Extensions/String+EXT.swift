//
//  File.swift
//  
//
//  Created by admin on 13.03.2024.
//

import Foundation

extension String? {
    public var unwrapString: String {
        guard let str = self else {
            return "-"
        }
        return str
    }
}
