//
//  CloudKitViewModel.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 29/01/2023.
//

import AppFoundation
import CloudKit
import Foundation

class CloudKitViewModel: ObservableObject {
    /// True si l'utilisateur est connceté à iCloud
    @Published
    var isSignedInToicloud: Bool = false

    /// `nil` si aucune erreur; sinon retourne l'erreur
    @Published
    var iCloudError: ICloudError?

    init() {
        Task(priority: .medium) {
            #if DEBUG
                print(">> CloudKitViewModel() initialization has started")
            #endif
            await getiCloudStatus()
            #if DEBUG
                print(">> CloudKitViewModel() initialization has completed")
            #endif
        }
    }

    /// Détermine le status iCloud et consigne le status et l'erreur éventuelle
    @MainActor
    private func getiCloudStatus() async {
        let accountStatus = try? await CKContainer.default().accountStatus()

        switch accountStatus {
            case .none, .couldNotDetermine:
                self.iCloudError = .couldNotDetermine

            case .available:
                self.isSignedInToicloud = true
                return

            case .restricted:
                self.iCloudError = .restricted

            case .noAccount:
                self.iCloudError = .noAccount

            case .temporarilyUnavailable:
                self.iCloudError = .temporarilyUnavailable

            @unknown default:
                self.iCloudError = .unknown
        }
        self.isSignedInToicloud = false
    }
}
