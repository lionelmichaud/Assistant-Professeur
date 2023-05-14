//
//  PersonContactEditView.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 13/05/2023.
//

import AppFoundation
import Contacts
import HelpersView
import SwiftUI

struct PersonsContactsView: View {
    @ObservedObject
    var school: SchoolEntity

    @State
    private var contacts = [CNContact]()

    var body: some View {
        Section("Contacts") {
            ForEach(contacts, id: \.identifier) { contact in
                DisclosureGroup(label(contact)) {
                    Text(CNContactFormatter.string(from: contact, style: .fullName) ?? "")
                        .textSelection(.enabled)
                    if hasPhoneNumber(contact) {
                        Text(contact.phoneNumbers.first!.value.stringValue)
                            .textSelection(.enabled)
                            .onLongPressGesture(minimumDuration: 1) {
                                call(telNumber: contact.phoneNumbers.first!.value.stringValue)
                            }
                    }
                    if hasEmailAddress(contact) {
                        Text((contact.emailAddresses.first!.value) as String)
                            .textSelection(.enabled)
                    }
                }
            }
            .emptyListPlaceHolder(contacts) {
                Text("Aucun contact dans cet établissement")
            }
        }
        .task {
            contacts = await ContactManager
                .allPersonContacts(inOrganizationName: school.viewName)
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
