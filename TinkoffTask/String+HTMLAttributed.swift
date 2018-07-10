//
//  String+HTMLAttributed.swift
//  TinkoffTask
//
//  Created by Sher Locked on 08.07.2018.
//  Copyright © 2018 Sher Locked. All rights reserved.
//

import Foundation

extension String {
    var html2Attributed: NSAttributedString? {
        do {
            guard let data = data(using: String.Encoding.utf8) else {
                return nil
            }
            return try NSAttributedString(data: data,
                                          options: [.documentType: NSAttributedString.DocumentType.html,
                                                    .characterEncoding: String.Encoding.utf8.rawValue],
                                          documentAttributes: nil)
        } catch {
            return nil
        }
    }
}
