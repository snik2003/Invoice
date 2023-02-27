//
//  String+Extension.swift
//  Invoice
//
//  Created by Сергей Никитин on 28.11.2022.
//

import UIKit

extension String {
    func capitalizingFirstLetter() -> String {
        return prefix(1).capitalized + dropFirst()
    }

    mutating func capitalizeFirstLetter() {
        self = self.capitalizingFirstLetter()
    }
    
    func convertToCurrencySymbol() -> String {
        switch self {
        case "RUB":
            return "₽"
        case "UAH":
            return "₴"
        case "THB":
            return "฿"
        default:
            return self
        }
    }
    
    var htmlAttributedString: NSAttributedString? {
        return try? NSAttributedString(data: Data(utf8), options: [.documentType: NSAttributedString.DocumentType.html, .characterEncoding: String.Encoding.utf8.rawValue], documentAttributes: nil)
    }
}
