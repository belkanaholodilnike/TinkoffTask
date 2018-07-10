//
//  ErrorHandler.swift
//  TinkoffTask
//
//  Created by Sher Locked on 07.07.2018.
//  Copyright © 2018 Sher Locked. All rights reserved.
//

import UIKit

class ErrorHandler: ErrorHandlerProtocol {
    
    weak var vc: UIViewController?
    
    init(vc: UIViewController?) {
        self.vc = vc
    }
    
    func handleError(_ error: TTError) {
        guard let description = error.getDescription() else {
            return
        }
        let alert = UIAlertController(title: "Error", message: description, preferredStyle: .alert)
        let alertAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(alertAction)
        vc?.present(alert, animated: true, completion: nil)
    }
}
