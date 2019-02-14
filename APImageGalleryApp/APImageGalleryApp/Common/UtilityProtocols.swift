//
//  UtilityProtocols.swift

//

import Foundation
import UIKit

public protocol UtilityProtocols: class {
    func showServerErrorAlert()
    func showAlertWithMessage(message: String)
}

extension UtilityProtocols where Self: UIViewController {
    
    func showServerErrorAlert() {
        
        let alert = UIAlertController(title: "Server Error", message: "Service is not responding", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true)
    }
    
    func showAlertWithMessage(message: String) {
        let alert = UIAlertController(title: "Server Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true)
    }
}
