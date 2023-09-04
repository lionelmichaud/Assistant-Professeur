//
//  ContactsManager.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 10/05/2023.
//

import Contacts
import Foundation
import os

private let customLog = Logger(
    subsystem: "com.michaud.lionel.Assistant-Professeur",
    category: "ContactManager"
)

/// Gestionnaire de Contacts. Synchronize l'appli avec l'app Contacts.
struct ContactManager {
    enum SortOrder {
        case byJobTitle
        case byName
    }

    // MARK: - SINGLETON

    static var shared = ContactManager()

    // MARK: - Initializer

    private init() {}

    // MARK: - Properties

    private var autorizationStatus: CNAuthorizationStatus?

    /// True si l'accès à déjà été demandé à l'utilisateur
    var isAccessChecked: Bool {
        autorizationStatus != nil
    }

    var isAccessAuthorized: Bool {
        autorizationStatus == .authorized
    }

    // MARK: - Methods

    mutating func requestContactsAccess(
        contactStore: CNContactStore,
        groupName: String
    ) async -> (
        contactGroup: CNGroup?,
        alertIsPresented: Bool,
        alertTitle: String,
        alertMessage: String
    ) {
        do {
            if try await contactStore.requestAccess(for: .contacts) {
                // Succès
                self.autorizationStatus = CNContactStore.authorizationStatus(for: .contacts)
                let (
                    group,
                    alertIsPresented,
                    alertTitle,
                    alertMessage
                ) = getOrCreateGroup(
                    named: groupName,
                    inContactStore: contactStore
                )
                if let group {
                    // Succès
                    return (group, false, "", "")
                } else {
                    return (
                        contactGroup: nil,
                        alertIsPresented: alertIsPresented,
                        alertTitle: alertTitle,
                        alertMessage: alertMessage
                    )
                }

            } else if isAccessChecked {
                // Echec déjà signalé
                return (nil, false, "", "")

            } else {
                // Echec jamais signalé
                let authorizationStatus = CNContactStore.authorizationStatus(for: .contacts)
                self.autorizationStatus = authorizationStatus
                var reason = ""
                switch authorizationStatus {
                    case .notDetermined:
                        reason = "indéfinie"
                    case .restricted:
                        reason = "accès restreint"
                    case .denied:
                        reason = "accès refusé"
                    case .authorized:
                        reason = "accès autorisé"
                    @unknown default:
                        reason = "inconnue"
                }
                let alertTitle: String = "Accès au Contacts non autorisé: raison \(reason)"
                customLog.log(level: .error, "\(alertTitle, privacy: .public)")
                return (
                    contactGroup: nil,
                    alertIsPresented: true,
                    alertTitle: alertTitle,
                    alertMessage: "The app doesn't have permission to access Contacts data. Please grant the app access to Contacts in Settings."
                )
            }

        } catch {
            if !isAccessChecked {
                customLog.log(
                    level: .error,
                    "Echec de la demande d'accès aux Contacts: \(error.localizedDescription)"
                )
                self.autorizationStatus = CNContactStore.authorizationStatus(for: .contacts)
                return (
                    contactGroup: nil,
                    alertIsPresented: true,
                    alertTitle: "Echec de la demande d'accès au Contacts",
                    alertMessage: error.localizedDescription
                )
            } else {
                // Echec déjà signalé
                return (nil, false, "", "")
            }
        }
    }

    /// Retourne le contact de type .organization dont le nom d'organisation est `organizationName`
    /// se trouvant dans le Groupe de contacts nommé `organizationName`.
    /// - Parameter organizationName: Nom de l'organisation recherchée
    /// - Returns: nil si le contact de l'organisation n'est pas trouvé.
    func organizationContact(
        inContactGroup group: CNGroup,
        inContactStore contactStore: CNContactStore,
        withOrganizationName organizationName: String
    ) throws -> CNContact? {
        let predicate =
            CNContact
                .predicateForContactsInGroup(withIdentifier: group.identifier)
        let matchingContacts =
            try contactStore.unifiedContacts(
                matching: predicate,
                keysToFetch: ContactEnum.organization().keysToFetch
            )

        return matchingContacts.first(where: {
            $0.contactType == .organization && $0.organizationName == organizationName
        })
    }

