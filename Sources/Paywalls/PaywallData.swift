//
//  Copyright RevenueCat Inc. All Rights Reserved.
//
//  Licensed under the MIT License (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//      https://opensource.org/licenses/MIT
//
//  PaywallData.swift
//
//  Created by Nacho Soto on 7/10/23.

import Foundation

/// The data necessary to display a paywall using the `RevenueCatUI` library.
/// They can be created and configured in the dashboard, then access from ``Offering/paywall``.
public struct PaywallData {

    /// The type of template used to display this paywall.
    public var template: PaywallTemplate

    /// Generic configuration for any paywall.
    public var config: Configuration

    /// The base remote URL where assets for this paywall are stored.
    public var assetBaseURL: URL

    fileprivate var defaultLocaleIdentifier: String
    fileprivate var localization: [String: LocalizedConfiguration]

}

/// Defines the necessary localized information for a paywall.
public protocol PaywallLocalizedConfiguration {

    /// The title of the paywall screen.
    var title: String { get }
    /// The subtitle of the paywall screen.
    var subtitle: String { get }
    /// The content of the main action button for purchasing a subscription.
    var callToAction: String { get }
    /// The content of the main action button for purchasing a subscription when an intro offer is available.
    /// If `nil`, no information regarding trial eligibility will be displayed.
    var callToActionWithIntroOffer: String? { get }
    /// Description for the offer to be purchased.
    var offerDetails: String { get }
    /// Description for the offer to be purchased when an intro offer is available.
    /// If `nil`, no information regarding trial eligibility will be displayed.
    var offerDetailsWithIntroOffer: String? { get }

}

// swiftlint:disable identifier_name

extension PaywallData {

    /// Defines the necessary localized information for a paywall.
    public struct LocalizedConfiguration: PaywallLocalizedConfiguration {

        // Docs inherited from the protocol
        // swiftlint:disable missing_docs

        public var title: String
        public var subtitle: String
        public var callToAction: String
        public var offerDetails: String
        @NonEmptyStringDecodable
        var _callToActionWithIntroOffer: String?
        @NonEmptyStringDecodable
        var _offerDetailsWithIntroOffer: String?

        public var callToActionWithIntroOffer: String? {
            get { return self._callToActionWithIntroOffer }
            set { self._callToActionWithIntroOffer = newValue }
        }
        public var offerDetailsWithIntroOffer: String? {
            get { return self._offerDetailsWithIntroOffer }
            set { self._offerDetailsWithIntroOffer = newValue }
        }

        public init(
            title: String,
            subtitle: String,
            callToAction: String,
            callToActionWithIntroOffer: String? = nil,
            offerDetails: String,
            offerDetailsWithIntroOffer: String? = nil
        ) {
            self.title = title
            self.subtitle = subtitle
            self.callToAction = callToAction
            self._callToActionWithIntroOffer = callToActionWithIntroOffer
            self.offerDetails = offerDetails
            self._offerDetailsWithIntroOffer = offerDetailsWithIntroOffer
        }

        // swiftlint:enable missing_docs
    }

    /// - Returns: ``PaywallData/LocalizedConfiguration-swift.struct`` for the given `Locale`, if found.
    public func config(for locale: Locale) -> LocalizedConfiguration? {
        return self.localization[locale.identifier]
    }

    /// The default `Locale` used if `Locale.current` is not configured for this paywall.
    public var defaultLocale: Locale {
        return .init(identifier: self.defaultLocaleIdentifier)
    }

    /// - Returns: the ``PaywallData/LocalizedConfiguration-swift.struct`` associated to the current `Locale`
    /// or the configuration associated to ``defaultLocale``.
    public var localizedConfiguration: LocalizedConfiguration {
        return self.config(for: Locale.current) ?? self.defaultLocalizedConfiguration
    }

    private var defaultLocalizedConfiguration: LocalizedConfiguration {
        let defaultLocale = self.defaultLocale

        guard let result = self.config(for: defaultLocale) else {
            fatalError(
                "Corrupted data. Expected to find locale \(defaultLocale.identifier) " +
                "in locales: \(Set(self.localization.keys))"
            )
        }

        return result
    }

}

extension PaywallData {

    /// Generic configuration for any paywall.
    public struct Configuration {

        /// The list of package types this paywall will display
        public var packages: [PackageType]

        /// The name for the header image asset.
        public var headerImageName: String

        // swiftlint:disable:next missing_docs
        public init(packages: [PackageType], headerImageName: String) {
            self.packages = packages
            self.headerImageName = headerImageName
        }

    }

}

// MARK: - Extensions

public extension PaywallData {

    /// The remote URL to load the header image asset.
    var headerImageURL: URL {
        return self.assetBaseURL.appendingPathComponent(self.config.headerImageName)
    }

}

// MARK: - Constructors

extension PaywallData {

    init(
        template: PaywallTemplate,
        config: Configuration,
        defaultLocale: String,
        localization: [String: LocalizedConfiguration],
        assetBaseURL: URL
    ) {
        self.template = template
        self.config = config
        self.defaultLocaleIdentifier = defaultLocale
        self.localization = localization
        self.assetBaseURL = assetBaseURL
    }

    /// Creates a test ``PaywallData`` with one localization
    public init(
        template: PaywallTemplate,
        config: Configuration,
        localization: LocalizedConfiguration,
        assetBaseURL: URL
    ) {
        let locale = Locale.current.identifier

        self.init(
            template: template,
            config: config,
            defaultLocale: locale,
            localization: [locale: localization],
            assetBaseURL: assetBaseURL
        )
    }

}

// MARK: - Codable

extension PaywallData.LocalizedConfiguration: Codable {

    private enum CodingKeys: String, CodingKey {
        case title
        case subtitle
        case callToAction
        case _callToActionWithIntroOffer = "callToActionWithIntroOffer"
        case offerDetails
        case _offerDetailsWithIntroOffer = "offerDetailsWithIntroOffer"
    }

}

extension PaywallData.Configuration: Codable {

    private enum CodingKeys: String, CodingKey {
        case packages
        case headerImageName = "headerImage"
    }

}

extension PaywallData: Codable {

    // Note: these are camel case but converted by the decoder
    private enum CodingKeys: String, CodingKey {
        case template = "templateName"
        case defaultLocaleIdentifier = "defaultLocale"
        case config
        case localization = "localizedStrings"
        case assetBaseURL = "assetBaseUrl"
    }

}

// MARK: - Equatable

extension PaywallData.LocalizedConfiguration: Equatable {}
extension PaywallData.Configuration: Equatable {}
extension PaywallData: Equatable {}

// MARK: - Sendable

extension PaywallData.LocalizedConfiguration: Sendable {}
extension PaywallData.Configuration: Sendable {}

#if swift(>=5.7)
extension PaywallData: Sendable {}
#else
// `@unchecked` because:
// - `URL` is not `Sendable` until Swift 5.7
extension PaywallData: @unchecked Sendable {}
#endif
