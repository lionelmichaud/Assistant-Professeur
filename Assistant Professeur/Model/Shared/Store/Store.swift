//
//  File.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 15/12/2023.
//

import Collections
import HelpersView
import OSLog
import StoreKit
import SwiftUI

private let logger = Logger(
    subsystem: "com.michaud.lionel.Assistant-Professeur",
    category: "Store"
)

typealias Transaction = StoreKit.Transaction
typealias RenewalInfo = StoreKit.Product.SubscriptionInfo.RenewalInfo
typealias RenewalState = StoreKit.Product.SubscriptionInfo.RenewalState

public enum StoreError: Error {
    case failedVerification
}

/// Attributs d'un Product du Store tel que défini dans une PList du Bundle
struct NcProductAttributes: Codable {
    var iconName: String
    var rank: Int
}

@Observable
public final class Store {
    private(set) var nonConsumables: [Product]
    private(set) var subscriptions: [Product]
    private(set) var nonRenewables: [Product]

    private(set) var purchasedNonConsumables: [Product] = []
    private(set) var purchasedNonRenewableSubscriptions: [Product] = []
    private(set) var purchasedSubscriptions: [Product] = []
    private(set) var subscriptionGroupStatus: RenewalState?

    private var updateListenerTask: Task<Void, Error>?

    private let productIdToAttributes: OrderedDictionary<String, NcProductAttributes>

    var allProductsIds: [String] {
        Array(productIdToAttributes.keys)
    }

    /// Le produit minimum sans option
    var baseProduct: Product? {
        nonConsumables.first
    }

    /// Le produit maximum toutes options
    var fullProduct: Product? {
        guard let baseProduct,
              !purchasedNonConsumables.contains(baseProduct) else {
            return nil
        }
        return nonConsumables.last
    }

    /// Le produit maximum toutes options
    var optionProducts: [Product] {
        if nonConsumables.count >= 2 {
            Array(nonConsumables[(nonConsumables.startIndex+1)...(nonConsumables.endIndex-2)])
        } else {
            []
        }
    }

    // MARK: - Initializer / Deinitializer

    init() {
        productIdToAttributes = Store.loadProductIdToEmojiData()

        // Initialize empty products, and then do a product request asynchronously to fill them in.
        nonConsumables = []
        subscriptions = []
        nonRenewables = []

        // Start a transaction listener as close to app launch as possible
        // so you don't miss any transactions.
        updateListenerTask = listenForTransactionUpdates()

        Task {
            // Check if we have any unfinished transactions where we
            // need to grant access to content
            await checkForUnfinishedTransactions()

            // During store initialization, request products from the App Store.
            await requestProducts()

            // Deliver products that the customer purchases.
            await updateCustomerProductStatus()
        }
    }

    deinit {
        updateListenerTask?.cancel()
    }

    // MARK: - Methods

    /// Charge les attributs de tous les Products du Store tels que définis dans la PList "Products.plist" du Bundle.
    static func loadProductIdToEmojiData() -> OrderedDictionary<String, NcProductAttributes> {
        guard let path = Bundle.main.path(forResource: "Products", ofType: "plist"),
              let plistData = FileManager.default.contents(atPath: path),
              // let data = try? PropertyListSerialization.propertyList(from: plistData, format: nil) as? [String: NcProduct] else {
              let dico = try? PropertyListDecoder().decode([String: NcProductAttributes].self, from: plistData) else {
            return [:]
        }
        var ordredDico = OrderedDictionary<String, NcProductAttributes>(
            uniqueKeys: dico.keys,
            values: dico.values
        )
        ordredDico.sort(by: { $0.value.rank < $1.value.rank })
        return ordredDico
    }

