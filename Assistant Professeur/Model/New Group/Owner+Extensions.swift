//
//  Owner.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 03/05/2023.
//

import CoreData
import Foundation

extension OwnerEntity {
    /// Wrapper of `familyName`
    /// - Important: *Saves the context to the store after modification is done*
    @objc
    var viewFamilyName: String {
        get {
            self.familyName ?? ""
        }
        set {
            self.familyName = newValue.trimmed.uppercased()
            try? Self.saveIfContextHasChanged()
        }
    }

    /// Wrapper of `givenName`
    /// - Important: *Saves the context to the store after modification is done*
    @objc
    var viewGivenName: String {
        get {
            self.givenName ?? ""
        }
        set {
            self.givenName = newValue.trimmed
            try? Self.saveIfContextHasChanged()
        }
    }

    /// Wrapper of `annotation`
    /// - Important: *Saves the context to the store after modification is done*
    @objc
    var viewAnnotation: String {
        get {
            self.annotation ?? ""
        }
        set {
            self.annotation = newValue
            try? Self.saveIfContextHasChanged()
        }
    }

    /// Wrapper of `numen`
    /// - Important: *Saves the context to the store after modification is done*
    @objc
    var viewNumen: String {
        get {
            self.numen ?? ""
        }
        set {
            self.numen = newValue.trimmed
            try? Self.saveIfContextHasChanged()
        }
    }

    /// Wrapper of `mailAdressAcademy`
    /// - Important: *Saves the context to the store after modification is done*
    @objc
    var viewEmailAdressAcademy: String {
        get {
            self.mailAdressAcademy ?? ""
        }
        set {
            self.mailAdressAcademy = newValue.trimmed
            try? Self.saveIfContextHasChanged()
        }
    }

    /// Wrapper of `idMailAcademy`
    /// - Important: *Saves the context to the store after modification is done*
    @objc
    var viewIdMailAcademy: String {
        get {
            self.idMailAcademy ?? ""
        }
        set {
            self.idMailAcademy = newValue.trimmed
            try? Self.saveIfContextHasChanged()
        }
    }

    /// Wrapper of `pwdMailAcademy`
    /// - Important: *Saves the context to the store after modification is done*
    @objc
    var viewPwdMailAcademy: String {
        get {
            self.pwdMailAcademy ?? ""
        }
        set {
            self.pwdMailAcademy = newValue.trimmed
            try? Self.saveIfContextHasChanged()
        }
    }

    /// Wrapper of `userIdentifier`
    /// - Important: *Saves the context to the store after modification is done*
    @objc
    var viewUserIdentifier: String {
        get {
            self.userIdentifier ?? ""
        }
        set {
            self.userIdentifier = newValue.trimmed
            try? Self.saveIfContextHasChanged()
        }
    }

    var isIdentified: Bool {
        !viewUserIdentifier.isEmpty
    }
}

// MARK: - Extension Core Data

extension OwnerEntity {
    // MARK: - Methods

    override public func awakeFromInsert() {
        super.awakeFromInsert()
        // Set defaults here
        self.id = UUID()
    }

    static func byUserIdentifier(userIdentifier: String) -> Self? {
        all().first { object in
            object.userIdentifier == userIdentifier
        }
    }

    // MARK: - Type Methods

