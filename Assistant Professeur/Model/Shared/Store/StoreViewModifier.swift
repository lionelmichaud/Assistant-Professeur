//
//  StoreViewModifier.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 14/12/2023.
//

//import SwiftUI
//import OSLog
//
//private let logger = Logger(
//    subsystem: "com.michaud.lionel.Assistant-Professeur",
//    category: "StoreViewModifier"
//)
//
//struct StoreViewModifier: ViewModifier {
//    func body(content: Content) -> some View {
//        ZStack {
//            content
//        }
////        .onAppear {
////            logger.info("Creating BirdBrain shared instance")
////            BirdBrain.createSharedInstance()
////            logger.info("BirdBrain shared instance created")
////        }
//        .task {
//            logger.info("Starting tasks to observe transaction updates")
//            // Begin observing StoreKit transaction updates in case a
//            // transaction happens on another device.
//            await StoreManager.shared.observeTransactionUpdates()
//            // Check if we have any unfinished transactions where we
//            // need to grant access to content
//            await StoreManager.shared.checkForUnfinishedTransactions()
//            logger.info("Finished checking for unfinished transactions")
//        }
//    }
//}
//
//extension View {
//    func storeSetUp() -> some View {
//        modifier(StoreViewModifier())
//    }
//}
