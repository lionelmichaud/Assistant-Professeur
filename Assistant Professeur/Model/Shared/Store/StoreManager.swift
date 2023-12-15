////
////  StoreManager.swift
////  Assistant Professeur
////
////  Created by Lionel MICHAUD on 14/12/2023.
////
//
//import Foundation
//import OSLog
//import StoreKit
//
//actor StoreManager {
//    private let logger = Logger(
//        subsystem: "com.michaud.lionel.Assistant-Professeur",
//        category: "StoreManager"
//    )
//
//    private var updatesTask: Task<Void, Never>?
//
//    private(set) static var shared = StoreManager()
//
//    init() {
//        StoreManager.shared = StoreManager()
//    }
//
//    func process(transaction verificationResult: VerificationResult<Transaction>) async {
//        do {
//            let unsafeTransaction = verificationResult.unsafePayloadValue
//            logger.log("""
//            Processing transaction ID \(unsafeTransaction.id) for \
//            \(unsafeTransaction.productID)
//            """)
//        }
//
//        let transaction: Transaction
//        switch verificationResult {
//            case let .verified(t):
//                logger.debug("""
//                Transaction ID \(t.id) for \(t.productID) is verified
//                """)
//                transaction = t
//            case let .unverified(t, error):
//                // Log failure and ignore unverified transactions
//                logger.error("""
//                Transaction ID \(t.id) for \(t.productID) is unverified: \(error)
//                """)
//                return
//        }
//
//        // We only need to handle consumables here. We will check the
//        // subscription status each time before unlocking a premium subscription
//        // feature.
//        if case .consumable = transaction.productType {
//            // The safest practice here is to send the transaction to your
//            // server to validate the JWS and keep a ledger of the bird food
//            // each account is entitled to. Since this is just a demonstration,
//            // we are going to rely on StoreKit's automatic validation and
//            // use SwiftData to keep a ledger of the bird food.
//
//            guard let (birdFood, product) = birdFood(for: transaction.productID) else {
//                logger.fault("""
//                Attempting to grant access to \(transaction.productID) for \
//                transaction ID \(transaction.id) but failed to query for
//                corresponding bird food model.
//                """)
//                return
//            }
//
//            let delta = product.quantity * transaction.purchasedQuantity
//
//            if transaction.revocationDate == nil, transaction.revocationReason == nil {
//                // SwiftData crashes when we do this, so we'll save this for later
//                //                if birdFood.finishedTransactions.contains(transaction.id) {
//                //                    logger.log("""
//                //                    Ignoring unrevoked transaction ID \(transaction.id) for \
//                //                    \(transaction.productID) because we have already added \
//                //                    \(birdFood.id) for the transaction.
//                //                    """)
//                //                    return
//                //                }
//
//                // This doesn't appear to actually be updating the model
//                birdFood.ownedQuantity += delta
//                //                birdFood.finishedTransactions.insert(transaction.id)
//
//                logger.log("""
//                Added \(delta) \(birdFood.id)(s) from transaction ID \
//                \(transaction.id). New total quantity: \(birdFood.ownedQuantity)
//                """)
//
//                // Finish the transaction after granting the user content
//                await transaction.finish()
//
//                logger.debug("""
//                Finished transaction ID \(transaction.id) for \
//                \(transaction.productID)
//                """)
//            } else {
//                birdFood.ownedQuantity -= delta
//
//                logger.log("""
//                Removed \(delta) \(birdFood.id)(s) because transaction ID \
//                \(transaction.id) was revoked due to \
//                \(transaction.revocationReason?.localizedDescription ?? "unknown"). \
//                New total quantity: \(birdFood.ownedQuantity).
//                """)
//            }
//        } else {
//            // We can just finish the transction since we will grant access to
//            // the subscription based on the subscription status.
//            await transaction.finish()
//        }
//
////        do {
////            try modelContext.save()
////        } catch {
////            logger.error("Could not save model context: \(error.localizedDescription)")
////        }
//    }
//
//    func checkForUnfinishedTransactions() async {
//        logger.debug("Checking for unfinished transactions")
//        for await transaction in Transaction.unfinished {
//            let unsafeTransaction = transaction.unsafePayloadValue
//            logger.log("""
//            Processing unfinished transaction ID \(unsafeTransaction.id) for \
//            \(unsafeTransaction.productID)
//            """)
//            Task.detached(priority: .background) {
//                await self.process(transaction: transaction)
//            }
//        }
//        logger.debug("Finished checking for unfinished transactions")
//    }
//
//    func observeTransactionUpdates() {
//        self.updatesTask = Task { [weak self] in
//            self?.logger.debug("Observing transaction updates")
//            for await update in Transaction.updates {
//                guard let self else {
//                    break
//                }
//                await self.process(transaction: update)
//            }
//        }
//    }
//
////    private func birdFood(for productID: Product.ID) -> (BirdFood, BirdFood.Product)? {
////        try? modelContext.fetch(FetchDescriptor<BirdFood>()).birdFood(for: productID)
////    }
//}
