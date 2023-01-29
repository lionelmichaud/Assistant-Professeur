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
    @Published
    var isSignedInToicloud: Bool = false

    @Published
    var iCloudError: ICloudError?

    @Published
    var permissionStatus: Bool = false

    @Published
    var userName: PersonNameComponents?

    init() {
        getiCloudStatus()
        requestPermission()
        fetchicloudUserRecordID()
    }

    /// Détermine le status iCloud et consigne le status et l'erreur éventuelle
    private func getiCloudStatus() {
        CKContainer.default().accountStatus { [weak self] accountStatus, _ in
            DispatchQueue.main.async { [weak self] in
                if accountStatus != .available {
                    switch accountStatus {
                    case .couldNotDetermine:
                        self?.iCloudError = .couldNotDetermine
                    case .available:
                        self?.isSignedInToicloud = true
                        return
                    case .restricted:
                        self?.iCloudError = .restricted
                    case .noAccount:
                        self?.iCloudError = .noAccount
                    case .temporarilyUnavailable:
                        self?.iCloudError = .temporarilyUnavailable
                    @unknown default:
                        self?.iCloudError = .unknown
                    }
                    self?.isSignedInToicloud = false
                }
            }
        }
    }

    private func requestPermission() {
        CKContainer.default().requestApplicationPermission([.userDiscoverability]) { [weak self] returnedStatus, _ in
            DispatchQueue.main.async {
                if returnedStatus == .granted {
                    self?.permissionStatus = true
                }
            }
        }
    }

    private func fetchicloudUserRecordID() {
        CKContainer.default().fetchUserRecordID { [weak self] returnedID, _ in
            if let id = returnedID {
                self?.discovericloudUser(id: id)
            }
        }
    }

    private func discovericloudUser(id: CKRecord.ID) {
        CKContainer.default().discoverUserIdentity(withUserRecordID: id) { [weak self] returnedIdentity, _ in
            DispatchQueue.main.async {
                if let name = returnedIdentity?.nameComponents {
                    self?.userName = name
                }
            }
        }
    }
}