    /// Retourne un contact de personne inclu dans le groupe de contact nommé `organizationName`.
    /// - Parameters:
    ///  - organizationName: Nom du groupe de contacts dans lequel recherchés les contacts.
    ///  - givenName: prénom du contact
    ///  - familyName: nom du contact
    func personContact(
        givenName: String,
        familyName: String,
        inContactStore contactStore: CNContactStore
    ) throws -> CNContact? {
        let predicate =
            CNContact
                .predicateForContacts(matchingName: "\(givenName) \(familyName)")
        let matchingContacts =
            try contactStore.unifiedContacts(
                matching: predicate,
                keysToFetch: ContactEnum.person().keysToFetch
            )

        return matchingContacts.first
    }

    /// Retourne tous les contacts de personnes inclus dans le groupe de contact nommé `organizationName`.
    /// - Parameters:
    ///  -  organizationName: Nom du groupe de contacts dans lequel recherchés les contacts.
    ///  - sortedBy: Ordre de tri.
    func allPersonContacts(
        inOrganizationName _: String,
        inContactGroup group: CNGroup,
        inContactStore contactStore: CNContactStore,
        sortedBy: SortOrder
    ) throws -> [CNContact] {
        let predicate =
            CNContact
                .predicateForContactsInGroup(withIdentifier: group.identifier)
        let contacts =
            try contactStore.unifiedContacts(
                matching: predicate,
                keysToFetch: ContactEnum.person().keysToFetch
            )
        let matchingContacts = contacts.compactMap { contact in
            contact.contactType == .person ? contact : nil
        }

        switch sortedBy {
            case .byJobTitle:
                return matchingContacts.sorted { left, right in
                    if left.jobTitle == right.jobTitle {
                        return left.familyName < right.familyName
                    } else if left.jobTitle.isEmpty || right.jobTitle.isEmpty {
                        return left.familyName < right.familyName
                    } else {
                        return left.jobTitle < right.jobTitle
                    }
                }

            case .byName:
                return matchingContacts.sorted { left, right in
                    left.familyName < right.familyName
                }
        }
    }

