//
//  Copyright RevenueCat Inc. All Rights Reserved.
//
//  Licensed under the MIT License (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//      https://opensource.org/licenses/MIT
//
//  BackendConfiguration.swift
//
//  Created by Joshua Liebowitz on 6/13/22.

import Foundation

class BackendConfiguration {

    let httpClient: HTTPClient

    let operationDispatcher: OperationDispatcher
    let operationQueue: OperationQueue
    let dateProvider: DateProvider
    let systemInfo: SystemInfo

    private let productEntitlementMappingFetcher: ProductEntitlementMappingFetcher
    private let purchasedProductsFetcher: PurchasedProductsFetcherType

    init(httpClient: HTTPClient,
         operationDispatcher: OperationDispatcher,
         operationQueue: OperationQueue,
         systemInfo: SystemInfo,
         productEntitlementMappingFetcher: ProductEntitlementMappingFetcher,
         purchasedProductsFetcher: PurchasedProductsFetcherType,
         dateProvider: DateProvider = DateProvider()) {
        self.httpClient = httpClient
        self.operationDispatcher = operationDispatcher
        self.operationQueue = operationQueue
        self.productEntitlementMappingFetcher = productEntitlementMappingFetcher
        self.purchasedProductsFetcher = purchasedProductsFetcher
        self.dateProvider = dateProvider
        self.systemInfo = systemInfo
    }

    func clearCache() {
        self.httpClient.clearCaches()
    }

    func createOfflineCustomerInfoCreator() -> OfflineCustomerInfoCreator {
        return .init(purchasedProductsFetcher: self.purchasedProductsFetcher,
                     productEntitlementMapping: self.productEntitlementMappingFetcher.productEntitlementMapping)
    }

}

extension BackendConfiguration: NetworkConfiguration {}

extension BackendConfiguration {

    /// Adds the `operation` to the `OperationQueue` (based on `CallbackCacheStatus`) potentially adding a random delay.
    func addCacheableOperation<T: CacheableNetworkOperation>(
        with factory: CacheableNetworkOperationFactory<T>,
        withRandomDelay randomDelay: Bool,
        cacheStatus: CallbackCacheStatus
    ) {
        self.operationDispatcher.dispatchOnWorkerThread(withRandomDelay: randomDelay) {
            self.operationQueue.addCacheableOperation(with: factory, cacheStatus: cacheStatus)
        }
    }

}

// @unchecked because:
// - `OperationQueue` is not `Sendable` as of Swift 5.7
// - Class is not `final` (it's mocked). This implicitly makes subclasses `Sendable` even if they're not thread-safe.
extension BackendConfiguration: @unchecked Sendable {}
