//
//  ContactView.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 28/10/2023.
//

import Contacts
import SwiftUI
import AppFoundation

struct ContactView: View {
    let contact: CNContact

    var body: some View {
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
