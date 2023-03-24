//
//  VerificationResultAPI.swift
//  SwiftAPITester
//
//  Created by Nacho Soto on 2/10/23.
//

import Foundation
import RevenueCat

func checkVerificationResultAPI(_ mode: EntitlementVerificationMode = .disabled,
                                _ result: VerificationResult = .notRequested) {
    switch mode {
    case .disabled,
            .informational,
            .enforced:
        break

    @unknown default: break
    }

    switch result {
    case .notRequested,
            .verified,
            .failed:
        break

    @unknown default: break
    }
}
