//
//  Date+Format.swift
//  xHtmlJunkiesDemo
//
//  Created by Apple on 08/12/20.
//

import Foundation

extension Date {
    
    func format(dateFormat: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = dateFormat
        return dateFormatter.string(from: self)
    }
}
