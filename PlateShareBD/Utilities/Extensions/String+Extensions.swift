//
//  String+Extensions.swift
//  PlateShareBD
//
//  Created by PlateShare Team.
//

import Foundation

extension String {
    /// Basic email format validation
    var isValidEmail: Bool {
        let pattern = #"^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$"#
        return self.range(of: pattern, options: .regularExpression) != nil
    }

    /// Truncate a string to a max length with ellipsis
    func truncated(to maxLength: Int) -> String {
        if self.count <= maxLength { return self }
        return String(self.prefix(maxLength)) + "..."
    }
}
