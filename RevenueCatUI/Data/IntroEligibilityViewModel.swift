//
//  IntroEligibilityViewModel.swift
//  
//
//  Created by Nacho Soto on 7/26/23.
//

import RevenueCat
import SwiftUI

/// Holds the state for dynamically computed `IntroEligibilityStatus`
/// for single or multi-package templates, depending on `PackageConfiguration`.
@available(iOS 16.0, macOS 13.0, tvOS 16.0, *)
@MainActor
final class IntroEligibilityViewModel: ObservableObject {

    typealias PackageConfiguration = TemplateViewConfiguration.PackageConfiguration

    private let introEligibilityChecker: TrialOrIntroEligibilityChecker

    init(introEligibilityChecker: TrialOrIntroEligibilityChecker) {
        self.introEligibilityChecker = introEligibilityChecker
    }

    @Published
    private(set) var allEligibility: [Package: IntroEligibilityStatus] = [:]
    @Published
    private(set) var singleEligibility: IntroEligibilityStatus?

}

@available(iOS 16.0, macOS 13.0, tvOS 16.0, *)
extension IntroEligibilityViewModel {

    func computeEligibility(for packages: PackageConfiguration) async {
        switch packages {
        case let .single(package):
            self.singleEligibility = await self.introEligibilityChecker.eligibility(for: package.content)

        case let .multiple(_, _, packages):
            self.allEligibility = await self.introEligibilityChecker.eligibility(for: packages.map(\.content))
        }
    }

}