    /// Updates or saves the `contact`to the address book in the group named `groupName`
    /// if the contact does not already exist.
    ///
    /// If the group named `groupName` does not exist, creates the group.
    /// - Parameters:
    ///   - contact: contact to be saved
    ///   - groupName: name of the group in the adress book.
    /// - Returns: True si l'enregistrement à réussi.
    func saveOrUpdate(
        contact: ContactEnum,
        inContactGroup group: CNGroup,
        inContactStore contactStore: CNContactStore
    ) -> Bool {
        switch contact {
            case let .person(givenName, familyName, _, _, _, _):
                do {
                    if let existingContact = try personContact(
                        givenName: givenName,
                        familyName: familyName,
                        inContactStore: contactStore
                    ) {
                        // mettre à jour le contact existants
                        let updatedContact = existingContact.mutableCopy() as! CNMutableContact
                        contact.update(mutableContact: updatedContact)

                        let updateRequest = CNSaveRequest()
                        updateRequest.update(updatedContact)

                        try contactStore.execute(updateRequest)
                        customLog.log(
                            level: .info,
                            "Contact updated successfully!"
                        )
                        return true

                    } else {
                        // créer un nouveau contact
                        guard let newContact = contact.mutableContact() else {
                            customLog.log(
                                level: .error,
                                "Contact cannot be converted to CNMutableContact!"
                            )
                            return false
                        }

                        let saveRequest = CNSaveRequest()
                        saveRequest.add(newContact, toContainerWithIdentifier: nil)
                        try contactStore.execute(saveRequest)
                        customLog.log(
                            level: .info,
                            "New contact saved successfully!"
                        )

                        let addToGroupRequest = CNSaveRequest()
                        addToGroupRequest.addMember(newContact, to: group)
                        try contactStore.execute(addToGroupRequest)
                        customLog.log(
                            level: .info,
                            "New contact added to group successfully!"
                        )
                        return true
                    }

                } catch {
                    customLog.log(
                        level: .error,
                        "Error creating or updating contact: \(error.localizedDescription)"
                    )
                    return false
                }

            case let .organization(organizationName, _, _, _, _, _, _):
                do {
                    if let existingContact = try organizationContact(
                        inContactGroup: group,
                        inContactStore: contactStore,
                        withOrganizationName: organizationName
                    ) {
                        // mettre à jour le contact existants
                        let updatedContact = existingContact.mutableCopy() as! CNMutableContact

                        contact.update(mutableContact: updatedContact)

                        let updateRequest = CNSaveRequest()
                        updateRequest.update(updatedContact)

                        try contactStore.execute(updateRequest)
                        print("Contact updated successfully!")
                        return true

                    } else {
                        // créer un nouveau contact
                        guard let newContact = contact.mutableContact() else {
                            customLog.log(
                                level: .error,
                                "Contact cannot be converted to CNMutableContact!"
                            )
                            return false
                        }

                        let saveRequest = CNSaveRequest()
                        saveRequest.add(newContact, toContainerWithIdentifier: nil)

                        let addToGroupRequest = CNSaveRequest()
                        addToGroupRequest.addMember(newContact, to: group)

                        try contactStore.execute(saveRequest)
                        print("New contact saved successfully!")
                        try contactStore.execute(addToGroupRequest)
                        print("New contact added to group successfully!")
                        return true
                    }

                } catch {
                    customLog.log(
                        level: .error,
                        "Error creating or updating contact: \(error.localizedDescription)"
                    )
                    return false
                }
        }
    }

    /// Cherche un groupe de contacts nommé `groupName` dans l'app Contacts.
    /// Si le groupe n'existe pas, il est créé.
    /// - Parameter groupName: Nomn du groupe de contacts recherché.
    /// - Returns: Le groupe de contacts nommé `groupName`.
    func getOrCreateGroup(
        named groupName: String,
        inContactStore contactStore: CNContactStore
    ) -> (
        group: CNGroup?,
        alertIsPresented: Bool,
        alertTitle: String,
        alertMessage: String
    ) {
        // Récupérer tous les groupes de Contacts
        do {
            let groups = try contactStore.groups(matching: nil)

            if let existingGroup = groups.first(where: { $0.name == groupName }) {
                // Succès
                return (
                    group: existingGroup,
                    alertIsPresented: false,
                    alertTitle: "",
                    alertMessage: ""
                )

            } else {
                // Créer le groupe de contacts
                let newGroup = CNMutableGroup()
                newGroup.name = groupName

                // Enregistrer le nouveau groupe
                let saveRequest = CNSaveRequest()
                saveRequest.add(newGroup, toContainerWithIdentifier: nil)

                do {
                    try contactStore.execute(saveRequest)
                    return (
                        group: newGroup,
                        alertIsPresented: false,
                        alertTitle: "",
                        alertMessage: ""
                    )
                } catch {
                    customLog.log(
                        level: .error,
                        "Echec de l'opération sur les Contacts. La création d'un nouveau groupe de contacts \"\(groupName)\" a échouée."
                    )
                    // Echec
                    return (
                        group: nil,
                        alertIsPresented: true,
                        alertTitle: "Echec de l'opération sur les Contacts.",
                        alertMessage: "La création d'un nouveau groupe de contacts \"\(groupName)\" a échouée."
                    )
                }
            }

        } catch {
            customLog.log(
                level: .error,
                "Echec de l'opération sur les Contacts. Groupes de contacts introuvables."
            )
            // Echec
            return (
                group: nil,
                alertIsPresented: true,
                alertTitle: "Echec de l'opération sur les Contacts.",
                alertMessage: "Groupes de contacts introuvables."
            )
        }
    }
}
