//
//  PersonContactEditView.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 13/05/2023.
//

import AppFoundation
import Contacts
import HelpersView
import os
import SwiftUI

private let customLog = Logger(
    subsystem: "com.michaud.lionel.Assistant-Professeur",
    category: "PersonsContactsView"
)

struct PersonsContactsView: View {
    @ObservedObject
    var school: SchoolEntity

    @State
    private var contactStore = CNContactStore()

    @State
    private var contacts = [CNContact]()

    @State
    private var contactSortOrder: ContactManager.SortOrder = .byJobTitle

    @State
    private var alertTitle = ""

    @State
    private var alertMessage = ""

    @State
    private var alertIsPresented = false

    var body: some View {
        Section {
            Picker("Tri", selection: $contactSortOrder) {
                Text("Tri par Nom").tag(ContactManager.SortOrder.byName)
                Text("Tri par Titre").tag(ContactManager.SortOrder.byJobTitle)
            }
            .pickerStyle(.segmented)
            ForEach(contacts, id: \.identifier) { contact in
                DisclosureGroup(label(contact)) {
                    if hasJobTitle(contact) {
                        Text(CNContactFormatter.string(from: contact, style: .fullName) ?? "")
                            .textSelection(.enabled)
                    }
                    if hasPhoneNumber(contact) {
                        Text(contact.phoneNumbers.first!.value.stringValue.formatPhoneNumber())
                            .foregroundColor(.accentColor)
                            .onLongPressGesture(minimumDuration: 1) {
                                call(telNumber: contact.phoneNumbers.first!.value.stringValue
                                    .replacingOccurrences(of: " ", with: "", count: 10))
                            }
                    }
                    if hasEmailAddress(contact) {
                        Text((contact.emailAddresses.first!.value) as String)
                            .foregroundColor(.accentColor)
                            .onLongPressGesture(minimumDuration: 1) {
                                sendMail(to: contact.emailAddresses.first!.value as String)
                            }
                    }
                }
            }
            .emptyListPlaceHolder(contacts) {
                Text("Aucun contact trouvé dans votre appli **Contacts** pour cet établissement.")
            }
        } header: {
            Label("Contacts", systemImage: "person")
                .font(.callout)
                .foregroundColor(.secondary)
                .fontWeight(.bold)
        } footer: {
            Text("Les contacts de votre appli **Contacts**, enregistrés dans la liste nommée **\(school.viewName)** sont affichés ici.")
        }
        .alert(
            alertTitle,
            isPresented: $alertIsPresented,
            actions: {},
            message: { Text(alertMessage) }
        )
        .task(id: contactSortOrder) {
            (
                alertIsPresented,
                alertTitle,
                alertMessage
            ) = await ContactManager.shared.requestContactsAccess(
                contactStore: contactStore,
                groupName: school.viewName
            ) { group in
                do {
                    contacts = try ContactManager.shared.allPersonContacts(
                        inOrganizationName: school.viewName,
                        inContactGroup: group,
                        inContactStore: contactStore,
                        sortedBy: contactSortOrder
                    )
                } catch {
                    customLog.log(
                        level: .error,
                        "La tentative de récupération des contacts dans l'appli **Contacts** pour cet établissement à échouée."
                    )
                    alertTitle = "Echec"
                    alertMessage = "La tentative de récupération des vos contacts dans votre appli **Contacts** pour cet établissement à échouée."
                    alertIsPresented = true
                }
            }
        }
    }

    private func label(_ contact: CNContact) -> String {
        hasJobTitle(contact) ?
            contact.jobTitle :
            CNContactFormatter.string(from: contact, style: .fullName) ?? ""
    }

    private func hasJobTitle(_ contact: CNContact) -> Bool {
        contact.isKeyAvailable(CNContactJobTitleKey) && contact.jobTitle.isNotEmpty
    }

    private func hasPhoneNumber(_ contact: CNContact) -> Bool {
        contact.isKeyAvailable(CNContactPhoneNumbersKey) && contact.phoneNumbers.first != nil
    }

    private func hasEmailAddress(_ contact: CNContact) -> Bool {
        contact.isKeyAvailable(CNContactEmailAddressesKey) && contact.emailAddresses.first != nil
    }
}

struct PersonContactEditView_Previews: PreviewProvider {
    static func initialize() {
        DataBaseManager.populateWithMockData(storeType: .inMemory)
    }

    static var previews: some View {
        initialize()
        return Group {
            NavigationStack {
                EmptyView()
                PersonsContactsView(school: SchoolEntity.all().first!)
            }
            .environmentObject(NavigationModel(selectedSchoolMngObjId: SchoolEntity.all().first!.objectID))
            .environment(\.managedObjectContext, CoreDataManager.shared.context)
            .previewDevice("iPad mini (6th generation)")

            NavigationStack {
                EmptyView()
                PersonsContactsView(school: SchoolEntity.all().first!)
            }
            .padding()
            .environmentObject(NavigationModel(selectedSchoolMngObjId: SchoolEntity.all().first!.objectID))
            .environment(\.managedObjectContext, CoreDataManager.shared.context)
            .previewDevice("iPhone 13")
        }
    }
}
