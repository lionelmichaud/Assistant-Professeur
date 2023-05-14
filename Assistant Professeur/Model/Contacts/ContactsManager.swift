//
//  ContactsManager.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 10/05/2023.
//

import Contacts
import Foundation

enum ContactManager {
    /// Retourne le contact de type .organization dont le nom d'organisation est `organizationName`
    /// se trouvant dans le Groupe de contacts nommé `organizationName`.
    /// - Parameter organizationName: Nom de l'organisation recherchée
    /// - Returns: nil si le contact de l'organisation n'est pas trouvé.
    static func organizationContact(organizationName: String) async -> CNContact? {
        let store = CNContactStore()
        do {
            try await store.requestAccess(for: .contacts)

            do {
                let group = try getOrCreateGroup(named: organizationName)
                let predicate =
                    CNContact
                        .predicateForContactsInGroup(withIdentifier: group.identifier)
                let matchingContacts =
                    try store.unifiedContacts(
                        matching: predicate,
                        keysToFetch: ContactEnum.organization().keysToFetch
                    )

                return matchingContacts.first(where: {
                    $0.contactType == .organization && $0.organizationName == organizationName
                })

            } catch {
                print("Error getting or creating Contacts Group: \(error.localizedDescription)")
                return nil
            }

        } catch {
            print("Error saving contact: \(error.localizedDescription)")
            return nil
        }
    }

    static func personContact(
        givenName: String,
        familyName: String,
        inOrganizationName organizationName: String
    ) async -> CNContact? {
        let store = CNContactStore()
        do {
            try await store.requestAccess(for: .contacts)

            do {
                let group = try getOrCreateGroup(named: organizationName)
                let predicate =
                    CNContact
                        .predicateForContacts(matchingName: "\(givenName) \(familyName)")
                let matchingContacts =
                    try store.unifiedContacts(
                        matching: predicate,
                        keysToFetch: ContactEnum.person().keysToFetch
                    )

                return matchingContacts.first

            } catch {
                print("Error getting or creating Contact: \(error.localizedDescription)")
                return nil
            }

        } catch {
            print("Error saving contact: \(error.localizedDescription)")
            return nil
        }
    }

    /// Retourne tous les contacts de personnes inclus dans le groupe de contact nommé `organizationName`.
    /// - Parameter organizationName: Nom du groupe de contacts dans lequel recherchés les contacts.
    static func allPersonContacts(
        inOrganizationName organizationName: String
    ) async -> [CNContact] {
        let store = CNContactStore()
        do {
            try await store.requestAccess(for: .contacts)

            do {
                let group = try getOrCreateGroup(named: organizationName)
                let predicate =
                    CNContact
                        .predicateForContactsInGroup(withIdentifier: group.identifier)
                let contacts =
                    try store.unifiedContacts(
                        matching: predicate,
                        keysToFetch: ContactEnum.person().keysToFetch
                    )
                let matchingContacts = contacts.compactMap { contact in
                    contact.contactType == .person ? contact : nil
                }

                return matchingContacts

            } catch {
                print("Error getting or creating Contact: \(error.localizedDescription)")
                return []
            }

        } catch {
            print("Error saving contact: \(error.localizedDescription)")
            return []
        }
    }

    /// Saves or updates the `contact`to the address book in the group named `groupName`
    /// if the contact does not already exist. Else, do nothing.
    ///
    /// If the group named `groupName` does not exist, creates the group.
    /// - Parameters:
    ///   - contact: contact to be saved
    ///   - groupName: name of the group in the adress book.
    /// - Returns: True si l'enregistrement à réussi.
    static func saveOrUpdate(
        contact: ContactEnum,
        toGroupNamed groupName: String
    ) async -> Bool {
        let store = CNContactStore()
        do {
            try await store.requestAccess(for: .contacts)

            let group = try getOrCreateGroup(named: groupName)

            switch contact {
                case let .person(givenName, familyName, _, _, _, _):
                    do {
                        if let existingContact = await personContact(
                            givenName: givenName,
                            familyName: familyName,
                            inOrganizationName: groupName
                        ) {
                            // mettre à jour le contact existants
                            let updatedContact = existingContact.mutableCopy() as! CNMutableContact

                            contact.update(mutableContact: updatedContact)

                            let updateRequest = CNSaveRequest()
                            updateRequest.update(updatedContact)

                            try store.execute(updateRequest)
                            print("Contact updated successfully!")
                            return true

                        } else {
                            // créer un nouveau contact
                            guard let newContact = contact.mutableContact() else {
                                print("Contact cannot be converted to CNMutableContact!")
                                return false
                            }

                            let saveRequest = CNSaveRequest()
                            saveRequest.add(newContact, toContainerWithIdentifier: nil)

                            let addToGroupRequest = CNSaveRequest()
                            addToGroupRequest.addMember(newContact, to: group)

                            try store.execute(saveRequest)
                            print("New contact saved successfully!")
                            try store.execute(addToGroupRequest)
                            print("New contact added to group successfully!")
                            return true
                        }

                    } catch {
                        print("Error creating or updating contact: \(error.localizedDescription)")
                        return false
                    }

                case let .organization(organizationName, _, _, _, _, _, _):
                    do {
                        if let existingContact = await organizationContact(organizationName: organizationName) {
                            // mettre à jour le contact existants
                            let updatedContact = existingContact.mutableCopy() as! CNMutableContact

                            contact.update(mutableContact: updatedContact)

                            let updateRequest = CNSaveRequest()
                            updateRequest.update(updatedContact)

                            try store.execute(updateRequest)
                            print("Contact updated successfully!")
                            return true

                        } else {
                            // créer un nouveau contact
                            guard let newContact = contact.mutableContact() else {
                                print("Contact cannot be converted to CNMutableContact!")
                                return false
                            }

                            let saveRequest = CNSaveRequest()
                            saveRequest.add(newContact, toContainerWithIdentifier: nil)

                            let addToGroupRequest = CNSaveRequest()
                            addToGroupRequest.addMember(newContact, to: group)

                            try store.execute(saveRequest)
                            print("New contact saved successfully!")
                            try store.execute(addToGroupRequest)
                            print("New contact added to group successfully!")
                            return true
                        }

                    } catch {
                        print("Error creating or updating contact: \(error.localizedDescription)")
                        return false
                    }
            }

        } catch {
            print("Error saving contact: \(error.localizedDescription)")
            return false
        }
    }

    /// Cherche un groupe de contacts nommé `groupName` dans l'app Contacts.
    /// Si le groupe n'existe pas, il est créé.
    /// - Parameter groupName: <#groupName description#>
    /// - Returns: Le groupe de contacts nommé `groupName`.
    private static func getOrCreateGroup(named groupName: String) throws -> CNGroup {
        let groups = try CNContactStore().groups(matching: nil)

        if let existingGroup = groups.first(where: { $0.name == groupName }) {
            return existingGroup
        } else {
            let newGroup = CNMutableGroup()
            newGroup.name = groupName

            let saveRequest = CNSaveRequest()
            saveRequest.add(newGroup, toContainerWithIdentifier: nil)

            try CNContactStore().execute(saveRequest)

            return newGroup
        }
    }
}
