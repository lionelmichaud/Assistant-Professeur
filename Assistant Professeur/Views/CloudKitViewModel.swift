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
    /// True si l'utilisateur est connecté à iCloud
    @Published
    var isSignedInToicloud: Bool = false

    /// `nil` si aucune erreur; sinon retourne l'erreur
    @Published
    //var iCloudError: ICloudError?
    var iCloudError: Error?

    init() {
        Task(priority: .high) {
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
        do {
            let accountStatus = try await CKContainer.default().accountStatus()

            switch accountStatus {
                case .couldNotDetermine:
                    self.iCloudError = ICloudError.couldNotDetermine

                case .available:
                    // Succès
                    self.isSignedInToicloud = true
                    return

                case .restricted:
                    self.iCloudError = ICloudError.restricted

                case .noAccount:
                    self.iCloudError = ICloudError.noAccount

                case .temporarilyUnavailable:
                    self.iCloudError = ICloudError.temporarilyUnavailable

                @unknown default:
                    self.iCloudError = ICloudError.unknown
            }
            // Echec
            self.isSignedInToicloud = false

        } catch {
            self.iCloudError = ICloudError.couldNotDetermine
            self.isSignedInToicloud = false
        }
    }
}
