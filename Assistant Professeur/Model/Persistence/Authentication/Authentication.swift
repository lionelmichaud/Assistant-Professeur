//
//  Authentication.swift
//  MySecureApp
//
//  Created by Stewart Lynch on 2021-05-29.
//

import AuthenticationServices
import LocalAuthentication
import os
import SwiftUI

private let customLog = Logger(
    subsystem: "com.michaud.lionel.Assistant-Professeur",
    category: "Authentication"
)

@Observable
final class Authentication {
    // MARK: - Properties

    /// L'utilisateur est authentifié par SignInWithApple ou pas
    @MainActor
    private(set) var userIsAuthenticatedByApple = false

    /// The User Apple ID credential is authorized or not.
    /// Si l'utilisateur est `Autorisé`il est forcément `Authentifié`.
    @MainActor
    private(set) var isAuthorizedUser = false

    @MainActor
    private(set) var userCredentials: Credentials?

    @MainActor
    private(set) var ownerAndPrefsExist = false

    // MARK: - Nested Types

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

    // MARK: - Methods

    /// Check the User Apple ID credential for the App, at start-up, to determine if the User is already authorized.
    /// Si oui, mettre à jour les context utilisateur.
    @MainActor
    func checkUserAppleIdCredentials(userContext: UserContext) async {
        // L'identifiant AppleID qui a été mémorisé au moment de la première authentification
        let userIdentifier = KeychainItem.currentUserIdentifier
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        // User Apple ID credential
        let credentialState = try? await appleIDProvider.credentialState(
            forUserID: userIdentifier
        )

        switch credentialState {
            case .authorized:
                // The Apple ID credential is authorized; so do NOT show the sign-in UI.
                //   Créer les Credential à partir des données iCloud du Owner.
                //   Mettre à jour les context utilisateur avec le Owner.
                setUserCredentialsFromiCloud_Signing_In(
                    userIdentifier: userIdentifier,
                    userContext: userContext
                )
                customLog.log(level: .info, ">> Apple ID credential: 'authorized' with Apple User ID = \(userIdentifier)")
                self.isAuthorizedUser = true

            case .revoked, .notFound, .transferred:
                // The Apple ID credential is either revoked (e.g. signed-out) or was not found, so show the sign-in UI.
                //  .notFound: The user hasn’t established a relationship with Sign in with Apple.
                //  .revoked: The given user’s authorization has been revoked and they should be signed out
                customLog.log(level: .info, ">> Apple ID credential = revoked ou notFound")
                self.isAuthorizedUser = false

            default:
                customLog.log(level: .info, ">> Apple ID credential = undefined")
                self.isAuthorizedUser = false
        }
    }

    /// Check if the User is authoriezd after sign-in.
    /// Si oui, mettre à jour les context utilisateur avec le Owner.
    @MainActor
    func checkAuthorization(
        authorization: ASAuthorization,
        userContext: UserContext
    ) {
        userIsAuthenticatedByApple = true
        switch authorization.credential {
            case let appleIDCredential as ASAuthorizationAppleIDCredential:
                // Connection par "Sign-In with Apple"

                /// Create an account in your system.
                let userIdentifier = appleIDCredential.user
                let fullName = appleIDCredential.fullName
                let email = appleIDCredential.email

                // For the purpose of this demo app, store the `userIdentifier` in the keychain.
                KeychainItem.saveUserIdentifierToKeychain(userIdentifier)

                if let fullName,
                   fullName.familyName != nil,
                   fullName.givenName != nil {
                    // First loging (Signing up).
                    //   Créer les Credential à partir des Credential Apple.
                    //   Mettre à jour les context utilisateur avec le Owner.
                    setUserCredentialsFromAppleIDCredential_Signing_Up(
                        userIdentifier: userIdentifier,
                        fullName: fullName,
                        email: email,
                        userContext: userContext
                    )
                    customLog.log(level: .info, "Signed-up with appleIDCredential. AppleUserID = \(userIdentifier)")

                } else {
                    // Returning user (signing in)
                    //   Créer les Credential à partir des données iCloud du Owner.
                    //   Mettre à jour les context utilisateur avec le Owner.
                    setUserCredentialsFromiCloud_Signing_In(
                        userIdentifier: userIdentifier,
                        userContext: userContext
                    )
                    customLog.log(level: .info, "Signed-in with appleIDCredential. AppleUserID = \(userIdentifier)")
                }

            case let passwordCredential as ASPasswordCredential:
                // Connection par "username / password"

                /// Sign in using an existing iCloud Keychain credential.
                let username = passwordCredential.user
                let password = passwordCredential.password

                // For the purpose of this demo app, show the password credential.
                userCredentials = Credentials(
                    userName: username,
                    password: password
                )
                customLog.log(level: .info, "Signed-in with passwordCredential. Username: \(username). Password: \(password)")

            default:
                break
        }
    }

