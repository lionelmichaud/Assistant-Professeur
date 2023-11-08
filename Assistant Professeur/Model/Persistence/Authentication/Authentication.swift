//
//  Authentication.swift
//  MySecureApp
//
//  Created by Stewart Lynch on 2021-05-29.
//

import AuthenticationServices
import LocalAuthentication
import SwiftUI

@MainActor
class Authentication: ObservableObject {
    @Published
    private(set) var isValidated = false

    @Published
    private(set) var isAuthorizedUser = false

    @Published
    private(set) var userCredentials: Credentials?

    enum BiometricType {
        case none
        case face
        case touch
    }

    enum AuthenticationError: Error, LocalizedError, Identifiable {
        case invalidCredentials
        case deniedAccess
        case noFaceIdEnrolled
        case noFingerprintEnrolled
        case biometrictError
        case credentialsNotSaved

        var id: String {
            self.localizedDescription
        }

        var errorDescription: String? {
            switch self {
                case .invalidCredentials:
                    return NSLocalizedString("Either your email or password are incorrect. Please try again.", comment: "")
                case .deniedAccess:
                    return NSLocalizedString("You have denied access. Please go to the settings app and locate this application and turn Face ID on.", comment: "")
                case .noFaceIdEnrolled:
                    return NSLocalizedString("You have not registered any Face Ids yet", comment: "")
                case .noFingerprintEnrolled:
                    return NSLocalizedString("You have not registered any fingerprints yet.", comment: "")
                case .biometrictError:
                    return NSLocalizedString("Your face or fingerprint were not recognized.", comment: "")
                case .credentialsNotSaved:
                    return NSLocalizedString("Your credentials have not been saved. Do you want to save them after the next successful login?", comment: "")
            }
        }
    }

    /// Process the User Apple ID credential for the App to determine if the User is already authorized.
    func processUserCredentials() async {
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let credentialState = try? await appleIDProvider.credentialState(
            forUserID: KeychainItem.currentUserIdentifier
        )

        switch credentialState {
            case .authorized:
                // The Apple ID credential is valid.
                self.isAuthorizedUser = true

            case .revoked, .notFound:
                // The Apple ID credential is either revoked or was not found, so show the sign-in UI.
                self.isAuthorizedUser = false

            default:
                self.isAuthorizedUser = false
        }
    }

    func processAuthorization(authorization: ASAuthorization) {
        isValidated = true
        switch authorization.credential {
            case let appleIDCredential as ASAuthorizationAppleIDCredential:

                /// Create an account in your system.
                let userIdentifier = appleIDCredential.user
                let fullName = appleIDCredential.fullName
                let email = appleIDCredential.email

                // For the purpose of this demo app, show the Apple ID credential information.
                userCredentials =
                    Credentials(
                        userIdentifier: userIdentifier,
                        fullName: fullName,
                        email: email
                    )

                // For the purpose of this demo app, store the `userIdentifier` in the keychain.
                KeychainItem.saveUserIdentifierToKeychain(userIdentifier)

                if let fullName, let email {
                    // First loging (Signing up).
                    // Save this information to CloudKit
                } else {
                    // Returning user (signing in)
                    // Fetch the user name/ email address
                    // from private CloudKit
                }

            case let passwordCredential as ASPasswordCredential:

                /// Sign in using an existing iCloud Keychain credential.
                let username = passwordCredential.user
                let password = passwordCredential.password

                // For the purpose of this demo app, show the password credential.
                userCredentials =
                    Credentials(
                        userName: username,
                        password: password
                    )

            default:
                break
        }
    }

    func updateValidation(success: Bool) {
        withAnimation {
            isValidated = success
        }
    }

    func biometricType() -> BiometricType {
        let authContext = LAContext()
        let _ = authContext.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil)
        switch authContext.biometryType {
            case .none:
                return .none
            case .touchID:
                return .touch
            case .faceID:
                return .face
            @unknown default:
                return .none
        }
    }

//    func requestBiometricUnlock(completion: @escaping (Result<Credentials, AuthenticationError>) -> Void) {
//        let credentials:Credentials? = Credentials(email: "anything", password: "password")
//        let credentials:Credentials? = nil

//        let credentials = KeychainStorage.getCredentials()
//        guard let credentials = credentials else {
//            completion(.failure(.credentialsNotSaved))
//            return
//        }
//        let context = LAContext()
//        var error: NSError?
//        let canEvaluate = context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error)
//        if let error = error {
//            switch error.code {
//            case -6:
//                completion(.failure(.deniedAccess))
//            case -7:
//                if context.biometryType == .faceID {
//                    completion(.failure(.noFaceIdEnrolled))
//                } else {
//                    completion(.failure(.noFingerprintEnrolled))
//                }
//            default:
//                completion(.failure(.biometrictError))
//            }
//            return
//        }
//        if canEvaluate {
//            if context.biometryType != .none {
//                context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: "Need to access credentials.") { success, error in
//                    DispatchQueue.main.async {
//                        if error != nil {
//                            completion(.failure(.biometrictError))
//                        } else {
//                            completion(.success(credentials))
//                        }
//                    }
//                }
//            }
//        }
//    }
}
