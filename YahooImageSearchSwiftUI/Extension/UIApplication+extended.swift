//
//  UIApplication+extended.swift
//  YahooImageSearchSwiftUI
//
//  Created by cano on 2021/05/09.
//

import SwiftUI

extension UIApplication {
    func endEditing() {
        sendAction(
            #selector(UIResponder.resignFirstResponder),
            to: nil,
            from: nil,
            for: nil
        )
    }
}
