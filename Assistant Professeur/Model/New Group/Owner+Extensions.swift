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
            try? OwnerEntity.saveIfContextHasChanged()
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
            try? OwnerEntity.saveIfContextHasChanged()
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
            try? OwnerEntity.saveIfContextHasChanged()
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
            try? OwnerEntity.saveIfContextHasChanged()
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
            try? OwnerEntity.saveIfContextHasChanged()
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
            try? OwnerEntity.saveIfContextHasChanged()
        }
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

    // MARK: - Type Methods

    /// Créer le record unique de l'utilisateur de l'appli s'il n'existe pas encore.
    static func initializeEntity(userName: PersonNameComponents?) {
        // créer le record unique de l'utilisateur de l'appli s'il n'existe pas encore
        create(
            familyName: userName?.familyName ?? "",
            givenName: userName?.givenName ?? "",
            numen: ""
        )
    }

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
        familyName        : String,
        givenName         : String,
        numen             : String,
        mailAdressAcademy : String = "",
        urlMailAcademy    : URL?   = nil,
        idMailAcademy     : String = "",
        pwdMailAcademy    : String = ""
    ) -> OwnerEntity? {
        guard OwnerEntity.cardinal() == 0 else {
            return nil
        }
        let owner = OwnerEntity.create()
        owner.familyName        = familyName
        owner.givenName         = givenName
        owner.numen             = numen

        owner.mailAdressAcademy = mailAdressAcademy
        owner.urlMailAcademy    = urlMailAcademy
        owner.idMailAcademy     = idMailAcademy
        owner.pwdMailAcademy    = pwdMailAcademy

        try? OwnerEntity.saveIfContextHasChanged()

        return owner
    }

    /// Check the correctness and consistency of all database entities of this type.
    /// - Parameters:
    ///   - errorList: Liste des erreurs trouvées.
    static func checkConsistency(
        errorList: inout DataBaseErrorList,
        tryToRepair: Bool
    ) {
        if cardinal() == 0 {
            if tryToRepair {
                create(
                    familyName: "",
                    givenName: "",
                    numen: ""
                )
            }
            if cardinal() == 0 {
                errorList.append(DataBaseError.some(
                    entity: Self.entity().name!,
                    name: "fichier inexistant et devrait exister",
                    id: nil
                ))
            }
        } else if cardinal() > 1 {
            if tryToRepair {
                let nbItemsToRemove = cardinal() - 1
                var allItems = all()
                for _ in 1 ... nbItemsToRemove {
                    if let lastItem = allItems.popLast() {
                        try? lastItem.delete()
                    }
                }
            }
            if cardinal() > 1 {
                errorList.append(DataBaseError.some(
                    entity: Self.entity().name!,
                    name: "plusieurs fichiers propriétaire ont été trouvés",
                    id: nil
                ))
            }
        }
    }
}

// MARK: - Extension Debug

public extension OwnerEntity {
    override var description: String {
        """

        OWNER:
           ID    : \(String(describing: id))
           Nom   : \(viewGivenName) \(viewFamilyName)
           NUMEN : \(viewNumen)

           eMail académique : \(viewEmailAdressAcademy)
           URL webmail : \(String(describing: urlMailAcademy?.absoluteString))
           Identifiant : \(viewIdMailAcademy)
           Mot de passe: \(viewPwdMailAcademy)
        """
    }
}
