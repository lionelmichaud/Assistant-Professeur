//
//  OrganizationEditView.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 11/05/2023.
//

import AppFoundation
import HelpersView
import SwiftUI

struct SchoolContactEditView: View {
    @ObservedObject
    var school: SchoolEntity

    /// Focused filed manager
    enum FocusableField: Hashable {
        case phone
        case mail
        case url
        case street
        case postalCode
        case city
        case none

        mutating func moveToNext() {
            switch self {
                case .phone:
                    self = .mail
                case .mail:
                    self = .url
                case .url:
                    self = .street
                case .street:
                    self = .postalCode
                case .postalCode:
                    self = .city
                case .city:
                    self = .none
                case .none:
                    self = .none
            }
        }
    }

    @FocusState
    private var focus: FocusableField?

    @State
    private var alertTitle = ""
    @State
    private var alertIsPresented = false

    @State
    private var phoneNumber: String = ""
    @State
    private var emailAddress: String = ""
    @State
    private var urlAddress: String = ""
    @State
    private var street: String = ""
    @State
    private var postalCode: String = ""
    @State
    private var city: String = ""

    var body: some View {
        Section {
            TextField("Numéro de téléphone", text: $phoneNumber)
            #if os(iOS) || os(tvOS)
                .keyboardType(.phonePad)
            #endif
                .textContentType(.telephoneNumber)
                .submitLabel(.next)
                .focused($focus, equals: .phone)
                .onChange(of: phoneNumber) { _ in
                    phoneNumber = phoneNumber.formatPhoneNumber()
                }
            TextField("Adresse e-mail", text: $emailAddress)
            #if os(iOS) || os(tvOS)
                .keyboardType(.emailAddress)
                .textInputAutocapitalization(.never)
            #endif
                .submitLabel(.next)
                .focused($focus, equals: .mail)
            TextField("Site Web", text: $urlAddress)
            #if os(iOS) || os(tvOS)
                .keyboardType(.URL)
                .textInputAutocapitalization(.never)
            #endif
                .submitLabel(.next)
                .focused($focus, equals: .url)
            TextField("Rue", text: $street)
                .submitLabel(.next)
                .focused($focus, equals: .street)
            HStack {
                TextField("CP", text: $postalCode)
                #if os(iOS) || os(tvOS)
                    .keyboardType(.numberPad)
                #endif
                    .submitLabel(.next)
                    .focused($focus, equals: .postalCode)
                Divider()
                TextField("Ville", text: $city)
                    .autocorrectionDisabled(false)
                    .submitLabel(.next)
                    .focused($focus, equals: .city)
            }
            Button(action: saveContact) {
                Text("Enregistrer dans Contacts")
            }
            .horizontallyAligned(.center)
            .padding(.bottom)
        } header: {
            Label("Coordonnées de l'établissement", systemImage: "building")
                .bold()
        }
        // .textFieldStyle(.roundedBorder)
        .autocorrectionDisabled()
        .onSubmit {
            focus?.moveToNext()
        }
        .alert(
            alertTitle,
            isPresented: $alertIsPresented,
            actions: {}
        )
        .onAppear {
            focus = SchoolContactEditView.FocusableField.none
            Task {
                if let schoolContact = await ContactManager.organizationContact(organizationName: school.viewName),
                   let contact = ContactEnum(from: schoolContact) {
                    if case let ContactEnum.organization(_, phoneNumber, emailAddress, urlAddress, street, city, postalCode) = contact {
                        self.phoneNumber = phoneNumber
                        self.emailAddress = emailAddress
                        self.urlAddress = urlAddress
                        self.street = street
                        self.city = city
                        self.postalCode = postalCode
                    }
                }
            }
        }
    }

    private func saveContact() {
        Task {
            let contact =
                ContactEnum.organization(
                    organization: school.viewName,
                    phoneNumber: phoneNumber,
                    emailAddress: emailAddress,
                    urlAddress: urlAddress,
                    street: street,
                    city: city,
                    postalCode: postalCode
                )
            let success = await ContactManager.saveOrUpdate(
                contact: contact,
                toGroupNamed: school.viewName
            )
            if success {
                alertTitle = "Le contact a été enregistré."
                alertIsPresented.toggle()
            } else {
                alertTitle = "L'enregistrement à échoué."
                alertIsPresented.toggle()
            }
        }
    }
}

struct OrganizationEditView_Previews: PreviewProvider {
    static func initialize() {
        DataBaseManager.populateWithMockData(storeType: .inMemory)
    }

    static var previews: some View {
        initialize()
        return Group {
            NavigationStack {
                EmptyView()
                SchoolContactEditView(school: SchoolEntity.all().first!)
            }
            .environmentObject(NavigationModel(selectedSchoolMngObjId: SchoolEntity.all().first!.objectID))
            .environment(\.managedObjectContext, CoreDataManager.shared.context)
            .previewDevice("iPad mini (6th generation)")

            NavigationStack {
                EmptyView()
                SchoolContactEditView(school: SchoolEntity.all().first!)
            }
            .padding()
            .environmentObject(NavigationModel(selectedSchoolMngObjId: SchoolEntity.all().first!.objectID))
            .environment(\.managedObjectContext, CoreDataManager.shared.context)
            .previewDevice("iPhone 13")
        }
    }
}