    /// Start a transaction listener as close to app launch as possible
    /// so you don't miss any transactions.
    func listenForTransactionUpdates() -> Task<Void, Error> {
        return Task.detached {
            logger.debug("Observing transaction updates")
            // Iterate through any transactions that don't come from a direct call to `purchase()`.
            for await result in Transaction.updates {
                do {
                    do {
                        let unsafeTransaction = result.unsafePayloadValue
                        logger.info("""
                        Processing transaction ID \(unsafeTransaction.id) for \
                        \(unsafeTransaction.productID)
                        """)
                    }
                    let transaction = try self.checkVerified(result)

                    // Deliver products to the user.
                    await self.updateCustomerProductStatus()

                    // Always finish a transaction.
                    await transaction.finish()
                } catch {
                    // StoreKit has a transaction that fails verification. Don't deliver content to the user.
                    logger.info("Transaction failed verification")
                }
            }
        }
    }

    /// Check if we have any unfinished transactions where we
    /// need to grant access to content
    func checkForUnfinishedTransactions() async {
        logger.debug("Checking for unfinished transactions")
        for await result in Transaction.unfinished {
            let unsafeTransaction = result.unsafePayloadValue
            logger.info("""
            Processing unfinished transaction ID \(unsafeTransaction.id) for \
            \(unsafeTransaction.productID)
            """)
            Task.detached(priority: .background) {
                // Deliver products to the user.
                await self.updateCustomerProductStatus()
            }
        }
        logger.debug("Finished checking for unfinished transactions")
    }

    /// Request registred products from the App Store.
    @MainActor
    func requestProducts() async {
        do {
            // Request products from the App Store using the identifiers that the Products.plist file defines.
            let storeProducts = try await Product.products(for: productIdToAttributes.keys)

            var newNonConsumables: [Product] = []
            var newSubscriptions: [Product] = []
            var newNonRenewables: [Product] = []

            // Filter the products into categories based on their type.
            for product in storeProducts {
                switch product.type {
                    case .consumable:
                        break
                    case .nonConsumable:
                        newNonConsumables.append(product)
                    case .autoRenewable:
                        newSubscriptions.append(product)
                    case .nonRenewable:
                        newNonRenewables.append(product)
                    default:
                        // Ignore this product.
                        logger.error("Unknown product type \(product.type.rawValue)")
                }
            }

            // Sort each product category by price, lowest to highest, to update the store.
            nonConsumables = sortByRank(newNonConsumables)
            subscriptions = sortByPrice(newSubscriptions)
            nonRenewables = sortByPrice(newNonRenewables)
        } catch {
            logger.error("Failed product request from the App Store server: \(error)")
        }
    }

    func purchase(_ product: Product) async throws -> Transaction? {
        // Begin purchasing the `Product` the user selects.
        let result = try await product.purchase()

        switch result {
            case let .success(verification):
                /// Check whether the transaction is verified. If it isn't,
                /// this function rethrows the verification error.
                let transaction = try checkVerified(verification)

                // The transaction is verified. Deliver content to the user.
                await updateCustomerProductStatus()

                // Always finish a transaction.
                await transaction.finish()

                return transaction

            case .userCancelled, .pending:
                return nil

            default:
                return nil
        }
    }

    /// Determines whether some non-consumable product has been purchased.
    func somePurchased() -> Bool {
        purchasedNonConsumables.isNotEmpty
    }