    /// Créer un utilisateur de l'appli **s'il n'en existe aucun**.
    /// - Important: Sauvegarder le Context.
    ///
    /// Sauvegarder le Context.
    /// - Parameters:
    ///   - familyName: Nom de famille
    ///   - givenName: Prénom
    ///   - numen: NUMEN
    ///   - mailAcademy: Adresse eMail académique
    ///   - urlMailAcademy: URL du webmail académique
    ///   - idMailAcademy: Idendifiant du compte eMail académique
    ///   - pwdMailAcademy: Mote de passe du compte eMail académique
    ///   - mailAddressSchool: Adresse eMail au sein de l'établissement
    ///   - urlMailSchool: URL du webmail au sein de l'établissement
    ///   - idMailSchool: Idendifiant du compte eMail au sein de l'établissement
    ///   - pwdMailSchool: Mote de passe du compte eMail au sein de l'établissement
    /// - Returns: Retourne `nil` s'il existe déjà un utilisateur de l'appli.
    @discardableResult
    static func create(
        familyName: String,
        givenName: String,
        numen: String,
        userIdentifier: String,
        mailAdressAcademy: String = "",
        urlMailAcademy: URL? = nil,
        idMailAcademy: String = "",
        pwdMailAcademy: String = ""
    ) -> OwnerEntity? {
        guard Self.cardinal() == 0 else {
            return nil
        }
        let owner = Self.create()
        owner.familyName = familyName
        owner.givenName = givenName
        owner.numen = numen
        owner.userIdentifier = userIdentifier

        // Créer les préférences utilisateurs
        let userPrefs = UserPrefEntity.created()
        owner.prefs = userPrefs

        owner.mailAdressAcademy = mailAdressAcademy
        owner.urlMailAcademy = urlMailAcademy
        owner.idMailAcademy = idMailAcademy
        owner.pwdMailAcademy = pwdMailAcademy

        try? Self.saveIfContextHasChanged()

        return owner
    }

    /// Check the correctness and consistency of all database entities of this type.
    /// - Parameters:
    ///   - errorList: Liste des erreurs trouvées.
    static func checkConsistency(
        errorList: inout DataBaseErrorList,
        tryToRepair: Bool
    ) {
        func checkAndRepair(owner: OwnerEntity) {
            if !owner.isIdentified {
                // Objet Owner non identifié
                if tryToRepair && KeychainItem.currentUserIdentifier.isNotEmpty {
                    // Utilisateur identifié
                    owner.userIdentifier = KeychainItem.currentUserIdentifier
                }
                // Utilisateur non identifié
                errorList.append(
                    DataBaseError.outOfBound(
                        entity: Self.entity().name!,
                        name: "Utilisateur non identifié",
                        attribute: "userIdentifier",
                        id: nil
                    ))
            }

            if owner.prefs == nil {
                // Objet Owner sans préférences
                if tryToRepair {
                    if OwnerEntity.cardinal() == 1 && UserPrefEntity.cardinal() == 1 {
                        // Il existe des préférences utilisateurs orphelines
                        owner.prefs = UserPrefEntity.all().first

                    } else {
                        // Créer les préférences utilisateurs
                        let userPrefs = UserPrefEntity.created()
                        owner.prefs = userPrefs
                    }
                }
                if owner.prefs == nil {
                    errorList.append(
                        DataBaseError.some(
                            entity: Self.entity().name!,
                            name: "Préférences absentes (UserPrefEntity)",
                            id: owner.id
                        ))
                }
            }
        }

        switch cardinal() {
            case 0:
                if tryToRepair && KeychainItem.currentUserIdentifier.isNotEmpty {
                    create(
                        familyName: "Nom",
                        givenName: "Prénom",
                        numen: "numen",
                        userIdentifier: KeychainItem.currentUserIdentifier
                    )
                }
                if cardinal() == 0 {
                    errorList.append(
                        DataBaseError.some(
                            entity: Self.entity().name!,
                            name: "fichier inexistant et devrait exister",
                            id: nil
                        ))
                }

            case 1:
                let uniqueOwner = all().first!
                checkAndRepair(owner: uniqueOwner)

            case 2...:
                all().forEach { owner in
                    checkAndRepair(owner: owner)
                }

            default:
                break
        }
    }
}

// MARK: - Extension Debug

public extension OwnerEntity {
    override var description: String {
        """

        OWNER:
           ID            : \(String(describing: id))
           Apple USer ID : \(String(describing: userIdentifier))
           Nom           : \(viewGivenName) \(viewFamilyName)
           NUMEN         : \(viewNumen)

           eMail académique : \(viewEmailAdressAcademy)
           URL webmail : \(String(describing: urlMailAcademy?.absoluteString))
           Identifiant : \(viewIdMailAcademy)
           Mot de passe: \(viewPwdMailAcademy)
        """
    }
}
