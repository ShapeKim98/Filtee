//
//  DateStyle.swift
//  Filtee
//
//  Created by 김도형 on 6/16/25.
//

import Foundation

enum DateStyle: String, CaseIterable {
    case `default` = "yyyy-MM-dd'T'HH:mm:ss'Z'"
    case metadata = "yyyy:MM:dd HH:mm:ss"
    case chatTime = "a hh:mm"
    case chatDateDivider = "yyyy년 M월 d일 EEEE"
    case chat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
    
    
    static var cachedFormatter: [DateStyle: DateFormatter] {
        var formatters = [DateStyle: DateFormatter]()
        for style in Self.allCases {
            let formatter = DateFormatter()
            formatter.timeZone = TimeZone(identifier: "Asia/Seoul")
            formatter.locale = Locale(identifier: "ko_KR")
            formatter.dateFormat = style.rawValue
            formatters[style] = formatter
        }
        return formatters
    }
}

extension Date {
    func toString(
        _ style: DateStyle,
        identifier: String = "ko_KR"
    ) -> String {
        guard let formatter = DateStyle.cachedFormatter[style] else {
            return ""
        }
        formatter.locale = Locale(identifier: identifier)
        let secondsFromGMT = formatter.timeZone.secondsFromGMT()
        let newDate = self.addingTimeInterval(TimeInterval(secondsFromGMT))
        return formatter.string(from: newDate)
    }
}

extension String {
    func toDate(
        _ style: DateStyle,
        identifier: String = "ko_KR"
    ) -> Date? {
        guard let formatter = DateStyle.cachedFormatter[style] else {
            return nil
        }
        return formatter.date(from: self)
    }
    
    func convertDateFormat(_ from: DateStyle, to: DateStyle) -> String {
        guard let date = self.toDate(from) else { return self }
        return date.toString(to)
    }
}
