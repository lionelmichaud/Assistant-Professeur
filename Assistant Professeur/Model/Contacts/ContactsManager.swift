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

    /// Saves or updates the `contact`to the address book in the group named `groupName`
    /// if the contact does not already exist. Else, do nothing.
    ///
    /// If the group named `groupName` does not exist, creates the group.
    /// - Parameters:
    ///   - contact: contact to be saved
    ///   - groupName: name of the group in the adress book.
    /// - Returns: True si l'enregistrement à réussi.
    static func save(
        contact: ContactEnum,
        to groupName: String
    ) async -> Bool {
        let store = CNContactStore()
        do {
            try await store.requestAccess(for: .contacts)

            let group = try getOrCreateGroup(named: groupName)

            switch contact {
                case let .person(givenName, familyName, _, _, _, _):
                    let predicate =
                        CNContact
                            .predicateForContacts(matchingName: "\(givenName) \(familyName)")
                    let matchingContacts =
                        try store.unifiedContacts(matching: predicate, keysToFetch: ContactEnum.person().keysToFetch)

                    if !matchingContacts.isEmpty {
                        print("A contact with the same name already exists!")
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

        return false
    }

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
