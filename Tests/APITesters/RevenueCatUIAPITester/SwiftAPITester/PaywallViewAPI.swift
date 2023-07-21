//
//  PaywallViewAPI.swift
//  SwiftAPITester
//
//  Created by Nacho Soto on 7/14/23.
//

import RevenueCat
import RevenueCatUI
import SwiftUI

@available(iOS 16.0, macOS 13.0, tvOS 16.0, *)
struct App: View {

    private var offering: Offering

    var body: some View {
        PaywallView()
        PaywallView(mode: .fullScreen)
        PaywallView(offering: self.offering)
        PaywallView(mode: .card, offering: self.offering)
    }

    private func modes(_ mode: PaywallViewMode) {
        switch mode {
        case .fullScreen:
            break
        case .card:
            break
        case .banner:
            break
        }
    }

}