    /// First loging (Signing up).
    /// Créer les Credential à partir des Credential Apple.
    /// Mettre à jour les context utilisateur avec le Owner.
    @MainActor
    private func setUserCredentialsFromAppleIDCredential_Signing_Up(
        userIdentifier: String,
        fullName: PersonNameComponents,
        email: String?,
        userContext: UserContext
    ) {
        // Save this information to CloudKit.
        // Créer un Owner s'il n'existe pas encore avec cet AppleID
        if let owner = OwnerEntity.byUserIdentifier(userIdentifier: userIdentifier) {
            // Connecter le Owner existant au UserContext
            userContext.setOwner(to: owner)
        } else {
            // Créer un Owner avec cet AppleID
            let newOwner = OwnerEntity.create(
                familyName: fullName.familyName!,
                givenName: fullName.givenName!,
                numen: "",
                userIdentifier: userIdentifier
            )
            userContext.setOwner(to: newOwner)
        }
        userCredentials = Credentials(
            userIdentifier: userIdentifier,
            fullName: fullName,
            email: email
        )
        ownerAndPrefsExist = userContext.isValid
    }

    /// Returning user (signing in)
    /// Créer les Credential à partir des données iCloud du Owner.
    /// Mettre à jour le context utilisateur avec le Owner.
    @MainActor
    private func setUserCredentialsFromiCloud_Signing_In(
        userIdentifier: String,
        userContext: UserContext
    ) {
        var fullName: PersonNameComponents?
        // Fetch the user data from private CloudKit
        if let owner = OwnerEntity.byUserIdentifier(userIdentifier: userIdentifier) {
            userContext.setOwner(to: owner)

            if let familyName = owner.familyName,
               let givenName = owner.givenName {
                fullName = PersonNameComponents(
                    givenName: givenName,
                    familyName: familyName
                )
            }

        } else {
            // La synchro iCloud n'a sans doute pas encore synchronisé les objets OwnerEntity et PrefEntity
            customLog.log(level: .error, ">> Utilisateur (Owner) supposé exister mais pas trouvé dans CoreData pour Apple User ID = \(userIdentifier)")
        }
        userCredentials = Credentials(
            userIdentifier: userIdentifier,
            fullName: fullName
        )
        ownerAndPrefsExist = userContext.isValid
    }

    @MainActor
    func updateValidation(success: Bool) {
        withAnimation {
            userIsAuthenticatedByApple = success
        }
    }

    /// Invalider les autorization et supprimer les credentials dans la KeyChain
    @MainActor
    func logOut() {
        updateValidation(success: false)
        updateAuthentication(isAuthorized: false)
        KeychainItem.deleteUserIdentifierFromKeychain()
    }

    @MainActor
    func updateAuthentication(isAuthorized: Bool) {
        withAnimation {
            isAuthorizedUser = isAuthorized
        }
    }

    @MainActor
    func biometricType() -> BiometricType {
        let authContext = LAContext()
        _ = authContext.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil)
        switch authContext.biometryType {
            case .none:
                return .none
            case .touchID:
                return .touch
            case .faceID:
                return .face
            case .opticID:
                return .none
            @unknown default:
                return .none
        }
    }
}
