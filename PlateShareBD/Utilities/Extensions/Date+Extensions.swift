//
//  Date+Extensions.swift
//  PlateShareBD
//
//  Created by PlateShare Team.
//

import Foundation

extension Date {
    /// Returns a human-readable relative time string (e.g., "5 min ago", "2 hours ago")
    var timeAgo: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .short
        return formatter.localizedString(for: self, relativeTo: Date())
    }

    /// Returns formatted time for chat messages (e.g., "2:30 PM")
    var chatTime: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return formatter.string(from: self)
    }

    /// Returns formatted date for listings (e.g., "Feb 25, 2:30 PM")
    var listingDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, h:mm a"
        return formatter.string(from: self)
    }

    /// Check if the date is expired (in the past)
    var isExpired: Bool {
        return self < Date()
    }

    /// Returns a date that is `hours` hours from now
    static func hoursFromNow(_ hours: Int) -> Date {
        return Calendar.current.date(byAdding: .hour, value: hours, to: Date()) ?? Date()
    }
}
