//
//  ContactsViewModel.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 04/11/2023.
//

import Contacts
import Foundation
import os

private let customLog = Logger(
    subsystem: "com.michaud.lionel.Assistant-Professeur",
    category: "ContactsViewModel"
)

@MainActor
class ContactsViewModel: ObservableObject {
    /// Tableau des documents à imprimer dans les séances à venir
    @Published
    var contacts: [CNContact] = []

    /// Avancement de la recherche des ToDo dans les futurs séances
    @Published
    var status: ContactsLoadingStatus = .pending

    /// Récupérer les contacts dans l'appli "Contacts"
    func getAllContacts(
        forSchoolName schoolName: String,
        contactSortOrder: ContactManager.SortOrder
    ) async -> AlertInfo {
        status = .pending

        var contactGroup: CNGroup?
        var contacts = [CNContact]()
        var alert = AlertInfo()
        let contactStore = CNContactStore()

        (
            contactGroup,
            alert.isPresented,
            alert.title,
            alert.message
        ) = await ContactManager.shared.requestContactsAccess(
            contactStore: contactStore,
            groupName: schoolName
        )
        guard let contactGroup else {
            status = .failed
            return alert
        }

        status = .loading

        do {
            contacts = try ContactManager.shared.allPersonContacts(
                inOrganizationName: schoolName,
                inContactGroup: contactGroup,
                inContactStore: contactStore,
                sortedBy: contactSortOrder
            )
            status = .finished(contacts: contacts)
            return alert

        } catch {
            customLog.log(
                level: .error,
                "La tentative de récupération des contacts dans l'appli **Contacts** pour cet établissement à échouée."
            )
            alert.title = "Echec"
            alert.message = "La tentative de récupération des vos contacts dans votre appli **Contacts** pour cet établissement à échouée."
            alert.isPresented = true
            status = .finished(contacts: [])
            return alert
        }
    }
}