    /// Check if the transaction is authentic
    func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        // Check whether the JWS passes StoreKit verification.
        switch result {
            case .unverified:
                // StoreKit parses the JWS, but it fails verification.
                throw StoreError.failedVerification
            case let .verified(safe):
                // The result is verified. Return the unwrapped value.
                return safe
        }
    }

    /// Deliver products that the customer purchases.
    @MainActor
    func updateCustomerProductStatus() async {
        var purchasedNonConsumables: [Product] = []
        var purchasedSubscriptions: [Product] = []
        var purchasedNonRenewableSubscriptions: [Product] = []

        // Iterate through all of the user's purchased products.
        for await result in Transaction.currentEntitlements {
            do {
                // Check whether the transaction is verified. If it isn’t, catch `failedVerification` error.
                let transaction = try checkVerified(result)

                // Check the `productType` of the transaction and get the corresponding product from the store.
                switch transaction.productType {
                    case .nonConsumable:
                        if let ncProduct = nonConsumables.first(where: { $0.id == transaction.productID }) {
                            purchasedNonConsumables.append(ncProduct)
                        }

                    case .nonRenewable:
                        if let nonRenewable = nonRenewables.first(where: { $0.id == transaction.productID }),
                           transaction.productID == "nonRenewing.standard" {
                            // Non-renewing subscriptions have no inherent expiration date, so they're always
                            // contained in `Transaction.currentEntitlements` after the user purchases them.
                            // This app defines this non-renewing subscription's expiration date to be one year after purchase.
                            // If the current date is within one year of the `purchaseDate`, the user is still entitled to this
                            // product.
                            let currentDate = Date()
                            let expirationDate = Calendar(identifier: .gregorian).date(
                                byAdding: DateComponents(year: 1),
                                to: transaction.purchaseDate
                            )!

                            if currentDate < expirationDate {
                                purchasedNonRenewableSubscriptions.append(nonRenewable)
                            }
                        }

                    case .autoRenewable:
                        if let subscription = subscriptions.first(where: { $0.id == transaction.productID }) {
                            purchasedSubscriptions.append(subscription)
                        }

                    default:
                        break
                }
            } catch {
                // StoreKit has a transaction that fails verification. Don't deliver content to the user.
                logger.info("Transaction failed verification")
            }
        }

        // Update the store information with the purchased products.
        self.purchasedNonConsumables = purchasedNonConsumables
        self.purchasedNonRenewableSubscriptions = purchasedNonRenewableSubscriptions

        // Update the store information with auto-renewable subscription products.
        self.purchasedSubscriptions = purchasedSubscriptions

        // Check the `subscriptionGroupStatus` to learn the auto-renewable subscription state to determine whether the customer
        // is new (never subscribed), active, or inactive (expired subscription). This app has only one subscription
        // group, so products in the subscriptions array all belong to the same group. The statuses that
        // `product.subscription.status` returns apply to the entire subscription group.
        subscriptionGroupStatus = try? await subscriptions.first?.subscription?.status.first?.state
    }
}

// MARK: - Product's attributes

extension Store {
    /// Determines whether the user purchases a given product.
    func isPurchased(_ product: Product) -> Bool {
        switch product.type {
            case .nonConsumable:
                return purchasedNonConsumables.contains(product)
            case .nonRenewable:
                return purchasedNonRenewableSubscriptions.contains(product)
            case .autoRenewable:
                return purchasedSubscriptions.contains(product)
            default:
                return false
        }
    }

    func iconeName(for productId: String) -> String {
        productIdToAttributes[productId]!.iconName
    }

    func isPurchasable(_ product: Product) -> Bool {
        if product == nonConsumables.first { return true }
        if product == nonConsumables.last { return true }
        for idx in (nonConsumables.startIndex+1)...(nonConsumables.endIndex-2) {
            if nonConsumables[idx] == product &&
                isPurchased(nonConsumables[idx-1]) {
                return true
            }
        }
        return false
    }

    @ViewBuilder
    func icone(for product: Product) -> some View {
        if isPurchased(product) {
            ProductIcone(systemName: "lock.open")
                .foregroundStyle(.green)
        } else {
            ProductIcone(systemName: iconeName(for: product.id))
        }
    }

    func sortByRank(_ products: [Product]) -> [Product] {
        products.sorted(by: {
            if let left = productIdToAttributes[$0.id]?.rank,
               let right = productIdToAttributes[$1.id]?.rank {
                return left < right
            } else {
                return true
            }
        })
    }

    func sortByPrice(_ products: [Product]) -> [Product] {
        products.sorted(by: { $0.price < $1.price })
    }
}
