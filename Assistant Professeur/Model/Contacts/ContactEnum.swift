//
//  ContactEnum.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 13/05/2023.
//

import Contacts
import Foundation

enum ContactEnum {
    case person(
        givenName: String = "",
        familyName: String = "",
        jobTitle: String = "",
        phoneNumber: String = "",
        emailAddress: String = "",
        urlAddress: String = ""
    )
    case organization(
        organization: String = "",
        phoneNumber: String = "",
        emailAddress: String = "",
        urlAddress: String = "",
        street: String = "",
        city: String = "",
        postalCode: String = ""
    )

    // MARK: - Initializer

    /// Generates a ContactEnum from a CNContact
    init?(from contact: CNContact) {
        switch contact.contactType {
            case .person:
                self = .person(
                    givenName: contact.givenName,
                    familyName: contact.familyName,
                    jobTitle: contact.jobTitle,
                    phoneNumber: contact.phoneNumbers.first?.value.stringValue ?? "",
                    emailAddress: (contact.emailAddresses.first?.value ?? "") as String,
                    urlAddress: (contact.urlAddresses.first?.value ?? "") as String
                )
            case .organization:
                self = .organization(
                    organization: contact.organizationName,
                    phoneNumber: contact.phoneNumbers.first?.value.stringValue ?? "",
                    emailAddress: (contact.emailAddresses.first?.value ?? "") as String,
                    urlAddress: (contact.urlAddresses.first?.value ?? "") as String,
                    street: contact.postalAddresses.first?.value.street ?? "",
                    city: contact.postalAddresses.first?.value.city ?? "",
                    postalCode: contact.postalAddresses.first?.value.postalCode ?? ""
                )

            @unknown default:
                return nil
        }
    }

    // MARK: - Computed Properties

    /// Contact's descriptors to fetch from the Contacts database
    var keysToFetch: [CNKeyDescriptor] {
        switch self {
            case .person:
                return [
                    CNContactTypeKey as CNKeyDescriptor,
                    CNContactFormatter.descriptorForRequiredKeys(for: .fullName),
                    CNContactJobTitleKey as CNKeyDescriptor,
                    CNContactPhoneNumbersKey as CNKeyDescriptor,
                    CNContactEmailAddressesKey as CNKeyDescriptor,
                    CNContactUrlAddressesKey as CNKeyDescriptor
                ]
            case .organization:
                return [
                    CNContactTypeKey as CNKeyDescriptor,
                    CNContactOrganizationNameKey as CNKeyDescriptor,
                    CNContactPhoneNumbersKey as CNKeyDescriptor,
                    CNContactEmailAddressesKey as CNKeyDescriptor,
                    CNContactUrlAddressesKey as CNKeyDescriptor,
                    CNContactPostalAddressesKey as CNKeyDescriptor
                ]
        }
    }

    // MARK: - Methods

    func update(mutableContact: CNMutableContact) {
        switch self {
            case let .person(givenName, familyName, jobTitle, phoneNumber, emailAddress, urlAddress):
                guard givenName.isNotEmpty || familyName.isNotEmpty else {
                    return
                }
                mutableContact.contactType = .person
                mutableContact.givenName = givenName
                mutableContact.familyName = familyName
                mutableContact.jobTitle = jobTitle

                if phoneNumber.isNotEmpty {
                    let phone = CNLabeledValue(
                        label: CNLabelPhoneNumberMobile,
                        value: CNPhoneNumber(stringValue: phoneNumber)
                    )
                    mutableContact.phoneNumbers = [phone]
                }

                if emailAddress.isNotEmpty {
                    let email = CNLabeledValue(
                        label: CNLabelSchool,
                        value: emailAddress as NSString
                    )
                    mutableContact.emailAddresses = [email]
                }

                if urlAddress.isNotEmpty {
                    let url = CNLabeledValue(
                        label: CNLabelURLAddressHomePage,
                        value: urlAddress as NSString
                    )
                    mutableContact.urlAddresses = [url]
                }

            case let .organization(organization, phoneNumber, emailAddress, urlAddress, street, city, postalCode):
                guard organization.isNotEmpty else {
                    return
                }

                mutableContact.contactType = .organization
                mutableContact.organizationName = organization

                if phoneNumber.isNotEmpty {
                    let phone = CNLabeledValue(
                        label: CNLabelPhoneNumberMobile,
                        value: CNPhoneNumber(stringValue: phoneNumber)
                    )
                    mutableContact.phoneNumbers = [phone]
                }

                if emailAddress.isNotEmpty {
                    let email = CNLabeledValue(
                        label: CNLabelSchool,
                        value: emailAddress as NSString
                    )
                    mutableContact.emailAddresses = [email]
                }

                if urlAddress.isNotEmpty {
                    let url = CNLabeledValue(
                        label: CNLabelURLAddressHomePage,
                        value: urlAddress as NSString
                    )
                    mutableContact.urlAddresses = [url]
                }

                let postalAddress = CNMutablePostalAddress()
                postalAddress.street = street
                postalAddress.city = city
                postalAddress.postalCode = postalCode
                postalAddress.country = "France"
                mutableContact.postalAddresses = [
                    CNLabeledValue(
                        label: CNLabelSchool,
                        value: postalAddress
                    )
                ]
        }
    }

    /// Generates a new CNMutableContact from a ContactEnum
    /// - Returns: a new CNMutableContact or nil
    func mutableContact() -> CNMutableContact? {
        switch self {
            case let .person(givenName, familyName, jobTitle, phoneNumber, emailAddress, urlAddress):
                guard givenName.isNotEmpty || familyName.isNotEmpty else {
                    return nil
                }

                let newContact = CNMutableContact()
                newContact.contactType = .person
                newContact.givenName = givenName
                newContact.familyName = familyName
                newContact.jobTitle = jobTitle

                if phoneNumber.isNotEmpty {
                    let phone = CNLabeledValue(
                        label: CNLabelPhoneNumberMobile,
                        value: CNPhoneNumber(stringValue: phoneNumber)
                    )
                    newContact.phoneNumbers = [phone]
                }

                if emailAddress.isNotEmpty {
                    let email = CNLabeledValue(
                        label: CNLabelSchool,
                        value: emailAddress as NSString
                    )
                    newContact.emailAddresses = [email]
                }

                if urlAddress.isNotEmpty {
                    let url = CNLabeledValue(
                        label: CNLabelURLAddressHomePage,
                        value: urlAddress as NSString
                    )
                    newContact.urlAddresses = [url]
                }

                return newContact

            case let .organization(organization, phoneNumber, emailAddress, urlAddress, street, city, postalCode):
                guard organization.isNotEmpty else {
                    return nil
                }

                let newContact = CNMutableContact()
                newContact.contactType = .organization
                newContact.organizationName = organization

                if phoneNumber.isNotEmpty {
                    let phone = CNLabeledValue(
                        label: CNLabelPhoneNumberMobile,
                        value: CNPhoneNumber(stringValue: phoneNumber)
                    )
                    newContact.phoneNumbers = [phone]
                }

                if emailAddress.isNotEmpty {
                    let email = CNLabeledValue(
                        label: CNLabelSchool,
                        value: emailAddress as NSString
                    )
                    newContact.emailAddresses = [email]
                }

                if urlAddress.isNotEmpty {
                    let url = CNLabeledValue(
                        label: CNLabelURLAddressHomePage,
                        value: urlAddress as NSString
                    )
                    newContact.urlAddresses = [url]
                }

                let postalAddress = CNMutablePostalAddress()
                postalAddress.street = street
                postalAddress.city = city
                postalAddress.postalCode = postalCode
                postalAddress.country = "France"
                newContact.postalAddresses = [
                    CNLabeledValue(
                        label: CNLabelSchool,
                        value: postalAddress
                    )
                ]

                return newContact
        }
    }
}
